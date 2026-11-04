/// A logged period (ROADMAP 4.3). [end] is null while it is ongoing.
class Period {
  final int? id;
  final DateTime start;
  final DateTime? end;

  const Period({this.id, required this.start, this.end});

  int lengthDays(DateTime today) =>
      ((end ?? today).difference(start).inDays + 1).clamp(1, 15);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'start': _d(start),
        'end': end == null ? null : _d(end!),
      };

  factory Period.fromMap(Map<String, dynamic> m) => Period(
        id: m['id'] as int?,
        start: DateTime.parse(m['start'] as String),
        end: m['end'] == null ? null : DateTime.parse(m['end'] as String),
      );

  static String _d(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

enum CyclePhase { menstrual, follicular, ovulation, luteal }

enum Symptom { cramps, headache, bloating, fatigue, lowMood, acne, cravings, tenderBreasts }

class CycleStatus {
  /// Day of the current cycle (1 = first day of the last period).
  final int day;
  final CyclePhase phase;
  final DateTime nextPeriod;

  /// Earliest/latest likely start, wider when cycles are irregular.
  final DateTime nextEarliest;
  final DateTime nextLatest;
  final int cycleLength;
  final bool irregular;

  /// Past the latest likely start.
  final bool late;

  const CycleStatus({
    required this.day,
    required this.phase,
    required this.nextPeriod,
    required this.nextEarliest,
    required this.nextLatest,
    required this.cycleLength,
    required this.irregular,
    required this.late,
  });

  int daysUntilNext(DateTime today) => nextPeriod.difference(_day(today)).inDays;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

abstract final class CyclePredictor {
  static const defaultCycle = 28;
  static const defaultPeriod = 5;

  /// Lengths between consecutive period starts, newest last. Gaps outside
  /// 15–90 days are ignored (a missed log, not a real cycle).
  static List<int> cycleLengths(List<Period> periods) {
    final s = [...periods]..sort((a, b) => a.start.compareTo(b.start));
    return [
      for (var i = 1; i < s.length; i++)
        if (s[i].start.difference(s[i - 1].start).inDays case final d
            when d >= 15 && d <= 90)
          d
    ];
  }

  static int _median(List<int> v) {
    final s = [...v]..sort();
    final m = s.length ~/ 2;
    return s.length.isOdd ? s[m] : ((s[m - 1] + s[m]) / 2).round();
  }

  /// Null until at least one period is logged.
  static CycleStatus? status(List<Period> periods, DateTime now) {
    if (periods.isEmpty) return null;
    final today = _day(now);
    final sorted = [...periods]..sort((a, b) => a.start.compareTo(b.start));
    final last = sorted.last;

    // Median of the last 6 cycles resists one odd month.
    final lengths = cycleLengths(sorted);
    final recent = lengths.length > 6 ? lengths.sublist(lengths.length - 6) : lengths;
    final cycle = recent.isEmpty ? defaultCycle : _median(recent);
    // A gap near double the usual length is almost always a missed log;
    // leave it out of the spread so one forgotten entry isn't "irregular".
    final typical = recent.where((l) => l <= cycle * 1.6).toList();
    final spread = typical.length < 2
        ? 3 // little history: a few days either way
        : (typical.reduce((a, b) => a > b ? a : b) - typical.reduce((a, b) => a < b ? a : b));
    final irregular = spread > 7;
    final margin = (spread / 2).ceil().clamp(2, 10);

    final periodLen = sorted.where((p) => p.end != null).isEmpty
        ? defaultPeriod
        : _median([for (final p in sorted.where((p) => p.end != null)) p.lengthDays(today)]);

    final day = today.difference(_day(last.start)).inDays + 1;
    final next = _day(last.start).add(Duration(days: cycle));
    final latest = next.add(Duration(days: margin));

    // Ovulation ≈ 14 days before the next period.
    final ovulation = cycle - 14;
    final ongoing = last.end == null && day <= 10;
    final phase = (ongoing || day <= periodLen)
        ? CyclePhase.menstrual
        : day < ovulation - 1
            ? CyclePhase.follicular
            : day <= ovulation + 1
                ? CyclePhase.ovulation
                : CyclePhase.luteal;

    return CycleStatus(
      day: day,
      phase: phase,
      nextPeriod: next,
      nextEarliest: next.subtract(Duration(days: margin)),
      nextLatest: latest,
      cycleLength: cycle,
      irregular: irregular,
      late: today.isAfter(latest),
    );
  }
}
