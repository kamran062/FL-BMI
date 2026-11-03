import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/l10n/l10n.dart';

/// Local daily / weekly reminders. Nothing leaves the device.
///
/// Uses inexact scheduling, so no "alarms & reminders" special permission
/// is needed; reminders may arrive a few minutes late, which is fine here.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  static const _dailyId = 1;
  static const _weeklyId = 2;
  static const dailyHour = 20; // 8:00 PM
  static const weeklyHour = 10; // Sunday 10:00 AM

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (e, st) {
      // Falls back to UTC; reminders then fire at the UTC hour.
      reportError(e, st, reason: 'timezone');
    }
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
    _ready = true;
  }

  /// Asks for notification permission (Android 13+, iOS). Returns whether
  /// notifications are allowed.
  Future<bool> requestPermission() async {
    await _init();
    // The system prompt leaves the app; returning from it must not count
    // as an app open (which would show an App Open ad).
    AdService.instance.beginExternalUi();
    try {
      return await _requestPermission();
    } finally {
      AdService.instance.endExternalUi();
    }
  }

  Future<bool> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return true;
  }

  /// Makes the scheduled reminders match the settings. Safe to call often.
  Future<void> sync({
    required bool daily,
    required bool weekly,
    required AppLocalizations l,
  }) async {
    try {
      await _init();
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          l.reminderChannel,
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _plugin.cancel(_dailyId);
      await _plugin.cancel(_weeklyId);
      if (daily) {
        await _plugin.zonedSchedule(
          _dailyId,
          l.dailyReminderTitle,
          l.dailyReminderBody,
          nextAt(tz.TZDateTime.now(tz.local), hour: dailyHour),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      if (weekly) {
        await _plugin.zonedSchedule(
          _weeklyId,
          l.weeklyReminderTitle,
          l.weeklyReminderBody,
          nextAt(tz.TZDateTime.now(tz.local),
              hour: weeklyHour, weekday: DateTime.sunday),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e, st) {
      reportError(e, st, reason: 'reminders');
    }
  }

  /// Next occurrence of [hour]:00 (optionally on [weekday]) after [now].
  @visibleForTesting
  static tz.TZDateTime nextAt(tz.TZDateTime now, {required int hour, int? weekday}) {
    var t = tz.TZDateTime(now.location, now.year, now.month, now.day, hour);
    if (weekday != null) {
      t = t.add(Duration(days: (weekday - t.weekday) % 7));
    }
    if (!t.isAfter(now)) t = t.add(Duration(days: weekday == null ? 1 : 7));
    return t;
  }
}
