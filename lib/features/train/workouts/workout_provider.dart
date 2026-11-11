import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';

/// Active workout, workout history and saved routines.
/// Every change is written to the database immediately, so a workout
/// survives the app being killed mid-session.
class WorkoutProvider extends ChangeNotifier {
  WorkoutProvider(this._db);

  final DatabaseHelper _db;

  Workout? _active;
  List<WorkoutSet> _activeSets = [];
  List<WorkoutSummary> _history = [];
  List<Routine> _routines = [];
  List<WorkoutSet> _pastSets = [];

  Workout? get active => _active;
  List<WorkoutSet> get activeSets => _activeSets;
  List<WorkoutSummary> get history => _history;
  List<Routine> get routines => _routines;

  /// Exercise ids in the active workout, in order.
  List<String> get activeExercises {
    final seen = <String>[];
    for (final s in _activeSets) {
      if (!seen.contains(s.exerciseId)) seen.add(s.exerciseId);
    }
    return seen;
  }

  List<WorkoutSet> setsFor(String exerciseId) =>
      _activeSets.where((s) => s.exerciseId == exerciseId).toList();

  /// Completed sets from the last finished workout containing [exerciseId],
  /// shown as "previous" next to each set.
  List<WorkoutSet> previousSets(String exerciseId) {
    final byWorkout = <int, List<WorkoutSet>>{};
    for (final s in _pastSets.where((s) => s.exerciseId == exerciseId)) {
      byWorkout.putIfAbsent(s.workoutId, () => []).add(s);
    }
    return byWorkout.isEmpty ? const [] : byWorkout.values.last;
  }

  /// Completed sets of [exerciseId], one list per past workout, oldest first.
  List<List<WorkoutSet>> sessionsFor(String exerciseId) {
    final byWorkout = <int, List<WorkoutSet>>{};
    for (final s in _pastSets.where((s) => s.exerciseId == exerciseId)) {
      byWorkout.putIfAbsent(s.workoutId, () => []).add(s);
    }
    return byWorkout.values.toList();
  }

  /// Completed sets from workouts started on or after [from].
  List<WorkoutSet> setsSince(DateTime from) => [
        for (final h in _history)
          if (!h.workout.startedAt.isBefore(from)) ...h.doneSets
      ];

  Future<void> load() async {
    _active = await _db.getActiveWorkout();
    _activeSets = _active == null ? [] : await _db.getSets(_active!.id!);
    _routines = await _db.getRoutines();
    await _loadHistory();
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    _pastSets = await _db.getAllFinishedSets();
    final workouts = await _db.getFinishedWorkouts(); // newest first
    final setsByWorkout = <int, List<WorkoutSet>>{};
    for (final s in _pastSets) {
      setsByWorkout.putIfAbsent(s.workoutId, () => []).add(s);
    }
    // PRs: walk oldest → newest, comparing each workout to everything before.
    final best = <String, double>{};
    final prs = <int, int>{};
    for (final w in workouts.reversed) {
      final sets = setsByWorkout[w.id] ?? const <WorkoutSet>[];
      prs[w.id!] = WorkoutMath.personalRecords(best, sets).length;
      WorkoutMath.bestByExercise(sets).forEach((id, v) {
        if (v > (best[id] ?? 0)) best[id] = v;
      });
    }
    _history = [
      for (final w in workouts)
        WorkoutSummary(w, setsByWorkout[w.id] ?? const [], prCount: prs[w.id] ?? 0)
    ];
  }

  // ── Active workout ────────────────────────────────────────────────────

  /// [targets]: recommended sets × reps per exercise (muscle-day plans);
  /// used only for exercises with no history.
  Future<void> start({
    Routine? routine,
    String name = '',
    Map<String, Prescription> targets = const {},
  }) async {
    if (_active != null) return;
    final w = Workout(name: routine?.name ?? name, startedAt: DateTime.now());
    _active = w.copyWith(id: await _db.insertWorkout(w));
    _activeSets = [];
    if (routine != null) {
      for (final id in routine.exerciseIds) {
        await addExercise(id, notify: false, target: targets[id]);
      }
    }
    notifyListeners();
  }

  /// Adds an exercise prefilled from last time, or with the [target]
  /// number of sets (reps at the bottom of the range) when it's new.
  Future<void> addExercise(String exerciseId,
      {bool notify = true, Prescription? target}) async {
    final w = _active;
    if (w == null || activeExercises.contains(exerciseId)) return;
    final order = activeExercises.length;
    final prev = previousSets(exerciseId);
    final count = prev.isEmpty ? (target?.sets ?? 1) : prev.length;
    for (var i = 0; i < count; i++) {
      final p = prev.isEmpty ? null : prev[i];
      final s = WorkoutSet(
        workoutId: w.id!, exerciseId: exerciseId, order: order,
        weightKg: p?.weightKg ?? 0,
        reps: p?.reps ?? (target != null && !target.timed ? target.repMin : 0),
        // Warm-ups stay warm-ups; effort is rated fresh each time
        type: p?.type ?? SetType.normal,
      );
      _activeSets.add(WorkoutSet.fromMap({...s.toMap(), 'id': await _db.insertSet(s)}));
    }
    if (notify) notifyListeners();
  }

