/// The daily habit loop on the Today screen: four goals and a streak of
/// active days.
abstract final class DailyStreak {
  /// Calendar days of [times].
  static Set<DateTime> days(Iterable<DateTime> times) =>
      {for (final t in times) DateTime(t.year, t.month, t.day)};

  /// Days in a row with activity, ending today — or yesterday, so the streak
  /// isn't shown as lost before the user has had a chance to act today.
  static int count(Set<DateTime> activeDays, DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (!activeDays.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
    var n = 0;
    while (activeDays.contains(day)) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }
}

/// Progress 0..1 toward each of today's goals.
class DailyGoals {
  /// Null when steps aren't connected; then the other three decide a
  /// perfect day.
  final double? move;
  final double train;
  final double eat;
  final double water;
  const DailyGoals({required this.move, required this.train, required this.eat, required this.water});

  /// Eating within 85 % of the calorie target counts as on track.
  static const eatOnTrack = 0.85;

  static double ratio(num value, num goal) => goal <= 0 ? 0 : (value / goal).clamp(0, 1).toDouble();

  factory DailyGoals.from({
    required int? steps,
    required int stepGoal,
    required bool trained,
    required int kcal,
    required int kcalTarget,
    required int waterMl,
    required int waterGoal,
  }) =>
      DailyGoals(
        move: steps == null ? null : ratio(steps, stepGoal),
        train: trained ? 1 : 0,
        eat: ratio(kcal, kcalTarget * eatOnTrack),
        water: ratio(waterMl, waterGoal),
      );

  List<double> get _counted => [if (move case final m?) m, train, eat, water];
  int get completed => _counted.where((v) => v >= 1).length;
  bool get perfect => completed == _counted.length;
}
