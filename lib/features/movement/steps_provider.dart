import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';

enum StepsStatus {
  /// Not on this platform (e.g. tests, desktop).
  unsupported,

  /// Android: Health Connect missing or needs an update.
  needsInstall,

  /// The user has not connected yet (or revoked access).
  notConnected,
  connected,
}

/// Abstraction over the platform health store, so tests can fake it.
abstract class StepsSource {
  Future<StepsStatus> status({required bool userConnected});
  Future<bool> requestAccess();
  Future<void> install();
  Future<int> stepsBetween(DateTime from, DateTime to);
}

/// Health Connect (Android) / HealthKit (iOS). Read-only, steps only.
class HealthStepsSource implements StepsSource {
  final _health = Health();
  bool _configured = false;
  static const _types = [HealthDataType.STEPS];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<StepsStatus> status({required bool userConnected}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return StepsStatus.unsupported;
    await _configure();
    if (Platform.isAndroid) {
      final sdk = await _health.getHealthConnectSdkStatus();
      if (sdk != HealthConnectSdkStatus.sdkAvailable) {
        return StepsStatus.needsInstall;
      }
    }
    if (!userConnected) return StepsStatus.notConnected;
    // iOS never reveals read permission; trust the user's choice there.
    final granted = Platform.isIOS
        ? true
        : await _health.hasPermissions(_types) ?? false;
    return granted ? StepsStatus.connected : StepsStatus.notConnected;
  }

  @override
  Future<bool> requestAccess() async {
    await _configure();
    return _health.requestAuthorization(_types,
        permissions: const [HealthDataAccess.READ]);
  }

  @override
  Future<void> install() => _health.installHealthConnect();

  @override
  Future<int> stepsBetween(DateTime from, DateTime to) async =>
      await _health.getTotalStepsInInterval(from, to) ?? 0;
}

/// Today's step count from the phone's health store.
class StepsProvider extends ChangeNotifier {
  StepsProvider({StepsSource? source, DateTime Function()? clock})
      : _source = source ?? HealthStepsSource(),
        _now = clock ?? DateTime.now;

  final StepsSource _source;
  final DateTime Function() _now;

  static const _connectedKey = 'steps_connected';
  static const _bestKey = 'steps_best_day';
  static const defaultGoal = 8000;

  StepsStatus _status = StepsStatus.unsupported;
  int _today = 0;
  bool _userConnected = false;

  StepsStatus get status => _status;
  int get today => _today;

  /// Most steps seen on one day since connecting (for the 10k badge).
  int get bestDay => _bestDay;
  int _bestDay = 0;
  int get goal => defaultGoal;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userConnected = prefs.getBool(_connectedKey) ?? false;
    await refresh();
  }

  /// Re-reads status and today's steps (call on app resume).
  /// [justGranted]: Health Connect reports a fresh grant as "not granted"
  /// for a moment, so trust a successful request instead of re-checking.
  Future<void> refresh({bool justGranted = false}) async {
    try {
      _status = justGranted
          ? StepsStatus.connected
          : await _source.status(userConnected: _userConnected);
      if (_status == StepsStatus.connected) {
        final n = _now();
        _today = await _source.stepsBetween(DateTime(n.year, n.month, n.day), n);
        final prefs = await SharedPreferences.getInstance();
        _bestDay = prefs.getInt(_bestKey) ?? 0;
        if (_today > _bestDay) {
          _bestDay = _today;
          await prefs.setInt(_bestKey, _today);
        }
      }
    } catch (e, st) {
      reportError(e, st, reason: 'steps');
    }
    notifyListeners();
  }

  /// Asks for read access to steps. Only ever called from a user tap.
  Future<void> connect() async {
    // The permission screen leaves the app; don't treat the return as an
    // app open (App Open ad).
    AdService.instance.beginExternalUi();
    var ok = false;
    try {
      if (_status == StepsStatus.needsInstall) {
        await _source.install();
        return;
      }
      ok = await _source.requestAccess();
      _userConnected = ok;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_connectedKey, ok);
    } catch (e, st) {
      reportError(e, st, reason: 'steps-connect');
    } finally {
      AdService.instance.endExternalUi();
    }
    await refresh(justGranted: ok);
  }
}
