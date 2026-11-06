import 'dart:io';

import 'package:bmi_health/app/router.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/rest_alerts.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/app_harness.dart';

WorkoutSummary _summary(int id, String name, DateTime at, List<(double, int)> sets,
        {String ex = 'barbell_bench_press'}) =>
    WorkoutSummary(
      Workout(id: id, name: name, startedAt: at, finishedAt: at.add(const Duration(hours: 1))),
      [
        for (final (kg, reps) in sets)
          WorkoutSet(workoutId: id, exerciseId: ex, order: 0, weightKg: kg, reps: reps, done: true)
      ],
    );

void main() {
  sqfliteFfiInit();

  test('exercise sessions: best set by estimated 1RM and volume, oldest first', () {
    final history = [
      _summary(2, 'B', DateTime(2026, 11, 5), [(80, 5), (70, 10)]), // newest first
      _summary(1, 'A', DateTime(2026, 11, 1), [(60, 10)]),
      _summary(3, 'C', DateTime(2026, 10, 1), [(20, 10)], ex: 'other'),
    ];
    final s = ExerciseSession.fromHistory(history, 'barbell_bench_press');
    expect(s.map((x) => x.date.day), [1, 5]);
    // 70 × 10 (93.3) beats 80 × 5 (93.3 vs 93.3?) — compute exactly
    final e80 = WorkoutMath.estimated1RM(80, 5), e70 = WorkoutMath.estimated1RM(70, 10);
    expect(s.last.best1RM, e80 > e70 ? e80 : e70);
    expect(s.last.volumeKg, 80 * 5 + 70 * 10);
    expect(s.last.totalReps, 15);
    expect(s.last.maxReps, 10);
    expect(ExerciseSession.fromHistory(history, 'nothing'), isEmpty);
  });

  test('program week: done this week (Monday start), days and the next day', () {
    final p = Programs.all.firstWhere((p) => p.id == 'fullbody_home');
    String name(int day, [String locale = 'en']) =>
        '${p.nameIn(locale)} · ${p.days[day].nameIn(locale)}';
    final now = DateTime(2026, 11, 6, 18); // Friday
    final history = [
      _summary(3, name(0, 'ur'), DateTime(2026, 11, 5), [(0, 10)]),
      _summary(2, 'Something else', DateTime(2026, 11, 4), [(0, 10)]),
      _summary(1, name(1), DateTime(2026, 11, 2, 7), [(0, 10)]), // Monday
      _summary(0, name(0), DateTime(2026, 11, 1), [(0, 10)]), // last week
    ];
    final w = ProgramWeek.of(p, history, now);
    expect(w.done, 2);
    expect(w.target, 3);
    expect(w.doneDays, {0, 1});
    expect(w.nextDay, 1); // after day 0 (the latest)
    expect(w.complete, isFalse);
    expect(ProgramWeek.of(p, const [], now).started, isFalse);
    expect(ProgramWeek.of(p, const [], now).nextDay, 0);
  });

  group('editing finished workouts', () {
    late Directory tmp;
    late DatabaseHelper db;
    late WorkoutProvider w;

    setUp(() async {
      tmp = Directory.systemTemp.createTempSync('wk');
      db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/w.db');
      w = WorkoutProvider(db);
      await w.load();
    });
    tearDown(() async {
      await db.close();
      tmp.deleteSync(recursive: true);
    });

    Future<int> log(List<(double, int)> sets) async {
      await w.start(name: 'A');
      await w.addExercise('barbell_bench_press');
      for (var i = 1; i < sets.length; i++) {
        await w.addSet('barbell_bench_press');
      }
      final rows = w.setsFor('barbell_bench_press');
      for (var i = 0; i < sets.length; i++) {
        await w.updateSet(rows[i].copyWith(weightKg: sets[i].$1, reps: sets[i].$2, done: true));
      }
      return (await w.finish())!.workout.id!;
    }

    test('edit a set: volume and PRs recomputed; rename', () async {
      await log([(60, 10)]);
      final id = await log([(60, 10)]);
      expect(w.summaryOf(id)!.prCount, 0);
      final set = w.summaryOf(id)!.sets.single;
      await w.updateFinishedSet(set.copyWith(weightKg: 70));
      expect(w.summaryOf(id)!.volumeKg, 700);
      expect(w.summaryOf(id)!.prCount, 1); // now beats the first session
      await w.renameWorkout(id, '  Push day ');
      expect(w.summaryOf(id)!.workout.name, 'Push day');
    });

    test('deleting the last set deletes the workout; delete workout', () async {
      final a = await log([(60, 10), (60, 8)]);
      final b = await log([(50, 10)]);
      await w.deleteFinishedSet(w.summaryOf(a)!.sets.first);
      expect(w.summaryOf(a)!.sets, hasLength(1));
      await w.deleteFinishedSet(w.summaryOf(a)!.sets.single);
      expect(w.summaryOf(a), isNull);
      await w.deleteWorkout(b);
      expect(w.history, isEmpty);
    });
  });

  group('screens', () {
    setUpAll(setUpAppHarness);

    Future<void> settleIO(WidgetTester tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> tapAndSave(WidgetTester tester, Finder f) async {
      await tester.runAsync(() async {
        await tester.tap(f);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    }

    Future<int> logBench(AppState app, WidgetTester tester, double kg, int reps) async {
      late int id;
      await tester.runAsync(() async {
        final w = app.workouts;
        await w.start(name: 'Bench day');
        await w.addExercise('barbell_bench_press');
        final s = w.setsFor('barbell_bench_press').single;
        await w.updateSet(s.copyWith(weightKg: kg, reps: reps, done: true));
        id = (await w.finish())!.workout.id!;
      });
      return id;
    }

    testWidgets('rest timer: notification scheduled in background, cancelled on return',
        (tester) async {
      final alerts = RecordingRestAlerts()..isAllowed = false;
      restAlerts = alerts;
      final app = await launchApp(tester);
      await tester.runAsync(() async {
        await app.workouts.start(name: 'A');
        await app.workouts.addExercise('push_up');
        final s = app.workouts.setsFor('push_up').single;
        await app.workouts.updateSet(s.copyWith(reps: 10));
      });
      GoRouter.of(tester.element(find.byType(Scaffold).first)).push(Routes.workout);
      await settleIO(tester);
      await tapAndSave(tester, find.byIcon(Icons.check_circle_outline_rounded));
      await settleIO(tester);
      expect(find.textContaining('Rest'), findsWidgets);
      // First rest, notifications off: offered once
      expect(find.text('Allow'), findsOneWidget);
      await tester.tap(find.text('Allow'));
      expect(alerts.requests, 1);

      final before = DateTime.now();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(alerts.scheduled, hasLength(1));
      final rest = alerts.scheduled.single.difference(before).inSeconds;
      expect(rest, inInclusiveRange(1, 120)); // push-up rest from the catalog
      final cancelsBefore = alerts.cancels;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(alerts.cancels, cancelsBefore + 1);

      // Skipping rest cancels too
      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(alerts.cancels, cancelsBefore + 2);
      expect(alerts.scheduled, hasLength(1));
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pump(const Duration(seconds: 10));
      await settleIO(tester);
    });

    testWidgets('history: open a workout, edit a set, delete the workout', (tester) async {
      final app = await launchApp(tester);
      final id = await logBench(app, tester, 60, 10);
      await tester.tap(find.text('Train'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Bench day'), 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Bench day'));
      await tester.pumpAndSettle();
      expect(find.text('60 kg × 10'), findsOneWidget);
      expect(find.textContaining('Volume 600.0 kg'), findsOneWidget);

      await tester.tap(find.text('60 kg × 10'));
      await tester.pumpAndSettle();
      expect(find.text('Edit set'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('edit-weight')), '65');
      await tapAndSave(tester, find.text('Save'));
      await settleIO(tester);
      await tester.pumpAndSettle();
      expect(find.text('65 kg × 10'), findsOneWidget);
      expect(app.workouts.summaryOf(id)!.volumeKg, 650);

      await tester.tap(find.byTooltip('Delete workout'));
      await tester.pumpAndSettle();
      await tapAndSave(tester, find.text('Delete'));
      await settleIO(tester);
      await tester.pumpAndSettle();
      expect(app.workouts.history, isEmpty);
      expect(find.text('Bench day'), findsNothing);
    });

    testWidgets('exercise detail: progress empty state, then best set', (tester) async {
      final app = await launchApp(tester);
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push(Routes.exercise('barbell_bench_press'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('YOUR PROGRESS'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('Log this exercise'), findsOneWidget);

      await logBench(app, tester, 60, 10);
      await logBench(app, tester, 70, 8);
      await tester.pumpAndSettle();
      expect(find.text('Best: 70 kg × 8'), findsOneWidget);
      expect(find.text('2 sessions'), findsOneWidget);
      expect(find.textContaining('Estimated 1-rep max'), findsOneWidget);
      await tester.tap(find.text('Volume'));
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsNWidgets(2));
    });

    testWidgets('program card: this week and the trained day', (tester) async {
      final app = await launchApp(tester);
      final p = Programs.all.firstWhere((p) => p.id == 'fullbody_home');
      await tester.runAsync(() async {
        final w = app.workouts;
        await w.start(name: '${p.nameIn('en')} · ${p.days[0].nameIn('en')}');
        await w.addExercise('push_up');
        final s = w.setsFor('push_up').single;
        await w.updateSet(s.copyWith(reps: 10, done: true));
        await w.finish();
      });
      await tester.tap(find.text('Train'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('This week 1/3'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('This week 1/3'), findsOneWidget);
    });
  });
}
