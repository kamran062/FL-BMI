import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/today/domain/daily_goals.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/muscle_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  group('DailyStreak', () {
    final now = DateTime(2026, 11, 20, 18);
    DateTime d(int daysAgo) => DateTime(2026, 11, 20 - daysAgo, 9);

    test('counts days in a row ending today', () {
      expect(DailyStreak.count(DailyStreak.days([d(0), d(1), d(2), d(4)]), now), 3);
    });

    test("today not logged yet: yesterday's streak is still alive", () {
      expect(DailyStreak.count(DailyStreak.days([d(1), d(2)]), now), 2);
    });

    test('a missed day breaks it', () {
      expect(DailyStreak.count(DailyStreak.days([d(2), d(3)]), now), 0);
      expect(DailyStreak.count({}, now), 0);
    });

    test('several entries on one day count once; across month ends', () {
      final days = DailyStreak.days([DateTime(2026, 12, 1, 8), DateTime(2026, 12, 1, 20), DateTime(2026, 11, 30, 7)]);
      expect(DailyStreak.count(days, DateTime(2026, 12, 1, 22)), 2);
    });
  });

  group('DailyGoals', () {
    DailyGoals goals({int? steps = 9000, bool trained = true, int kcal = 1800, int water = 2500}) =>
        DailyGoals.from(
          steps: steps,
          stepGoal: 8000,
          trained: trained,
          kcal: kcal,
          kcalTarget: 2000,
          waterMl: water,
          waterGoal: 2500,
        );

    test('perfect when every goal is met; eating 85% of target is on track', () {
      expect(goals().perfect, isTrue);
      expect(goals(kcal: 1700).eat, 1.0);
      expect(goals(kcal: 1000).eat, lessThan(1));
    });

    test('counts completed goals', () {
      final g = goals(trained: false, water: 1000);
      expect(g.completed, 2);
      expect(g.perfect, isFalse);
    });

    test("steps not connected don't block a perfect day", () {
      final g = goals(steps: null);
      expect(g.move, isNull);
      expect(g.perfect, isTrue);
      expect(g.completed, 3);
    });
  });

  test('gym day suggestion: the main muscles trained least this week', () {
    expect(MuscleDay.suggested({}), MuscleDay.chest);
    expect(
      MuscleDay.suggested({
        Muscle.chest: 8, Muscle.back: 8, Muscle.shoulders: 6, Muscle.biceps: 4, Muscle.triceps: 4,
        Muscle.quads: 1, Muscle.hamstrings: 1, Muscle.glutes: 1, Muscle.calves: 0,
      }),
      MuscleDay.legs,
    );
  });

  group('Today screen', () {
    setUpAll(setUpAppHarness);

    testWidgets('new user: four goals, a 30-day home plan, quick add', (tester) async {
      final app = await launchApp(tester);
      expect(find.text("TODAY'S GOALS"), findsOneWidget);
      for (final g in ['Move', 'Eat', 'Water']) {
        expect(find.text(g), findsOneWidget);
      }
      expect(find.text('Start your 30-day plan'), findsOneWidget);
      final focus = ChallengePlanner.orderedFor(app.profile.profile).first;
      expect(focus, isNotNull);

      // +250 ml fills the Water ring and starts today's streak
      await tester.ensureVisible(find.text('+250 ml'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+250 ml'));
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(app.fuel.waterMl, 250);
      // Back to the top: the Water ring and the streak chip
      await tester.drag(find.byType(CustomScrollView).first, const Offset(0, 2000));
      await tester.pumpAndSettle();
      expect(find.text('0.3 L'), findsOneWidget);
      expect(find.bySemanticsLabel('1-day streak'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // snackbar
    });

    testWidgets('gym user: today plan is a muscle day for the least-trained muscles', (tester) async {
      final app = await launchApp(tester);
      await tester.runAsync(() => app.profile.update(app.profile.profile.copyWith(equipment: Equipment.gym)));
      await tester.pumpAndSettle();
      expect(find.text('Chest workout'), findsOneWidget);
      expect(find.text('Your least-trained muscles this week'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Start this workout'), findsOneWidget); // the plan sheet
    });

    testWidgets('a challenge in progress: today is its next day', (tester) async {
      final app = await launchApp(tester);
      await tester.runAsync(() => app.challenges.completeDay(ChallengeFocus.coreAbs, ChallengeLevel.beginner, 1));
      await tester.pumpAndSettle();
      // Done today, so the plan card congratulates instead
      expect(find.text('Done for today'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget); // Train ring
    });
  });
}
