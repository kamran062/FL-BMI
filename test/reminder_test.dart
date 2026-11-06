import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:bmi_health/core/notifications/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  final karachi = tz.getLocation('Asia/Karachi');
  tz.TZDateTime at(int d, int h, [int m = 0]) =>
      tz.TZDateTime(karachi, 2026, 11, d, h, m);

  test('daily: later today, or tomorrow once the time has passed', () {
    expect(ReminderService.nextAt(at(3, 9), hour: 20), at(3, 20));
    expect(ReminderService.nextAt(at(3, 20), hour: 20), at(4, 20));
    expect(ReminderService.nextAt(at(3, 21, 30), hour: 20), at(4, 20));
    expect(ReminderService.nextAt(at(3, 22, 10), hour: 22, minute: 30), at(3, 22, 30));
    expect(ReminderService.nextAt(at(3, 22, 30), hour: 22, minute: 30), at(4, 22, 30));
  });

  test('weekly: the next Sunday at the hour', () {
    // 3 Nov 2026 is a Tuesday → Sunday 8 Nov
    expect(ReminderService.nextAt(at(3, 9), hour: 10, weekday: DateTime.sunday),
        at(8, 10));
    // On Sunday after 10:00 → the following Sunday
    expect(ReminderService.nextAt(at(8, 11), hour: 10, weekday: DateTime.sunday),
        at(15, 10));
  });

  group('ReminderSettings', () {
    test('nothing scheduled by default', () {
      expect(const ReminderSettings().slots(), isEmpty);
    });

    test('custom check-in times', () {
      final s = const ReminderSettings(daily: true, dailyAt: 21 * 60 + 15).slots();
      expect(s.single, (id: 1, kind: ReminderKind.daily, hour: 21, minute: 15, weekday: null));
      final w = const ReminderSettings(weekly: true, weeklyDay: DateTime.saturday, weeklyAt: 9 * 60)
          .slots()
          .single;
      expect((w.weekday, w.hour), (DateTime.saturday, 9));
    });

    test('water every 2 h from 9:00 to 21:00, inside the window only', () {
      const r = ReminderSettings(water: true);
      expect(r.waterTimes.map((m) => m ~/ 60), [9, 11, 13, 15, 17, 19, 21]);
      final slots = r.slots();
      expect(slots.every((s) => s.kind == ReminderKind.water && s.weekday == null), isTrue);
      expect(slots.map((s) => s.id).toSet().length, slots.length);
      expect(const ReminderSettings(water: true, waterEveryHours: 3, waterTo: 20 * 60)
          .waterTimes
          .map((m) => m ~/ 60), [9, 12, 15, 18]);
    });

    test('workout days follow the profile until chosen', () {
      final three = const ReminderSettings(workout: true).slots(perWeek: 3);
      expect(three.map((s) => s.weekday), [DateTime.monday, DateTime.wednesday, DateTime.friday]);
      expect(three.every((s) => s.hour == 18), isTrue);
      expect(const ReminderSettings(workout: true).slots(perWeek: 5).length, 5);
      final chosen = const ReminderSettings(workout: true, workoutDays: {DateTime.sunday, DateTime.tuesday})
          .slots(perWeek: 5);
      expect(chosen.map((s) => s.weekday), [DateTime.tuesday, DateTime.sunday]);
      for (var n = 1; n <= 7; n++) {
        expect(ReminderSettings.defaultWorkoutDays(n).length, n);
      }
    });

    test('weigh-in and bedtime', () {
      final s = const ReminderSettings(weighIn: true, bedtime: true).slots();
      expect(s.map((x) => x.kind), [ReminderKind.weighIn, ReminderKind.bedtime]);
      expect((s[0].weekday, s[0].hour, s[0].minute), (DateTime.monday, 7, 30));
      expect((s[1].weekday, s[1].hour, s[1].minute), (null, 22, 30));
    });

    test('every scheduled id is cancellable and none clash with the gym check-in', () {
      const all = ReminderSettings(
          daily: true, weekly: true, water: true, waterEveryHours: 1, waterFrom: 0, waterTo: 23 * 60,
          weighIn: true, workout: true, bedtime: true);
      final ids = all.slots(perWeek: 7).map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ReminderSettings.allIds, containsAll(ids));
      expect(ReminderSettings.allIds, isNot(contains(10)));
    });

    test('saved and loaded through preferences (old keys kept)', () async {
      SharedPreferences.setMockInitialValues({'daily_reminder': true});
      final prefs = await SharedPreferences.getInstance();
      expect(ReminderSettings.fromPrefs(prefs).daily, isTrue);
      const r = ReminderSettings(
          weekly: true, weeklyAt: 8 * 60, water: true, waterEveryHours: 3,
          workout: true, workoutDays: {2, 4}, bedtime: true, bedtimeAt: 23 * 60);
      await r.save(prefs);
      final back = ReminderSettings.fromPrefs(prefs);
      expect(back.signature, r.signature);
      expect(prefs.getBool('weekly_check_in'), isTrue);
    });
  });
}
