import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/core/notifications/reminder_settings.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/l10n/l10n.dart';

/// Local reminders (check-ins, water, weigh-in, workouts, bedtime). Nothing leaves the device.
///
/// Uses inexact scheduling, so no "alarms & reminders" special permission
/// is needed; reminders may arrive a few minutes late, which is fine here.
class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

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
  /// [perWeek] (the profile's training days) picks workout days when the
  /// user has not chosen them.
  Future<void> sync(ReminderSettings settings,
      {required AppLocalizations l, int perWeek = 3}) async {
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

      for (final id in ReminderSettings.allIds) {
        await _plugin.cancel(id);
      }
      final now = tz.TZDateTime.now(tz.local);
      for (final s in settings.slots(perWeek: perWeek)) {
        final (title, body) = switch (s.kind) {
          ReminderKind.daily => (l.dailyReminderTitle, l.dailyReminderBody),
          ReminderKind.weekly => (l.weeklyReminderTitle, l.weeklyReminderBody),
          ReminderKind.water => (l.remindWaterTitle, l.remindWaterBody),
          ReminderKind.weighIn => (l.remindWeighInTitle, l.remindWeighInBody),
          ReminderKind.workout => (l.remindWorkoutTitle, l.remindWorkoutBody),
          ReminderKind.bedtime => (l.remindBedtimeTitle, l.remindBedtimeBody),
        };
        await _plugin.zonedSchedule(
          s.id,
          title,
          body,
          nextAt(now, hour: s.hour, minute: s.minute, weekday: s.weekday),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: s.weekday == null
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e, st) {
      reportError(e, st, reason: 'reminders');
    }
  }

  /// Shows a notification right away (e.g. gym check-in).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required AppLocalizations l,
  }) async {
    try {
      await _init();
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails('activity', l.activityChannel,
              importance: Importance.high),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e, st) {
      reportError(e, st, reason: 'notify-now');
    }
  }

  /// Next occurrence of [hour]:[minute] (optionally on [weekday]) after [now].
  @visibleForTesting
  static tz.TZDateTime nextAt(tz.TZDateTime now,
      {required int hour, int minute = 0, int? weekday}) {
    var t = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);
    if (weekday != null) {
      t = t.add(Duration(days: (weekday - t.weekday) % 7));
    }
    if (!t.isAfter(now)) t = t.add(Duration(days: weekday == null ? 1 : 7));
    return t;
  }
}
