import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';

/// What the watch shows (ROADMAP 5.4). Kept small: the Data Layer syncs it
/// on every change.
@immutable
class WearState {
  final bool active;
  final String exercise;
  final int setNumber; // 1-based, of the next set to do
  final int setsTotal;
  final double weightKg;
  final int reps;
  final int restEndsAtMs; // 0 = no rest running
  final bool allDone;

  const WearState({
    this.active = false,
    this.exercise = '',
    this.setNumber = 0,
    this.setsTotal = 0,
    this.weightKg = 0,
    this.reps = 0,
    this.restEndsAtMs = 0,
    this.allDone = false,
  });

  static const idle = WearState();

  Map<String, Object> toJson() => {
        'active': active,
        'exercise': exercise,
        'setNumber': setNumber,
        'setsTotal': setsTotal,
        'weightKg': weightKg,
        'reps': reps,
        'restEndsAt': restEndsAtMs,
        'allDone': allDone,
      };

  @override
  bool operator ==(Object other) =>
      other is WearState && jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  /// The next unticked set in workout order.
  static ({String exerciseId, WorkoutSet set, int index, int total})? nextSet(
      WorkoutProvider w) {
    for (final id in w.activeExercises) {
      final sets = w.setsFor(id);
      for (var i = 0; i < sets.length; i++) {
        if (!sets[i].done) return (exerciseId: id, set: sets[i], index: i, total: sets.length);
      }
    }
    return null;
  }

  static WearState of(WorkoutProvider w, ExerciseCatalog catalog, String locale,
      {int restEndsAtMs = 0}) {
    if (w.active == null) return idle;
    final next = nextSet(w);
    if (next == null) {
      return WearState(active: true, allDone: true, restEndsAtMs: restEndsAtMs);
    }
    return WearState(
      active: true,
      exercise: catalog.byId(next.exerciseId)?.nameIn(locale) ?? next.exerciseId,
      setNumber: next.index + 1,
      setsTotal: next.total,
      weightKg: next.set.weightKg,
      reps: next.set.reps,
      restEndsAtMs: restEndsAtMs,
    );
  }
}

/// Native side: android MainActivity (Wearable Data Layer). A no-op where
/// there is no watch support (iOS for now, tests, desktop).
abstract class WearChannel {
  Future<void> send(WearState s);
  void listen(Future<void> Function(String event, Object? arg) onEvent);
}

class PlatformWearChannel implements WearChannel {
  static const _ch = MethodChannel('bmi_health/wear');

  @override
  Future<void> send(WearState s) async {
    try {
      await _ch.invokeMethod('sync', jsonEncode(s.toJson()));
    } on MissingPluginException {
      // No watch support on this platform.
    } on PlatformException {
      // No watch paired / Play services missing: nothing to do.
    }
  }

  @override
  void listen(Future<void> Function(String event, Object? arg) onEvent) {
    _ch.setMethodCallHandler((call) => onEvent(call.method, call.arguments));
  }
}

/// Keeps the watch in step with the active workout and applies what the
/// user does on the watch.
class WearBridge {
  WearBridge(this._workouts, this._catalog,
      {WearChannel? channel, DateTime Function()? clock, this.locale = 'en'})
      : _channel = channel ?? PlatformWearChannel(),
        _now = clock ?? DateTime.now {
    _workouts.addListener(_onChange);
    _channel.listen(_onEvent);
    _onChange();
  }

  static const restSeconds = 90;

  final WorkoutProvider _workouts;
  final ExerciseCatalog _catalog;
  final WearChannel _channel;
  final DateTime Function() _now;
  String locale;

  /// Latest heart rate from the watch (null when none is coming in).
  final heartRate = ValueNotifier<int?>(null);
  DateTime? _lastHr;

  /// Null until the first send, so the watch is always reset on app start.
  WearState? _sent;
  int _doneCount = 0;
  int _restEndsAt = 0;

  int get _done => _workouts.activeSets.where((s) => s.done).length;

  void _onChange() {
    if (_workouts.active == null) {
      _doneCount = 0;
      _restEndsAt = 0;
      heartRate.value = null;
    } else {
      final done = _done;
      // A newly ticked set (phone or watch) starts the rest timer.
      if (done > _doneCount) {
        _restEndsAt = _now().add(const Duration(seconds: restSeconds)).millisecondsSinceEpoch;
      }
      _doneCount = done;
    }
    final s = WearState.of(_workouts, _catalog, locale, restEndsAtMs: _restEndsAt);
    if (s != _sent) {
      _sent = s;
      _channel.send(s);
    }
  }

  Future<void> _onEvent(String event, Object? arg) async {
    switch (event) {
      case 'setDone':
        final next = WearState.nextSet(_workouts);
        if (next != null) await _workouts.updateSet(next.set.copyWith(done: true));
      case 'heartRate':
        final bpm = arg is int ? arg : int.tryParse('$arg');
        // Ignore sensor noise outside a human range.
        if (bpm != null && bpm >= 30 && bpm <= 230 && _workouts.active != null) {
          heartRate.value = bpm;
          _lastHr = _now();
        }
    }
  }

  /// Hides a stale reading (watch taken off, sensor stopped).
  int? get currentHeartRate {
    final at = _lastHr;
    if (at == null || _now().difference(at) > const Duration(seconds: 20)) return null;
    return heartRate.value;
  }

  void dispose() => _workouts.removeListener(_onChange);
}
