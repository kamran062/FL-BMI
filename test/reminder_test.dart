import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });

  test('weekly: the next Sunday at the hour', () {
    // 3 Nov 2026 is a Tuesday → Sunday 8 Nov
    expect(ReminderService.nextAt(at(3, 9), hour: 10, weekday: DateTime.sunday),
        at(8, 10));
    // On Sunday after 10:00 → the following Sunday
    expect(ReminderService.nextAt(at(8, 11), hour: 10, weekday: DateTime.sunday),
        at(15, 10));
  });
}
