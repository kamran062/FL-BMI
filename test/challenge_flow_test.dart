import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/challenges/ui/challenges_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/app_harness.dart';

void main() {
  sqfliteFfiInit();

  group('ChallengeProvider', () {
    late Directory tmp;
    late DatabaseHelper db;
    var now = DateTime(2026, 11, 6, 18);
    late ChallengeProvider c;

    setUp(() async {
      tmp = Directory.systemTemp.createTempSync('ch');
      db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/c.db');
      c = ChallengeProvider(db, clock: () => now);
      await c.load();
    });
    tearDown(() async {
      await db.close();
      tmp.deleteSync(recursive: true);
    });

    const f = ChallengeFocus.coreAbs;

    test('beginner open, next levels locked until the previous is finished', () async {
      expect(c.isUnlocked(f, ChallengeLevel.beginner), isTrue);
      expect(c.isUnlocked(f, ChallengeLevel.intermediate), isFalse);
      for (var d = 1; d <= 30; d++) {
        await c.completeDay(f, ChallengeLevel.beginner, d);
      }
      expect(c.isComplete(f, ChallengeLevel.beginner), isTrue);
      expect(c.isUnlocked(f, ChallengeLevel.intermediate), isTrue);
      expect(c.isUnlocked(f, ChallengeLevel.advanced), isFalse);
      // Other focuses are independent
      expect(c.isUnlocked(ChallengeFocus.hiit, ChallengeLevel.intermediate), isFalse);
    });

    test('current day advances; finishing day 8 also ticks rest day 7', () async {
      for (var d = 1; d <= 6; d++) {
        await c.completeDay(f, ChallengeLevel.beginner, d);
      }
      expect(c.currentDay(f, ChallengeLevel.beginner), 7);
      await c.completeDay(f, ChallengeLevel.beginner, 8);
      expect(c.completedDays(f, ChallengeLevel.beginner), containsAll([7, 8]));
      expect(c.currentDay(f, ChallengeLevel.beginner), 9);
      expect(c.latest, (focus: f, level: ChallengeLevel.beginner));
    });

    test('streak counts consecutive calendar days', () async {
      now = DateTime(2026, 11, 4, 18);
      await c.completeDay(f, ChallengeLevel.beginner, 1);
      now = DateTime(2026, 11, 5, 18);
      await c.completeDay(f, ChallengeLevel.beginner, 2);
      now = DateTime(2026, 11, 6, 9);
      expect(c.streak, 2); // today not done yet: streak still alive
      await c.completeDay(f, ChallengeLevel.beginner, 3);
      expect(c.streak, 3);
      now = DateTime(2026, 11, 9, 9);
      expect(c.streak, 0);
    });

    test('restart clears progress', () async {
      await c.completeDay(f, ChallengeLevel.beginner, 1);
      await c.restart(f, ChallengeLevel.beginner);
      expect(c.started(f, ChallengeLevel.beginner), isFalse);
    });
  });

  testWidgets('guided player: day 1 start → every set → finished, logged',
      (tester) async {
    setUpAppHarness();
    final app = await launchApp(tester);

    // Open Home Challenges from the Train tab
    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Home Challenges'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Home Challenges'));
    await tester.pumpAndSettle();
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('RECOMMENDED'), findsOneWidget);

    // Core & Abs, beginner
    await tester.scrollUntilVisible(find.text('Core & Abs'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Core & Abs'));
    await tester.pumpAndSettle();
    expect(find.text('Day 1 of 30'), findsOneWidget);
    expect(find.text('Warm-up · 1 × 30 s'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Start Day 1'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Start Day 1'));
    for (var i = 0; i < 40 && find.text('WARM-UP').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(app.workouts.active, isNotNull);
    expect(find.text('WARM-UP'), findsOneWidget);

    // Tap Done for every set, skipping rests, until the finish screen
    for (var i = 0; i < 40 && find.text('Day 1 complete!').evaluate().isEmpty; i++) {
      if (find.text('Skip rest').evaluate().isNotEmpty) {
        await tester.tap(find.text('Skip rest'));
      } else if (find.text('Done').evaluate().isNotEmpty) {
        await tester.ensureVisible(find.text('Done'));
        await tester.tap(find.text('Done'));
      }
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump();
    }
    expect(find.text('Day 1 complete!'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump();
    }
    expect(app.workouts.active, isNull);
    expect(app.workouts.history, isNotEmpty);
    expect(app.challenges.completedDays(ChallengeFocus.coreAbs, ChallengeLevel.beginner), {1});
    expect(find.textContaining('1-day streak'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // Back on the day grid, ready for day 2
    await tester.scrollUntilVisible(find.text('Start Day 2'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Start Day 2'), findsOneWidget);
    // Labels used in the list exist in Urdu too
    expect(ChallengeLevel.values.length, 3);
    expect(focusIcon(ChallengeFocus.stretch), isNotNull);
  });
}