  Future<void> addSet(String exerciseId) async {
    final w = _active;
    if (w == null) return;
    final existing = setsFor(exerciseId);
    final last = existing.isEmpty ? null : existing.last;
    final s = WorkoutSet(
      workoutId: w.id!, exerciseId: exerciseId,
      order: last?.order ?? activeExercises.length,
      weightKg: last?.weightKg ?? 0, reps: last?.reps ?? 0,
    );
    _activeSets.add(WorkoutSet.fromMap({...s.toMap(), 'id': await _db.insertSet(s)}));
    _sortActive();
    notifyListeners();
  }

  Future<void> updateSet(WorkoutSet s) async {
    final i = _activeSets.indexWhere((x) => x.id == s.id);
    if (i < 0) return;
    _activeSets[i] = s;
    notifyListeners();
    await _db.updateSet(s);
  }

  Future<void> removeSet(WorkoutSet s) async {
    _activeSets.removeWhere((x) => x.id == s.id);
    notifyListeners();
    await _db.deleteSet(s.id!);
  }

  Future<void> removeExercise(String exerciseId) async {
    final sets = setsFor(exerciseId);
    _activeSets.removeWhere((x) => x.exerciseId == exerciseId);
    notifyListeners();
    for (final s in sets) {
      await _db.deleteSet(s.id!);
    }
  }

  /// Finishes the workout. Returns its summary, or null if no set was
  /// completed (the empty workout is discarded instead).
  Future<WorkoutSummary?> finish() async {
    final w = _active;
    if (w == null) return null;
    if (!_activeSets.any((s) => s.done)) {
      await discard();
      return null;
    }
    // Unticked sets are not part of the record.
    for (final s in _activeSets.where((s) => !s.done).toList()) {
      await _db.deleteSet(s.id!);
    }
    await _db.updateWorkout(w.copyWith(finishedAt: DateTime.now()));
    _active = null;
    _activeSets = [];
    await _loadHistory();
    notifyListeners();
    return _history.firstWhere((h) => h.workout.id == w.id);
  }

  Future<void> discard() async {
    final w = _active;
    if (w == null) return;
    _active = null;
    _activeSets = [];
    notifyListeners();
    await _db.deleteWorkout(w.id!);
  }

  // ── Finished workouts ─────────────────────────────────────────────────
  // Edits re-read history, so volume and PRs are recomputed everywhere.

  WorkoutSummary? summaryOf(int workoutId) {
    for (final h in _history) {
      if (h.workout.id == workoutId) return h;
    }
    return null;
  }

  Future<void> renameWorkout(int workoutId, String name) async {
    final h = summaryOf(workoutId);
    if (h == null) return;
    await _db.updateWorkout(h.workout.copyWith(name: name.trim()));
    await _reload();
  }

  Future<void> updateFinishedSet(WorkoutSet s) async {
    await _db.updateSet(s);
    await _reload();
  }

  /// Deleting the last set deletes the workout too.
  Future<void> deleteFinishedSet(WorkoutSet s) async {
    await _db.deleteSet(s.id!);
    final left = summaryOf(s.workoutId)?.sets.where((x) => x.id != s.id) ?? const [];
    if (left.isEmpty) await _db.deleteWorkout(s.workoutId);
    await _reload();
  }

  Future<void> deleteWorkout(int workoutId) async {
    await _db.deleteWorkout(workoutId);
    await _reload();
  }

  Future<void> _reload() async {
    await _loadHistory();
    notifyListeners();
  }

  // ── Routines ──────────────────────────────────────────────────────────

  Future<void> saveRoutine(String name, List<String> exerciseIds) async {
    if (name.trim().isEmpty || exerciseIds.isEmpty) return;
    await _db.insertRoutine(Routine(name: name.trim(), exerciseIds: exerciseIds));
    _routines = await _db.getRoutines();
    notifyListeners();
  }

  Future<void> deleteRoutine(int id) async {
    await _db.deleteRoutine(id);
    _routines = await _db.getRoutines();
    notifyListeners();
  }

  void _sortActive() => _activeSets.sort((a, b) =>
      a.order != b.order ? a.order.compareTo(b.order) : a.id!.compareTo(b.id!));
}
