import 'package:bmi_health/core/notifications/reminder_service.dart';
import 'package:bmi_health/l10n/l10n.dart';

/// Rest-timer notifications while the app is in the background.
/// Tests replace [restAlerts] with a [RecordingRestAlerts].
abstract class RestAlerts {
  Future<void> schedule(DateTime end, AppLocalizations l);
  Future<void> cancel();

  /// Null when it can't be told (then we don't ask).
  Future<bool?> allowed();
  Future<bool> request();
}

RestAlerts restAlerts = _NotificationRestAlerts();

class _NotificationRestAlerts implements RestAlerts {
  ReminderService get _n => ReminderService.instance;

  @override
  Future<void> schedule(DateTime end, AppLocalizations l) => _n.scheduleRestEnd(end, l: l);
  @override
  Future<void> cancel() => _n.cancelRest();
  @override
  Future<bool?> allowed() => _n.notificationsAllowed();
  @override
  Future<bool> request() => _n.requestPermission();
}

class RecordingRestAlerts implements RestAlerts {
  final scheduled = <DateTime>[];
  int cancels = 0;
  bool? isAllowed = true;
  int requests = 0;

  @override
  Future<void> schedule(DateTime end, AppLocalizations l) async => scheduled.add(end);
  @override
  Future<void> cancel() async => cancels++;
  @override
  Future<bool?> allowed() async => isAllowed;
  @override
  Future<bool> request() async {
    requests++;
    return isAllowed = true;
  }
}
