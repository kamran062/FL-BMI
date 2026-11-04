package com.bmihealth.bmi_health.wear

import org.json.JSONObject

/** Mirror of WearState in lib/features/train/wear/wear_bridge.dart. */
data class WorkoutState(
    val active: Boolean = false,
    val exercise: String = "",
    val setNumber: Int = 0,
    val setsTotal: Int = 0,
    val weightKg: Double = 0.0,
    val reps: Int = 0,
    val restEndsAt: Long = 0,
    val allDone: Boolean = false,
) {
    /** Seconds of rest left at [nowMs] (0 when none). */
    fun restLeft(nowMs: Long): Int =
        if (restEndsAt <= nowMs) 0 else ((restEndsAt - nowMs + 999) / 1000).toInt()

    /** "60 kg × 8", or "× 12" for bodyweight sets. */
    val target: String
        get() {
            val kg = if (weightKg == Math.floor(weightKg)) weightKg.toLong().toString()
                     else String.format(java.util.Locale.US, "%.1f", weightKg)
            return if (weightKg > 0) "$kg kg × $reps" else "× $reps"
        }

    companion object {
        fun parse(json: String?): WorkoutState {
            if (json.isNullOrBlank()) return WorkoutState()
            return try {
                val o = JSONObject(json)
                WorkoutState(
                    active = o.optBoolean("active"),
                    exercise = o.optString("exercise"),
                    setNumber = o.optInt("setNumber"),
                    setsTotal = o.optInt("setsTotal"),
                    weightKg = o.optDouble("weightKg", 0.0),
                    reps = o.optInt("reps"),
                    restEndsAt = o.optLong("restEndsAt"),
                    allDone = o.optBoolean("allDone"),
                )
            } catch (e: Exception) {
                WorkoutState() // never crash on a bad message
            }
        }
    }
}

fun formatClock(seconds: Int): String = "%d:%02d".format(seconds / 60, seconds % 60)
