import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/recovery/domain/recovery.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';

/// Daily values read from the health store.
typedef DailyValue = ({DateTime day, double value});

/// Sleep and heart data from Health Connect / HealthKit (read-only).
abstract class RecoverySource {
  Future<bool> available();
  Future<bool> hasAccess();
  Future<bool> requestAccess();
  Future<List<SleepNight>> sleepSegments(DateTime from, DateTime to);
  Future<List<DailyValue>> restingHr(DateTime from, DateTime to);
  Future<List<DailyValue>> hrv(DateTime from, DateTime to);
}

class HealthRecoverySource implements RecoverySource {
  final _health = Health();
  bool _configured = false;

  List<HealthDataType> get _sleep => [
        Platform.isIOS ? HealthDataType.SLEEP_ASLEEP : HealthDataType.SLEEP_SESSION
      ];
  HealthDataType get _hrv => Platform.isIOS
      ? HealthDataType.HEART_RATE_VARIABILITY_SDNN
      : HealthDataType.HEART_RATE_VARIABILITY_RMSSD;
  List<HealthDataType> get _types =>
      [..._sleep, HealthDataType.RESTING_HEART_RATE, _hrv];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> available() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    await _configure();
    if (Platform.isIOS) return true;
    return await _health.getHealthConnectSdkStatus() ==
        HealthConnectSdkStatus.sdkAvailable;
  }

  @override
  Future<bool> hasAccess() async {
    await _configure();
    // iOS never reveals read access; data simply comes back empty.
    if (Platform.isIOS) return true;
    return await _health.hasPermissions(_types,
            permissions: List.filled(_types.length, HealthDataAccess.READ)) ??
        false;
  }

  @override
  Future<bool> requestAccess() async {
    await _configure();
    return _health.requestAuthorization(_types,
        permissions: List.filled(_types.length, HealthDataAccess.READ));
  }

  Future<List<HealthDataPoint>> _read(
          List<HealthDataType> t, DateTime from, DateTime to) async =>
      _health.removeDuplicates(
          await _health.getHealthDataFromTypes(types: t, startTime: from, endTime: to));

  @override
  Future<List<SleepNight>> sleepSegments(DateTime from, DateTime to) async =>
      [for (final p in await _read(_sleep, from, to)) SleepNight(p.dateFrom, p.dateTo)];

  Future<List<DailyValue>> _daily(HealthDataType t, DateTime from, DateTime to) async {
    final byDay = <DateTime, List<double>>{};
    for (final p in await _read([t], from, to)) {
      final v = p.value;
      if (v is! NumericHealthValue) continue;
      final d = DateTime(p.dateFrom.year, p.dateFrom.month, p.dateFrom.day);
      byDay.putIfAbsent(d, () => []).add(v.numericValue.toDouble());
    }
    return [
      for (final e in byDay.entries)
        (day: e.key, value: e.value.reduce((a, b) => a + b) / e.value.length)
    ]..sort((a, b) => a.day.compareTo(b.day));
  }

  @override
  Future<List<DailyValue>> restingHr(DateTime from, DateTime to) =>
      _daily(HealthDataType.RESTING_HEART_RATE, from, to);

  @override
  Future<List<DailyValue>> hrv(DateTime from, DateTime to) => _daily(_hrv, from, to);
}

/// Recovery score and sleep insights (ROADMAP 4.1, 4.2).
class RecoveryProvider extends ChangeNotifier {
  RecoveryProvider({RecoverySource? source, DateTime Function()? clock})
      : _source = source ?? HealthRecoverySource(),
        _now = clock ?? DateTime.now;

  final RecoverySource _source;
  final DateTime Function() _now;
  static const _connectedKey = 'recovery_connected';

  bool _available = false;
  bool _connected = false;
  List<SleepNight> _nights = [];
  List<DailyValue> _rhr = [];
  List<DailyValue> _hrv = [];
  int? _soreness;

  /// Health store present on this device.
  bool get available => _available;
  bool get connected => _connected;
  List<SleepNight> get nights => _nights;
  int? get soreness => _soreness;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  String get _sorenessKey {
    final d = _day(_now());
    return 'soreness_${d.year}-${d.month}-${d.day}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _soreness = prefs.getInt(_sorenessKey);
    _connected = prefs.getBool(_connectedKey) ?? false;
    await refresh();
  }

  Future<void> refresh() async {
    try {
      _available = await _source.available();
      if (_available && _connected && await _source.hasAccess()) {
        final now = _now();
        final from = _day(now).subtract(const Duration(days: 14));
        _nights = SleepSummary.mergeSegments(await _source.sleepSegments(
            from.subtract(const Duration(hours: 6)), now));
        _rhr = await _source.restingHr(from, now);
        _hrv = await _source.hrv(from, now);
      }
    } catch (e, st) {
      reportError(e, st, reason: 'recovery-read');
    }
    final prefs = await SharedPreferences.getInstance();
    _soreness = prefs.getInt(_sorenessKey);
    notifyListeners();
  }

  Future<void> connect() async {
    AdService.instance.beginExternalUi();
    try {
      _connected = await _source.requestAccess();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_connectedKey, _connected);
    } catch (e, st) {
      reportError(e, st, reason: 'recovery-connect');
    } finally {
      AdService.instance.endExternalUi();
    }
    await refresh();
  }

  Future<void> setSoreness(int value) async {
    _soreness = value.clamp(1, 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sorenessKey, _soreness!);
    notifyListeners();
  }

  /// Last night's sleep (woke up today), if recorded.
  SleepNight? get lastNight {
    final today = _day(_now());
    for (final n in _nights.reversed) {
      if (n.wakeDay == today) return n;
    }
    return null;
  }

  SleepSummary? get week => SleepSummary.of(_nights
      .where((n) => n.wakeDay.isAfter(_day(_now()).subtract(const Duration(days: 8))))
      .toList());

  static ({double? today, double? baseline}) _todayVsBaseline(
      List<DailyValue> v, DateTime today) {
    if (v.isEmpty) return (today: null, baseline: null);
    final t = v.where((x) => x.day == today).map((x) => x.value).firstOrNull;
    final past = v.where((x) => x.day != today).map((x) => x.value).toList();
    // Need a few days before a baseline means anything.
    final base = past.length < 3 ? null : past.reduce((a, b) => a + b) / past.length;
    return (today: t, baseline: base);
  }

  /// Today's score from health data, training history and check-in.
  /// [setsSince] returns completed sets from workouts started on/after a date.
  RecoveryScore? score(List<WorkoutSet> Function(DateTime from) setsSince) {
    final today = _day(_now());
    final recent = setsSince(today.subtract(const Duration(days: 2))).length.toDouble();
    // Average 2-day load over the previous 4 weeks.
    final usual =
        (setsSince(today.subtract(const Duration(days: 30))).length - recent) / 14;
    final rhr = _todayVsBaseline(_rhr, today);
    final hrv = _todayVsBaseline(_hrv, today);
    final night = lastNight;

    return Recovery.compute(RecoveryInputs(
      sleepHours: night == null ? null : night.duration.inMinutes / 60,
      restingHr: rhr.today,
      restingHrBaseline: rhr.baseline,
      hrv: hrv.today,
      hrvBaseline: hrv.baseline,
      recentSets: recent,
      usualSets: usual,
      soreness: _soreness,
    ));
  }
}
