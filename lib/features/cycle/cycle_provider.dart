import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/cycle/domain/cycle.dart';

/// Device unlock (biometric or PIN); a seam for tests.
abstract class AppLock {
  Future<bool> canLock();
  Future<bool> unlock(String reason);
}

class DeviceAppLock implements AppLock {
  final _auth = LocalAuthentication();

  @override
  Future<bool> canLock() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> unlock(String reason) async {
    // The system prompt can pause the app; not an "app open".
    AdService.instance.beginExternalUi();
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (e, st) {
      reportError(e, st, reason: 'cycle-unlock');
      return false;
    } finally {
      AdService.instance.endExternalUi();
    }
  }
}

/// Cycle tracking (ROADMAP 4.3). Off until the user opts in; data stays on
/// the device and can be deleted in one tap.
class CycleProvider extends ChangeNotifier {
  CycleProvider(this._db, {AppLock? lock, DateTime Function()? clock})
      : _lock = lock ?? DeviceAppLock(),
        _now = clock ?? DateTime.now;

  final DatabaseHelper _db;
  final AppLock _lock;
  final DateTime Function() _now;
  static const _enabledKey = 'cycle_enabled';
  static const _lockKey = 'cycle_lock';

  bool _enabled = false;
  bool _lockEnabled = false;
  bool _unlocked = false;
  List<Period> _periods = [];
  Map<String, Set<Symptom>> _symptoms = {};

  bool get enabled => _enabled;
  bool get lockEnabled => _lockEnabled;

  /// Data may be shown (no lock, or unlocked this session).
  bool get unlocked => !_lockEnabled || _unlocked;
  List<Period> get periods => _periods;
  CycleStatus? get status => CyclePredictor.status(_periods, _now());
  Period? get ongoing =>
      _periods.isNotEmpty && _periods.last.end == null ? _periods.last : null;

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Set<Symptom> symptomsOn(DateTime d) => _symptoms[dateKey(d)] ?? const {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _lockEnabled = prefs.getBool(_lockKey) ?? false;
    if (_enabled) await _reload();
    notifyListeners();
  }

  Future<void> _reload() async {
    _periods = await _db.getPeriods();
    _symptoms = {
      for (final e in (await _db.getCycleSymptoms()).entries)
        e.key: {
          for (final n in e.value.split(','))
            if (Symptom.values.asNameMap()[n] case final s?) s
        }
    };
  }

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, v);
    if (v) await _reload();
    notifyListeners();
  }

  Future<bool> canLock() => _lock.canLock();

  /// Turning the lock on requires unlocking once, so users can't lock
  /// themselves out with a method that doesn't work.
  Future<bool> setLock(bool v, String reason) async {
    if (v && !await _lock.unlock(reason)) return false;
    _lockEnabled = v;
    _unlocked = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, v);
    notifyListeners();
    return true;
  }

  Future<bool> unlock(String reason) async {
    _unlocked = await _lock.unlock(reason);
    notifyListeners();
    return _unlocked;
  }

  /// Locks again when the app goes to the background.
  void relock() {
    if (_lockEnabled && _unlocked) {
      _unlocked = false;
      notifyListeners();
    }
  }

  Future<void> startPeriod(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    // Close an ongoing period first.
    if (ongoing case final o?) {
      await _db.updatePeriod(Period(id: o.id, start: o.start, end: d.subtract(const Duration(days: 1))));
    }
    await _db.insertPeriod(Period(start: d));
    await _reload();
    notifyListeners();
  }

  Future<void> endPeriod(DateTime day) async {
    final o = ongoing;
    if (o == null) return;
    final d = DateTime(day.year, day.month, day.day);
    await _db.updatePeriod(Period(id: o.id, start: o.start, end: d.isBefore(o.start) ? o.start : d));
    await _reload();
    notifyListeners();
  }

  Future<void> deletePeriod(int id) async {
    await _db.deletePeriod(id);
    await _reload();
    notifyListeners();
  }

  Future<void> toggleSymptom(DateTime day, Symptom s) async {
    final key = dateKey(day);
    final set = {...?_symptoms[key]};
    set.contains(s) ? set.remove(s) : set.add(s);
    await _db.setCycleSymptoms(key, set.map((e) => e.name).join(','));
    _symptoms[key] = set;
    notifyListeners();
  }

  /// One-tap delete: removes all cycle data and turns tracking off.
  Future<void> deleteAll() async {
    await _db.deleteAllCycleData();
    _periods = [];
    _symptoms = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockKey);
    _lockEnabled = false;
    await setEnabled(false);
  }
}
