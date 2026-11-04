package com.bmihealth.bmi_health.wear

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WorkoutStateTest {
    @Test fun parsesThePhonesJson() {
        val s = WorkoutState.parse(
            """{"active":true,"exercise":"Barbell Bench Press","setNumber":2,"setsTotal":3,
               "weightKg":62.5,"reps":8,"restEndsAt":1000000,"allDone":false}""")
        assertTrue(s.active)
        assertEquals("Barbell Bench Press", s.exercise)
        assertEquals(2, s.setNumber)
        assertEquals("62.5 kg × 8", s.target)
    }

    @Test fun wholeKilosAndBodyweight() {
        assertEquals("60 kg × 10", WorkoutState(weightKg = 60.0, reps = 10).target)
        assertEquals("× 15", WorkoutState(weightKg = 0.0, reps = 15).target)
    }

    @Test fun restCountdownRoundsUpAndStopsAtZero() {
        val s = WorkoutState(restEndsAt = 90_000)
        assertEquals(90, s.restLeft(0))
        assertEquals(1, s.restLeft(89_500))
        assertEquals(0, s.restLeft(90_000))
        assertEquals(0, s.restLeft(200_000))
        assertEquals("1:30", formatClock(90))
    }

    @Test fun badOrMissingJsonIsIdle() {
        assertFalse(WorkoutState.parse(null).active)
        assertFalse(WorkoutState.parse("not json").active)
    }
}
