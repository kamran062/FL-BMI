import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  // Wednesday
  final now = DateTime(2026, 11, 11, 18);

  /// [weeks] full weeks before this one, [perWeek] workouts each.
  List<WorkoutSummary> history(int weeks, {int perWeek = 3, int skipWeek = -1}) => [
        for (var w = 1; w <= weeks; w++)
          if (w != skipWeek)
            for (var d = 0; d < perWeek; d++)
              WorkoutSummary(
                  Workout(
                      id: w * 10 + d,
                      startedAt: DateTime(2026, 11, 9 - 7 * w + d * 2, 18),
                      finishedAt: DateTime(2026, 11, 9 - 7 * w + d * 2, 19)),
                  const []),
      ];

  group('Deload', () {
    test('after 5 hard weeks in a row, the 6th is a deload week', () {
      expect(Deload.streak(history(5), now, 3), 5);
      expect(Deload.due(history(5), now, 3), isTrue);
      expect(Deload.due(history(4), now, 3), isFalse);
      // Trained through the deload: count restarts, next one 6 weeks later
      expect(Deload.due(history(6), now, 3), isFalse);
      expect(Deload.due(history(11), now, 3), isTrue);
    });

    test('a light or missed week breaks the run', () {
      expect(Deload.streak(history(8, skipWeek: 3), now, 3), 2);
      // 3 days a week: 2 workouts still counts as hard; 1 doesn't
      expect(Deload.streak(history(5, perWeek: 2), now, 3), 5);
      expect(Deload.streak(history(5, perWeek: 1), now, 3), 0);
    });
  });

  group('suggestions', () {
    WorkoutSet s(double kg, int reps, [double? rpe]) =>
        WorkoutSet(workoutId: 1, exerciseId: 'x', order: 0, weightKg: kg, reps: reps, done: true, rpe: rpe);

    test('deload week: about 10% lighter, rounded to the plate step', () {
      final sessions = [
        [s(100, 12), s(100, 12)]
      ];
      final normal = Progression.suggest(sessions, ExerciseEquipment.barbell);
      expect(normal.weightKg, 102.5);
      final light = Progression.suggest(sessions, ExerciseEquipment.barbell, deloadWeek: true);
      expect(light.reason, SuggestionReason.deloadWeek);
      expect(light.weightKg, 92.5);
      expect(light.reps, normal.reps);
    });

    test('deload week, bodyweight: fewer reps', () {
      final light = Progression.suggest([
        [s(0, 20)]
      ], ExerciseEquipment.bodyweight, deloadWeek: true);
      expect(light.reason, SuggestionReason.deloadWeek);
      expect(light.reps, 15); // 21 × 0.7
    });

    test('effort: very hard holds the weight, easy jumps two steps', () {
      final hard = Progression.suggest([
        [s(100, 12, 10), s(100, 12, 9.5)]
      ], ExerciseEquipment.barbell);
      expect(hard.reason, SuggestionReason.hold);
      expect(hard.weightKg, 100);

      final easy = Progression.suggest([
        [s(100, 12, 7), s(100, 12, 6)]
      ], ExerciseEquipment.barbell);
      expect(easy.reason, SuggestionReason.increase);
      expect(easy.weightKg, 105);

      final unrated = Progression.suggest([
        [s(100, 12), s(100, 12)]
      ], ExerciseEquipment.barbell);
      expect(unrated.weightKg, 102.5);
    });
  });

  test('skipping a deload week is remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final tmp = Directory.systemTemp.createTempSync('deload');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/d.db');
    for (final h in history(5)) {
      final id = await db.insertWorkout(h.workout.copyWith());
      await db.insertSet(WorkoutSet(workoutId: id, exerciseId: 'push_up', order: 0, reps: 10, done: true));
    }
    final w = WorkoutProvider(db);
    await w.load();
    expect(w.deloadDue(3, now: now), isTrue);
    await w.skipDeload(now: now);
    expect(w.deloadDue(3, now: now), isFalse);

    final again = WorkoutProvider(db);
    await again.load();
    expect(again.deloadDue(3, now: now), isFalse);
    // Next week isn't skipped (and isn't due either: the run continues)
    expect(again.deloadDue(3, now: now.add(const Duration(days: 7))), isFalse);
    await db.close();
    tmp.deleteSync(recursive: true);
  });
}
