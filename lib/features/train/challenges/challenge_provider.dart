import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';

/// Progress through Home Challenges (completed days, unlocks, streak).
class ChallengeProvider extends ChangeNotifier {
  ChallengeProvider(this._db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final DatabaseHelper _db;
  final DateTime Function() _now;
  Map<String, Map<int, DateTime>> _done = {};

  Future<void> load() async {
    _done = await _db.getChallengeProgress();
    notifyListeners();
  }

  Set<int> completedDays(ChallengeFocus f, ChallengeLevel l) =>
      (_done[ChallengePlanner.key(f, l)] ?? const {}).keys.toSet();

  bool isComplete(ChallengeFocus f, ChallengeLevel l) => completedDays(f, l).length >= l.days;

  /// Beginner is always open; each next level opens when the previous one
  /// in the same focus is finished.
  bool isUnlocked(ChallengeFocus f, ChallengeLevel l) =>
      l.previous == null || isComplete(f, l.previous!);

  /// The next day to do (rest days count once you pass them).
  int currentDay(ChallengeFocus f, ChallengeLevel l) {
    final done = completedDays(f, l);
    for (var d = 1; d <= l.days; d++) {
      if (!done.contains(d)) return d;
    }
    return l.days;
  }

  bool started(ChallengeFocus f, ChallengeLevel l) => completedDays(f, l).isNotEmpty;

  /// The challenge the user did most recently (for the Today card).
  ({ChallengeFocus focus, ChallengeLevel level})? get latest {
    String? best;
    DateTime? at;
    _done.forEach((k, days) {
      for (final t in days.values) {
        if (at == null || t.isAfter(at!)) {
          at = t;
          best = k;
        }
      }
    });
    if (best == null) return null;
    final parts = best!.split('_');
    final f = ChallengeFocus.values.asNameMap()[parts.first];
    final l = ChallengeLevel.values.asNameMap()[parts.last];
    if (f == null || l == null || isComplete(f, l)) return null;
    return (focus: f, level: l);
  }

  /// When each challenge day was completed (for the daily streak).
  Iterable<DateTime> get completionDates sync* {
    for (final m in _done.values) {
      yield* m.values;
    }
  }

  /// Whether a challenge day was completed today.
  bool get doneToday {
    final n = _now();
    return _done.values.any((m) => m.values.any((t) => t.year == n.year && t.month == n.month && t.day == n.day));
  }

  /// Consecutive calendar days (ending today or yesterday) with at least
  /// one challenge day completed.
  int get streak {
    final days = <DateTime>{
      for (final m in _done.values)
        for (final t in m.values) DateTime(t.year, t.month, t.day)
    };
    final n = _now();
    var d = DateTime(n.year, n.month, n.day);
    if (!days.contains(d)) d = d.subtract(const Duration(days: 1));
    var s = 0;
    while (days.contains(d)) {
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  /// Marks [day] done; rest days before it are marked too.
  Future<void> completeDay(ChallengeFocus f, ChallengeLevel l, int day) async {
    final key = ChallengePlanner.key(f, l);
    final now = _now();
    for (var d = 1; d < day; d++) {
      if (f.hasRestDays && d % 7 == 0 && !completedDays(f, l).contains(d)) {
        await _db.completeChallengeDay(key, d, now);
      }
    }
    await _db.completeChallengeDay(key, day, now);
    await load();
  }

  /// Rest days are "done" by tapping them.
  Future<void> completeRestDay(ChallengeFocus f, ChallengeLevel l, int day) =>
      completeDay(f, l, day);

  Future<void> restart(ChallengeFocus f, ChallengeLevel l) async {
    await _db.resetChallenge(ChallengePlanner.key(f, l));
    await load();
  }
}
