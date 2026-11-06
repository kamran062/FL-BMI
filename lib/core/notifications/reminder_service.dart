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
  static const _restId = 3;
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

  /// Whether notifications are allowed; null if it can't be told.
  Future<bool?> notificationsAllowed() async {
    try {
      await _init();
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.areNotificationsEnabled();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) return (await ios.checkPermissions())?.isEnabled;
    } catch (e, st) {
      reportError(e, st, reason: 'notify-check');
    }
    return null;
  }

  /// While the app is in the background during rest: a live countdown
  /// (Android) and an alert when rest ends. The alert replaces the countdown.
  Future<void> scheduleRestEnd(DateTime end, {required AppLocalizations l}) async {
    try {
      await _init();
      final left = end.difference(DateTime.now());
      if (left <= Duration.zero) return;
      if (_plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>() !=
          null) {
        await _plugin.show(
          _restId,
          l.trainRestCountdownTitle,
          l.trainRestCountdownBody,
          NotificationDetails(
            android: AndroidNotificationDetails('rest_countdown', l.trainRestChannel,
                importance: Importance.low,
                silent: true,
                ongoing: true,
                usesChronometer: true,
                chronometerCountDown: true,
                when: end.millisecondsSinceEpoch,
                timeoutAfter: left.inMilliseconds),
          ),
        );
      }
      await _plugin.zonedSchedule(
        _restId,
        l.trainRestOverTitle,
        l.trainRestOverBody,
        tz.TZDateTime.from(end, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails('rest_end', l.trainRestChannel,
              importance: Importance.high, priority: Priority.high),
          iOS: const DarwinNotificationDetails(
              interruptionLevel: InterruptionLevel.timeSensitive),
        ),
        // Inexact (no special permission): on Android it can arrive a little
        // late; the countdown above shows the exact time.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e, st) {
      reportError(e, st, reason: 'rest-notify');
    }
  }

  Future<void> cancelRest() async {
    try {
      await _init();
      await _plugin.cancel(_restId);
    } catch (e, st) {
      reportError(e, st, reason: 'rest-notify');
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
