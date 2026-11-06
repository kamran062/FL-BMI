import 'package:shared_preferences/shared_preferences.dart';

enum ReminderKind { daily, weekly, water, weighIn, workout, bedtime }

/// One scheduled notification: daily at [hour]:[minute], or weekly on
/// [weekday] (DateTime.monday … DateTime.sunday).
typedef ReminderSlot = ({int id, ReminderKind kind, int hour, int minute, int? weekday});

/// Which reminders are on and when. Times are minutes after midnight.
class ReminderSettings {
  final bool daily;
  final int dailyAt;
  final bool weekly;
  final int weeklyDay;
  final int weeklyAt;
  final bool water;
  final int waterEveryHours;
  final int waterFrom;
  final int waterTo;
  final bool weighIn;
  final int weighInDay;
  final int weighInAt;
  final bool workout;

  /// null → not chosen yet; the profile's days per week decide.
  final Set<int>? workoutDays;
  final int workoutAt;
  final bool bedtime;
  final int bedtimeAt;

  const ReminderSettings({
    this.daily = false,
    this.dailyAt = 20 * 60,
    this.weekly = false,
    this.weeklyDay = DateTime.sunday,
    this.weeklyAt = 10 * 60,
    this.water = false,
    this.waterEveryHours = 2,
    this.waterFrom = 9 * 60,
    this.waterTo = 21 * 60,
    this.weighIn = false,
    this.weighInDay = DateTime.monday,
    this.weighInAt = 7 * 60 + 30,
    this.workout = false,
    this.workoutDays,
    this.workoutAt = 18 * 60,
    this.bedtime = false,
    this.bedtimeAt = 22 * 60 + 30,
  });

  static const waterIntervals = [1, 2, 3, 4];

  // Notification ids. 10 is the gym check-in (MovementProvider).
  static const _dailyId = 1, _weeklyId = 2, _weighInId = 3, _bedtimeId = 4;
  static const _waterBase = 100, _workoutBase = 200;

  /// Every id this class may schedule, so stale ones can be cancelled.
  static final allIds = [
    _dailyId, _weeklyId, _weighInId, _bedtimeId,
    for (var i = 0; i < 24; i++) _waterBase + i,
    for (var d = 1; d <= 7; d++) _workoutBase + d,
  ];

  /// Training days spread over the week for [perWeek] sessions.
  static Set<int> defaultWorkoutDays(int perWeek) => switch (perWeek.clamp(1, 7)) {
        1 => {DateTime.monday},
        2 => {DateTime.monday, DateTime.thursday},
        3 => {DateTime.monday, DateTime.wednesday, DateTime.friday},
        4 => {DateTime.monday, DateTime.tuesday, DateTime.thursday, DateTime.friday},
        5 => {for (var d = 1; d <= 5; d++) d},
        6 => {for (var d = 1; d <= 6; d++) d},
        _ => {for (var d = 1; d <= 7; d++) d},
      };

  /// Water reminder times within the waking window.
  List<int> get waterTimes {
    final step = waterEveryHours.clamp(1, 12) * 60;
    return [for (var t = waterFrom; t <= waterTo && t < 24 * 60; t += step) t];
  }

  /// What to schedule. [perWeek] fills in workout days when none are chosen.
  List<ReminderSlot> slots({int perWeek = 3}) {
    ReminderSlot at(int id, ReminderKind k, int minutes, [int? weekday]) =>
        (id: id, kind: k, hour: minutes ~/ 60, minute: minutes % 60, weekday: weekday);
    return [
      if (daily) at(_dailyId, ReminderKind.daily, dailyAt),
      if (weekly) at(_weeklyId, ReminderKind.weekly, weeklyAt, weeklyDay),
      if (water)
        for (final (i, t) in waterTimes.take(24).indexed)
          at(_waterBase + i, ReminderKind.water, t),
      if (weighIn) at(_weighInId, ReminderKind.weighIn, weighInAt, weighInDay),
      if (workout)
        for (final d in (workoutDays ?? defaultWorkoutDays(perWeek)).toList()..sort())
          at(_workoutBase + d, ReminderKind.workout, workoutAt, d),
      if (bedtime) at(_bedtimeId, ReminderKind.bedtime, bedtimeAt),
    ];
  }

