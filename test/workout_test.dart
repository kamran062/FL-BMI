import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

WorkoutSet _set(String ex, double kg, int reps, {bool done = true, int w = 1}) =>
    WorkoutSet(workoutId: w, exerciseId: ex, order: 0, weightKg: kg, reps: reps, done: done);

void main() {
  group('WorkoutMath', () {
    test('Epley 1RM: 100 kg × 5 ≈ 116.7 kg; singles are exact', () {
      expect(WorkoutMath.estimated1RM(100, 5), closeTo(116.67, 0.01));
      expect(WorkoutMath.estimated1RM(100, 1), 100);
      expect(WorkoutMath.estimated1RM(0, 10), 0);
      // reps capped at 12
      expect(WorkoutMath.estimated1RM(50, 30), WorkoutMath.estimated1RM(50, 12));
    });

    test('volume counts completed sets only', () {
      expect(WorkoutMath.volume([_set('a', 60, 10), _set('a', 60, 8, done: false)]), 600);
    });

    test('PR only when an earlier best exists and is beaten', () {
      final prev = {'bench': WorkoutMath.estimated1RM(80, 5)};
      expect(WorkoutMath.personalRecords(prev, [_set('bench', 82.5, 5)]), {'bench'});
      expect(WorkoutMath.personalRecords(prev, [_set('bench', 80, 5)]), isEmpty);
      expect(WorkoutMath.personalRecords(prev, [_set('squat', 100, 5)]), isEmpty);
    });
  });

  test('bundled catalog parses and every exercise has steps', () {
    final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());
    expect(catalog.exercises.length, greaterThanOrEqualTo(30));
    for (final e in catalog.exercises) {
      expect(e.stepsIn('en'), isNotEmpty, reason: e.id);
      expect(e.nameIn('ur'), isNotEmpty, reason: e.id);
    }
    expect(catalog.byId('push_up')?.equipment, ExerciseEquipment.bodyweight);
  });

  test('video falls back to the other demonstrator if one is missing', () {
    const e = Exercise(id: 'x', name: {'en': 'X'}, primary: Muscle.chest,
        equipment: ExerciseEquipment.dumbbell, difficulty: Difficulty.beginner,
        femaleVideo: 'f.mp4');
    expect(e.videoFor(Sex.female), 'f.mp4');
    expect(e.videoFor(Sex.male), 'f.mp4');
  });

  test('home equipment excludes machines and barbells', () {
    final home = equipmentFor(Equipment.home);
    expect(home, contains(ExerciseEquipment.dumbbell));
    expect(home, isNot(contains(ExerciseEquipment.machine)));
    expect(equipmentFor(Equipment.none), {ExerciseEquipment.bodyweight});
  });

  group('WorkoutProvider', () {
    sqfliteFfiInit();
    late Directory tmp;
    late DatabaseHelper db;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('workout_test');
      db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/w.db');
    });
    tearDown(() async {
      await db.close();
      tmp.deleteSync(recursive: true);
    });

    test('a workout survives the app restarting mid-session', () async {
      final p = WorkoutProvider(db);
      await p.load();
      await p.start();
      await p.addExercise('push_up');
      final s = p.setsFor('push_up').single;
      await p.updateSet(s.copyWith(reps: 12, done: true));

      final reopened = WorkoutProvider(db);
      await reopened.load();
      expect(reopened.active, isNotNull);
      expect(reopened.setsFor('push_up').single.reps, 12);
      expect(reopened.setsFor('push_up').single.done, isTrue);
    });

    test('finish keeps done sets, drops unticked ones, detects PRs', () async {
      final p = WorkoutProvider(db);
      await p.load();

      // Workout 1: bench 80×5
      await p.start();
      await p.addExercise('barbell_bench_press');
      var s = p.setsFor('barbell_bench_press').single;
      await p.updateSet(s.copyWith(weightKg: 80, reps: 5, done: true));
      await p.finish();

      // Workout 2: prefilled from last time, then a heavier set + an unticked one
      await p.start();
      await p.addExercise('barbell_bench_press');
      s = p.setsFor('barbell_bench_press').single;
      expect(s.weightKg, 80); // "previous" prefill
      await p.updateSet(s.copyWith(weightKg: 85, reps: 5, done: true));
      await p.addSet('barbell_bench_press'); // left unticked
      final summary = await p.finish();

      expect(summary!.sets, hasLength(1));
      expect(summary.prCount, 1);
      expect(p.history, hasLength(2));
      expect(p.active, isNull);
    });

    test('finishing with nothing ticked discards the workout', () async {
      final p = WorkoutProvider(db);
      await p.load();
      await p.start();
      await p.addExercise('plank');
      expect(await p.finish(), isNull);
      expect(p.history, isEmpty);
      expect(await db.getActiveWorkout(), isNull);
    });

    test('routines start a workout with their exercises', () async {
      final p = WorkoutProvider(db);
      await p.load();
      await p.saveRoutine('Push day', ['push_up', 'bench_dip']);
      await p.start(routine: p.routines.single);
      expect(p.activeExercises, ['push_up', 'bench_dip']);
      expect(p.active!.name, 'Push day');
    });
  });
}
