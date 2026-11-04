package com.bmihealth.bmi_health

import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by the Health Connect permission flow
// (health package).
class MainActivity : FlutterFragmentActivity(), MessageClient.OnMessageReceivedListener {

    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Wear OS companion (ROADMAP 5.4): workout state → watch,
        // "set done" and heart rate ← watch. See wear/ and wear_bridge.dart.
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bmi_health/wear").apply {
            setMethodCallHandler { call, result ->
                if (call.method != "sync") return@setMethodCallHandler result.notImplemented()
                val json = call.arguments as? String ?: return@setMethodCallHandler result.success(false)
                val request = PutDataMapRequest.create(WORKOUT_PATH).apply {
                    dataMap.putString("json", json)
                    // Data items only sync when they change; a timestamp
                    // makes every update reach the watch.
                    dataMap.putLong("t", System.currentTimeMillis())
                }.asPutDataRequest().setUrgent()
                Wearable.getDataClient(this@MainActivity).putDataItem(request)
                    .addOnSuccessListener { result.success(true) }
                    .addOnFailureListener { result.success(false) } // no watch / Play services
            }
        }
        Wearable.getMessageClient(this).addListener(this)
    }

    override fun onMessageReceived(event: MessageEvent) {
        val ch = channel ?: return
        runOnUiThread {
            when (event.path) {
                SET_DONE_PATH -> ch.invokeMethod("setDone", null)
                HEART_RATE_PATH -> String(event.data).toIntOrNull()?.let { ch.invokeMethod("heartRate", it) }
            }
        }
    }

    override fun onDestroy() {
        Wearable.getMessageClient(this).removeListener(this)
        channel = null
        super.onDestroy()
    }

    companion object {
        const val WORKOUT_PATH = "/workout"
        const val SET_DONE_PATH = "/set_done"
        const val HEART_RATE_PATH = "/heart_rate"
    }
}