  ReminderSettings copyWith({
    bool? daily,
    int? dailyAt,
    bool? weekly,
    int? weeklyDay,
    int? weeklyAt,
    bool? water,
    int? waterEveryHours,
    int? waterFrom,
    int? waterTo,
    bool? weighIn,
    int? weighInDay,
    int? weighInAt,
    bool? workout,
    Set<int>? workoutDays,
    int? workoutAt,
    bool? bedtime,
    int? bedtimeAt,
  }) =>
      ReminderSettings(
        daily: daily ?? this.daily,
        dailyAt: dailyAt ?? this.dailyAt,
        weekly: weekly ?? this.weekly,
        weeklyDay: weeklyDay ?? this.weeklyDay,
        weeklyAt: weeklyAt ?? this.weeklyAt,
        water: water ?? this.water,
        waterEveryHours: waterEveryHours ?? this.waterEveryHours,
        waterFrom: waterFrom ?? this.waterFrom,
        waterTo: waterTo ?? this.waterTo,
        weighIn: weighIn ?? this.weighIn,
        weighInDay: weighInDay ?? this.weighInDay,
        weighInAt: weighInAt ?? this.weighInAt,
        workout: workout ?? this.workout,
        workoutDays: workoutDays ?? this.workoutDays,
        workoutAt: workoutAt ?? this.workoutAt,
        bedtime: bedtime ?? this.bedtime,
        bedtimeAt: bedtimeAt ?? this.bedtimeAt,
      );

  /// Changes whenever anything that affects the schedule changes.
  String get signature => [
        daily, dailyAt, weekly, weeklyDay, weeklyAt, water, waterEveryHours,
        waterFrom, waterTo, weighIn, weighInDay, weighInAt, workout,
        (workoutDays?.toList()?..sort())?.join(','), workoutAt, bedtime, bedtimeAt,
      ].join('|');

  static ReminderSettings fromPrefs(SharedPreferences p) {
    const d = ReminderSettings();
    final days = p.getStringList('workout_reminder_days');
    return ReminderSettings(
      daily: p.getBool('daily_reminder') ?? false,
      dailyAt: p.getInt('daily_reminder_at') ?? d.dailyAt,
      weekly: p.getBool('weekly_check_in') ?? false,
      weeklyDay: p.getInt('weekly_check_in_day') ?? d.weeklyDay,
      weeklyAt: p.getInt('weekly_check_in_at') ?? d.weeklyAt,
      water: p.getBool('water_reminder') ?? false,
      waterEveryHours: p.getInt('water_reminder_every') ?? d.waterEveryHours,
      waterFrom: p.getInt('water_reminder_from') ?? d.waterFrom,
      waterTo: p.getInt('water_reminder_to') ?? d.waterTo,
      weighIn: p.getBool('weigh_in_reminder') ?? false,
      weighInDay: p.getInt('weigh_in_reminder_day') ?? d.weighInDay,
      weighInAt: p.getInt('weigh_in_reminder_at') ?? d.weighInAt,
      workout: p.getBool('workout_reminder') ?? false,
      workoutDays: days?.map(int.tryParse).whereType<int>().where((x) => x >= 1 && x <= 7).toSet(),
      workoutAt: p.getInt('workout_reminder_at') ?? d.workoutAt,
      bedtime: p.getBool('bedtime_reminder') ?? false,
      bedtimeAt: p.getInt('bedtime_reminder_at') ?? d.bedtimeAt,
    );
  }

  Future<void> save(SharedPreferences p) async {
    await p.setBool('daily_reminder', daily);
    await p.setInt('daily_reminder_at', dailyAt);
    await p.setBool('weekly_check_in', weekly);
    await p.setInt('weekly_check_in_day', weeklyDay);
    await p.setInt('weekly_check_in_at', weeklyAt);
    await p.setBool('water_reminder', water);
    await p.setInt('water_reminder_every', waterEveryHours);
    await p.setInt('water_reminder_from', waterFrom);
    await p.setInt('water_reminder_to', waterTo);
    await p.setBool('weigh_in_reminder', weighIn);
    await p.setInt('weigh_in_reminder_day', weighInDay);
    await p.setInt('weigh_in_reminder_at', weighInAt);
    await p.setBool('workout_reminder', workout);
    if (workoutDays != null) {
      await p.setStringList('workout_reminder_days', [for (final d in workoutDays!) '$d']);
    }
    await p.setInt('workout_reminder_at', workoutAt);
    await p.setBool('bedtime_reminder', bedtime);
    await p.setInt('bedtime_reminder_at', bedtimeAt);
  }
}
