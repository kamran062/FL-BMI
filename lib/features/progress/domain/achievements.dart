import 'package:bmi_health/features/train/workouts/domain/workout.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Monday of the week containing [d].
DateTime weekStart(DateTime d) => _day(d).subtract(Duration(days: d.weekday - 1));

/// Streaks (ROADMAP 5.2). A week "counts" when it reaches [weeklyGoal]
/// workouts. The current week never breaks a streak while it is still
/// running — it only adds to it once the goal is met.
abstract final class Streaks {
  static int weeks(List<DateTime> workoutDays, int weeklyGoal, DateTime now) {
    if (weeklyGoal < 1) return 0;
    final perWeek = <DateTime, int>{};
    for (final d in workoutDays) {
      final w = weekStart(d);
      perWeek[w] = (perWeek[w] ?? 0) + 1;
    }
    final thisWeek = weekStart(now);
    var streak = (perWeek[thisWeek] ?? 0) >= weeklyGoal ? 1 : 0;
    var w = thisWeek.subtract(const Duration(days: 7));
    while ((perWeek[w] ?? 0) >= weeklyGoal) {
      streak++;
      w = w.subtract(const Duration(days: 7));
    }
    return streak;
  }

  /// Longest run of consecutive days with at least one workout.
  static int bestDays(List<DateTime> workoutDays) {
    final days = workoutDays.map(_day).toSet().toList()..sort();
    var best = 0, run = 0;
    for (var i = 0; i < days.length; i++) {
      run = i > 0 && days[i].difference(days[i - 1]).inDays == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }
    return best;
  }
}

enum Achievement {
  firstWorkout, workouts10, workouts50, workouts100,
  streak4, streak12, firstPr, prs10, ton, steps10k,
}

class AchievementProgress {
  final Achievement badge;
  final bool earned;

  /// 0–1 towards earning it.
  final double progress;
  const AchievementProgress(this.badge, this.earned, this.progress);
}

abstract final class Achievements {
  static List<AchievementProgress> evaluate({
    required int workouts,
    required int bestWeekStreak,
    required int prs,
    required double totalVolumeKg,
    required int bestStepsDay,
  }) {
    AchievementProgress at(Achievement b, num value, num target) =>
        AchievementProgress(b, value >= target, (value / target).clamp(0.0, 1.0).toDouble());
    return [
      at(Achievement.firstWorkout, workouts, 1),
      at(Achievement.workouts10, workouts, 10),
      at(Achievement.workouts50, workouts, 50),
      at(Achievement.workouts100, workouts, 100),
      at(Achievement.streak4, bestWeekStreak, 4),
      at(Achievement.streak12, bestWeekStreak, 12),
      at(Achievement.firstPr, prs, 1),
      at(Achievement.prs10, prs, 10),
      // 1,000 kg lifted in total (a "ton")
      at(Achievement.ton, totalVolumeKg, 1000),
      at(Achievement.steps10k, bestStepsDay, 10000),
    ];
  }
}

/// Totals for a period (ROADMAP 5.1). No locations — safe to share.
class Recap {
  final DateTime from;
  final DateTime to;
  final int workouts;
  final int sets;
  final double volumeKg;
  final int prs;
  final Duration trainingTime;
  final double? distanceKm;
  final Duration? gymTime;
  final double? weightChangeKg;

  const Recap({
    required this.from,
    required this.to,
    required this.workouts,
    required this.sets,
    required this.volumeKg,
    required this.prs,
    required this.trainingTime,
    this.distanceKm,
    this.gymTime,
    this.weightChangeKg,
  });

  bool get isEmpty =>
      workouts == 0 && (distanceKm ?? 0) < 0.1 && weightChangeKg == null;

  static Recap of(
    List<WorkoutSummary> history,
    DateTime from,
    DateTime to, {
    double? distanceKm,
    Duration? gymTime,
    List<({DateTime date, double kg})> weights = const [],
  }) {
    final inRange = history.where((h) =>
        !h.workout.startedAt.isBefore(from) && h.workout.startedAt.isBefore(to));
    var time = Duration.zero;
    for (final h in inRange) {
      final end = h.workout.finishedAt;
      // Ignore forgotten workouts left open for hours.
      if (end != null && end.difference(h.workout.startedAt) < const Duration(hours: 4)) {
        time += end.difference(h.workout.startedAt);
      }
    }
    final w = weights.where((x) => !x.date.isBefore(from) && x.date.isBefore(to)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return Recap(
      from: from,
      to: to,
      workouts: inRange.length,
      sets: inRange.fold(0, (s, h) => s + h.doneSets.length),
      volumeKg: inRange.fold(0.0, (s, h) => s + h.volumeKg),
      prs: inRange.fold(0, (s, h) => s + h.prCount),
      trainingTime: time,
      distanceKm: distanceKm,
      gymTime: gymTime,
      weightChangeKg: w.length < 2 ? null : w.last.kg - w.first.kg,
    );
  }
}
