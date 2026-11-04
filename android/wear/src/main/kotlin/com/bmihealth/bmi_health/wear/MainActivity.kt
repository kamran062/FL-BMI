package com.bmihealth.bmi_health.wear

import android.Manifest
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.Wearable
import kotlinx.coroutines.delay

private val Brand = Color(0xFF22B573)

/**
 * Watch companion (ROADMAP 5.4): shows the current set from the phone,
 * "Done" ticks it on the phone, rest countdown, heart rate while a workout
 * is running.
 */
class MainActivity : ComponentActivity(), DataClient.OnDataChangedListener, SensorEventListener {

    private var state by mutableStateOf(WorkoutState())
    private var heartRate by mutableIntStateOf(0)
    private var lastHrSent = 0L
    private var hrAllowed by mutableStateOf(false)

    private val askHr = registerForActivityResult(ActivityResultContracts.RequestPermission()) {
        hrAllowed = it
        updateSensor()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        hrAllowed = checkSelfPermission(Manifest.permission.BODY_SENSORS) == PackageManager.PERMISSION_GRANTED
        // Debug builds only: show a given state without a paired phone
        // (adb shell am start ... --es debug_state '<json>').
        if (BuildConfig.DEBUG) intent?.getStringExtra("debug_state")?.let { apply(it) }
        setContent {
            MaterialTheme {
                WorkoutScreen(
                    state = state,
                    heartRate = heartRate,
                    hrAllowed = hrAllowed,
                    onDone = ::sendDone,
                    onAllowHr = { askHr.launch(Manifest.permission.BODY_SENSORS) },
                    onRestOver = ::buzz,
                )
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Wearable.getDataClient(this).addListener(this)
        // Pick up the current state (the phone may have sent it while we were closed).
        Wearable.getDataClient(this).dataItems.addOnSuccessListener { items ->
            items.filter { it.uri.path == WORKOUT_PATH }.maxByOrNull {
                DataMapItem.fromDataItem(it).dataMap.getLong("t")
            }?.let { apply(DataMapItem.fromDataItem(it).dataMap.getString("json")) }
            items.release()
        }
        updateSensor()
    }

    override fun onPause() {
        Wearable.getDataClient(this).removeListener(this)
        stopSensor()
        super.onPause()
    }

    override fun onDataChanged(events: DataEventBuffer) {
        for (e in events) {
            if (e.type == DataEvent.TYPE_CHANGED && e.dataItem.uri.path == WORKOUT_PATH) {
                apply(DataMapItem.fromDataItem(e.dataItem).dataMap.getString("json"))
            }
        }
    }

    private fun apply(json: String?) {
        state = WorkoutState.parse(json)
        // Keep the screen on during a workout.
        if (state.active) window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        updateSensor()
    }

    private fun sendToPhone(path: String, data: ByteArray) {
        Wearable.getNodeClient(this).connectedNodes.addOnSuccessListener { nodes ->
            nodes.forEach { Wearable.getMessageClient(this).sendMessage(it.id, path, data) }
        }
    }

    private fun sendDone() = sendToPhone(SET_DONE_PATH, ByteArray(0))

    private fun buzz() {
        // A missing vibrator must never crash the workout screen.
        runCatching {
            getSystemService(Vibrator::class.java)
                ?.vibrate(VibrationEffect.createOneShot(400, VibrationEffect.DEFAULT_AMPLITUDE))
        }
    }

    // ── Heart rate: only while a workout is active and the app is open ──────
    private fun updateSensor() {
        if (state.active && hrAllowed) startSensor() else stopSensor()
    }

    private fun startSensor() {
        val sm = getSystemService(SensorManager::class.java) ?: return
        val hr = sm.getDefaultSensor(Sensor.TYPE_HEART_RATE) ?: return
        sm.registerListener(this, hr, SensorManager.SENSOR_DELAY_NORMAL)
    }

    private fun stopSensor() {
        getSystemService(SensorManager::class.java)?.unregisterListener(this)
        heartRate = 0
    }

    override fun onSensorChanged(event: SensorEvent) {
        val bpm = event.values.firstOrNull()?.toInt() ?: return
        if (bpm <= 0) return
        heartRate = bpm
        val now = System.currentTimeMillis()
        if (now - lastHrSent >= 5_000) { // at most every 5 s
            lastHrSent = now
            sendToPhone(HEART_RATE_PATH, bpm.toString().toByteArray())
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    companion object {
        const val WORKOUT_PATH = "/workout"
        const val SET_DONE_PATH = "/set_done"
        const val HEART_RATE_PATH = "/heart_rate"
    }
}

@Composable
fun WorkoutScreen(
    state: WorkoutState,
    heartRate: Int,
    hrAllowed: Boolean,
    onDone: () -> Unit,
    onAllowHr: () -> Unit,
    onRestOver: () -> Unit,
) {
    var now by mutableLongStateOf(System.currentTimeMillis())
    LaunchedEffect(state.restEndsAt) {
        var wasResting = state.restLeft(System.currentTimeMillis()) > 0
        while (true) {
            now = System.currentTimeMillis()
            val resting = state.restLeft(now) > 0
            if (wasResting && !resting) onRestOver()
            wasResting = resting
            delay(250)
        }
    }

    TimeText()
    Column(
        modifier = Modifier.fillMaxSize().padding(horizontal = 18.dp, vertical = 26.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        when {
            !state.active -> Text(stringResource(R.string.no_workout), textAlign = TextAlign.Center)
            state.allDone -> Text(stringResource(R.string.all_done), textAlign = TextAlign.Center)
            else -> {
                Text(state.exercise, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center,
                    maxLines = 2, overflow = TextOverflow.Ellipsis)
                Text(stringResource(R.string.set_of, state.setNumber, state.setsTotal), fontSize = 12.sp)
                Text(state.target, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                val rest = state.restLeft(now)
                if (rest > 0) {
                    Text(stringResource(R.string.rest, formatClock(rest)), color = Brand)
                }
                Button(
                    onClick = onDone,
                    modifier = Modifier.fillMaxWidth().padding(top = 6.dp),
                    colors = ButtonDefaults.buttonColors(backgroundColor = Brand),
                ) { Text(stringResource(R.string.done)) }
            }
        }
        if (state.active) {
            when {
                heartRate > 0 -> Text(stringResource(R.string.bpm, heartRate), color = Color(0xFFFF6B6B),
                    modifier = Modifier.padding(top = 4.dp))
                !hrAllowed -> Text(stringResource(R.string.allow_hr), color = Brand, fontSize = 12.sp,
                    modifier = Modifier.padding(top = 4.dp).then(Modifier),
                    textAlign = TextAlign.Center)
            }
        }
    }
    if (state.active && !hrAllowed) LaunchedEffect(Unit) { onAllowHr() }
}
