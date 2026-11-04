import 'package:bmi_health/features/progress/domain/achievements.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime d(int month, int day, [int h = 18]) => DateTime(2026, month, day, h);

WorkoutSummary w(DateTime start, {int minutes = 50, int sets = 3, double kg = 50, int prs = 0}) =>
    WorkoutSummary(
      Workout(id: start.day, startedAt: start, finishedAt: start.add(Duration(minutes: minutes))),
      [
        for (var i = 0; i < sets; i++)
          WorkoutSet(workoutId: start.day, exerciseId: 'x', order: 0, weightKg: kg, reps: 10, done: true)
      ],
      prCount: prs,
    );

void main() {
  // Wed 4 Nov 2026; weeks start Monday 2 Nov, 26 Oct, 19 Oct, 12 Oct
  final now = d(11, 4);

  group('week streak', () {
    test('counts consecutive weeks that hit the goal', () {
      final days = [d(10, 13), d(10, 15), d(10, 20), d(10, 22), d(10, 27), d(10, 29)];
      expect(Streaks.weeks(days, 2, now), 3); // this week not done yet, not broken
    });

    test('the current week adds once the goal is met', () {
      final days = [d(10, 27), d(10, 29), d(11, 2), d(11, 3)];
      expect(Streaks.weeks(days, 2, now), 2);
    });

    test('a missed week breaks it', () {
      final days = [d(10, 13), d(10, 15), d(10, 27), d(10, 29)]; // nothing week of 19 Oct
      expect(Streaks.weeks(days, 2, now), 1);
    });

    test('nothing logged → 0', () {
      expect(Streaks.weeks(const [], 3, now), 0);
    });
  });

  test('best day streak', () {
    expect(Streaks.bestDays([d(10, 1), d(10, 2), d(10, 2, 9), d(10, 3), d(10, 5)]), 3);
    expect(Streaks.bestDays(const []), 0);
  });

  test('badges: earned and progress', () {
    final b = {
      for (final x in Achievements.evaluate(
          workouts: 12, bestWeekStreak: 2, prs: 1, totalVolumeKg: 500, bestStepsDay: 12000))
        x.badge: x
    };
    expect(b[Achievement.workouts10]!.earned, isTrue);
    expect(b[Achievement.workouts50]!.progress, closeTo(0.24, 0.001));
    expect(b[Achievement.streak4]!.earned, isFalse);
    expect(b[Achievement.firstPr]!.earned, isTrue);
    expect(b[Achievement.ton]!.progress, 0.5);
    expect(b[Achievement.steps10k]!.earned, isTrue);
  });

  test('recap totals only the period; ignores forgotten open workouts', () {
    final history = [
      w(d(9, 30), prs: 1), // before October
      w(d(10, 2), sets: 4, kg: 60, prs: 2),
      w(d(10, 9), minutes: 600), // left running 10 h
      w(d(11, 1)), // after
    ];
    final r = Recap.of(history, DateTime(2026, 10), DateTime(2026, 11),
        distanceKm: 84.2,
        weights: [(date: d(10, 1), kg: 80.0), (date: d(10, 30), kg: 78.5)]);
    expect(r.workouts, 2);
    expect(r.sets, 7);
    expect(r.volumeKg, 4 * 600 + 3 * 500);
    expect(r.prs, 2);
    expect(r.trainingTime, const Duration(minutes: 50));
    expect(r.weightChangeKg, -1.5);
    expect(r.isEmpty, isFalse);
  });

  test('empty month is empty', () {
    expect(Recap.of(const [], DateTime(2026, 10), DateTime(2026, 11)).isEmpty, isTrue);
  });
}
