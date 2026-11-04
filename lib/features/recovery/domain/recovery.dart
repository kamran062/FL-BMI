import 'dart:math' as math;

/// One night of sleep.
class SleepNight {
  final DateTime start;
  final DateTime end;
  const SleepNight(this.start, this.end);

  Duration get duration => end.difference(start);

  /// Night it belongs to: the date the user woke up.
  DateTime get wakeDay => DateTime(end.year, end.month, end.day);
}

/// Inputs for one day's recovery score. Any of them may be missing
/// (no wearable, no check-in); the score uses what is there.
class RecoveryInputs {
  /// Last night's sleep in hours.
  final double? sleepHours;

  /// Resting heart rate today and its 14-day average (bpm).
  final double? restingHr;
  final double? restingHrBaseline;

  /// Heart-rate variability today and its 14-day average (ms).
  final double? hrv;
  final double? hrvBaseline;

  /// Hard sets in the last 2 days vs. the average 2-day load over 4 weeks.
  final double recentSets;
  final double usualSets;

  /// Soreness check-in: 1 (none) … 5 (very sore).
  final int? soreness;

  const RecoveryInputs({
    this.sleepHours,
    this.restingHr,
    this.restingHrBaseline,
    this.hrv,
    this.hrvBaseline,
    this.recentSets = 0,
    this.usualSets = 0,
    this.soreness,
  });
}

enum TrainingAdvice { trainHard, trainLight, rest }

class RecoveryScore {
  final int score; // 0–100
  final TrainingAdvice advice;

  /// Which inputs were used (so the UI can say "based on sleep and check-in").
  final Set<RecoveryFactor> used;

  /// Biggest drag on today's score, if any is clearly low.
  final RecoveryFactor? limiter;

  const RecoveryScore(this.score, this.advice, this.used, this.limiter);
}

enum RecoveryFactor { sleep, restingHr, hrv, load, soreness }

/// Daily 0–100 recovery score (ROADMAP 4.1).
///
/// Each available factor gives a 0–1 sub-score; the total is their
/// weighted average, re-weighted over the factors that are present, so a
/// user without a watch still gets a score from sleep, load and check-in.
abstract final class Recovery {
  static const _weights = {
    RecoveryFactor.sleep: 0.30,
    RecoveryFactor.hrv: 0.25,
    RecoveryFactor.restingHr: 0.15,
    RecoveryFactor.load: 0.15,
    RecoveryFactor.soreness: 0.15,
  };

  /// Returns null when there is nothing at all to go on.
  static RecoveryScore? compute(RecoveryInputs i) {
    final parts = <RecoveryFactor, double>{};

    if (i.sleepHours != null) {
      // 8 h+ = full marks, falling to 0 at 4 h.
      parts[RecoveryFactor.sleep] = ((i.sleepHours! - 4) / 4).clamp(0.0, 1.0);
    }
    if (i.restingHr != null && (i.restingHrBaseline ?? 0) > 0) {
      // Each bpm above baseline costs 10 %; below baseline is fine.
      final over = i.restingHr! - i.restingHrBaseline!;
      parts[RecoveryFactor.restingHr] = (1 - over / 10).clamp(0.0, 1.0);
    }
    if (i.hrv != null && (i.hrvBaseline ?? 0) > 0) {
      // At or above baseline = full; 30 % below = 0.
      final ratio = i.hrv! / i.hrvBaseline!;
      parts[RecoveryFactor.hrv] = ((ratio - 0.7) / 0.3).clamp(0.0, 1.0);
    }
    if (i.usualSets > 0 || i.recentSets > 0) {
      // Acute vs. usual load; 1.5× usual or more = heavy.
      final ratio = i.usualSets == 0 ? 2.0 : i.recentSets / i.usualSets;
      parts[RecoveryFactor.load] = (1 - (ratio - 1) / 1).clamp(0.0, 1.0);
    }
    if (i.soreness != null) {
      parts[RecoveryFactor.soreness] = ((5 - i.soreness!) / 4).clamp(0.0, 1.0);
    }
    if (parts.isEmpty) return null;

    var total = 0.0, weight = 0.0;
    parts.forEach((f, v) {
      total += v * _weights[f]!;
      weight += _weights[f]!;
    });
    final score = (total / weight * 100).round();

    // A single very bad sign (e.g. illness: HR way up) caps the score,
    // so good sleep can't hide it.
    final worst = parts.entries.reduce((a, b) => a.value <= b.value ? a : b);
    final capped = worst.value < 0.2 ? math.min(score, 40) : score;

    final advice = capped >= 70
        ? TrainingAdvice.trainHard
        : capped >= 45
            ? TrainingAdvice.trainLight
            : TrainingAdvice.rest;
    return RecoveryScore(
      capped,
      advice,
      parts.keys.toSet(),
      worst.value < 0.5 ? worst.key : null,
    );
  }
}

/// Sleep summary over recent nights (ROADMAP 4.2).
class SleepSummary {
  final Duration average;

  /// Spread of bedtimes (standard deviation); lower is more regular.
  final Duration bedtimeSpread;
  final int nights;

  /// Sleep debt vs. [goal] over the period.
  final Duration debt;

  const SleepSummary(this.average, this.bedtimeSpread, this.nights, this.debt);

  bool get regular => bedtimeSpread <= const Duration(minutes: 45);

  static SleepSummary? of(List<SleepNight> nights,
      {Duration goal = const Duration(hours: 8)}) {
    if (nights.isEmpty) return null;
    final total = nights.fold(Duration.zero, (s, n) => s + n.duration);
    final avg = total ~/ nights.length;

    // Bedtime as minutes from 18:00 so 23:30 and 00:30 are close.
    double mins(DateTime t) => ((t.hour * 60 + t.minute - 18 * 60) % 1440).toDouble();
    final m = nights.map((n) => mins(n.start)).toList();
    final mean = m.reduce((a, b) => a + b) / m.length;
    final variance =
        m.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / m.length;

    var debt = Duration.zero;
    for (final n in nights) {
      if (n.duration < goal) debt += goal - n.duration;
    }
    return SleepSummary(
      avg,
      Duration(minutes: math.sqrt(variance).round()),
      nights.length,
      debt,
    );
  }

  /// Merges overlapping/adjacent sleep segments (watches report several per
  /// night) into nights keyed by wake-up day.
  static List<SleepNight> mergeSegments(List<SleepNight> segments) {
    final sorted = [...segments]..sort((a, b) => a.start.compareTo(b.start));
    final out = <SleepNight>[];
    for (final s in sorted) {
      if (out.isNotEmpty &&
          s.start.difference(out.last.end) <= const Duration(hours: 1)) {
        final last = out.removeLast();
        out.add(SleepNight(last.start, s.end.isAfter(last.end) ? s.end : last.end));
      } else {
        out.add(s);
      }
    }
    // Ignore naps (< 3 h) for nightly stats.
    return out.where((n) => n.duration >= const Duration(hours: 3)).toList();
  }
}
