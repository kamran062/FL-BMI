import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/app_harness.dart';

void main() {
  sqfliteFfiInit();

  WorkoutSet set(double kg, int reps, {SetType type = SetType.normal, bool done = true, String id = 'barbell_back_squat'}) =>
      WorkoutSet(workoutId: 1, exerciseId: id, order: 0, weightKg: kg, reps: reps, done: done, type: type);

  group('warm-up sets', () {
    final sets = [
      set(40, 10, type: SetType.warmup),
      set(100, 5),
      set(100, 5),
      set(70, 10, type: SetType.drop),
    ];

    test("don't count toward volume or the best set; drop sets do", () {
      expect(WorkoutMath.volume(sets), 100 * 5 * 2 + 70 * 10);
      // A heavy "warm-up" never becomes the best set
      final withHeavyWarmup = [...sets, set(200, 1, type: SetType.warmup)];
      expect(WorkoutMath.bestByExercise(withHeavyWarmup)['barbell_back_squat'],
          WorkoutMath.estimated1RM(100, 5));
    });

    test("don't count as weekly hard sets", () {
      final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());
      final weekly = MuscleVolume.weeklySets(sets, catalog);
      expect(weekly[Muscle.quads], 3);
    });

    test('labels: warm-ups are W and not numbered, drop sets are D', () {
      expect([for (var i = 0; i < sets.length; i++) WorkoutMath.setTag(sets, i)], ['W', '1', '2', 'D']);
      expect(WorkoutMath.rpeText(8), '8');
      expect(WorkoutMath.rpeText(8.5), '8.5');
    });

    test('type and effort survive a save', () {
      final s = set(60, 8, type: SetType.drop).copyWith(rpe: 9.5);
      final back = WorkoutSet.fromMap({...s.toMap(), 'id': 3});
      expect(back.type, SetType.drop);
      expect(back.rpe, 9.5);
      expect(back.copyWith(clearRpe: true).rpe, isNull);
    });
  });

  test('migration 12 adds set type and effort, keeping old sets as normal', () async {
    final tmp = Directory.systemTemp.createTempSync('sets');
    final path = p.join(tmp.path, 'v11.db');
    final old = await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 11,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE workout_sets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                workout_id INTEGER NOT NULL,
                exercise_id TEXT NOT NULL,
                exercise_order INTEGER NOT NULL,
                weight_kg REAL NOT NULL DEFAULT 0,
                reps INTEGER NOT NULL DEFAULT 0,
                done INTEGER NOT NULL DEFAULT 0
              )
            ''');
            await db.insert('workout_sets', {
              'workout_id': 7, 'exercise_id': 'push_up', 'exercise_order': 0, 'reps': 12, 'done': 1,
            });
          },
        ));
    await old.close();

    final helper = DatabaseHelper.test(databaseFactoryFfi, path);
    final kept = (await helper.getSets(7)).single;
    expect(kept.reps, 12);
    expect(kept.type, SetType.normal);
    expect(kept.rpe, isNull);

    await helper.insertSet(const WorkoutSet(
        workoutId: 7, exerciseId: 'push_up', order: 0, reps: 8, type: SetType.warmup, rpe: 6));
    final both = await helper.getSets(7);
    expect(both.last.type, SetType.warmup);
    expect(both.last.rpe, 6);
    expect(await (await helper.db).getVersion(), DatabaseHelper.schemaVersion);
    await helper.close();
    tmp.deleteSync(recursive: true);
  });

  testWidgets('logger: tap a set number to mark it warm-up and rate its effort', (tester) async {
    setUpAppHarness();
    final semantics = tester.ensureSemantics();
    final app = await launchApp(tester);
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await app.workouts.start();
      await app.workouts.addExercise('push_up');
    });
    await tester.pump();
    await tester.tap(find.text('Resume workout'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel(RegExp('^Set type and effort')).first);
    await tester.pumpAndSettle();
    expect(find.text('Warm-up'), findsOneWidget);
    await tester.tap(find.text('Warm-up'));
    await settle();
    expect(find.textContaining("don't count toward volume"), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '8'));
    await settle();
    expect(app.workouts.setsFor('push_up').single.type, SetType.warmup);
    expect(app.workouts.setsFor('push_up').single.rpe, 8);

    // Close the sheet: the row now reads W with @8
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('W'), findsOneWidget);
    expect(find.text('@8'), findsOneWidget);
    semantics.dispose();
  });
}
