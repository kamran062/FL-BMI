import 'dart:convert';

class Workout {
  final int? id;
  final String name;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const Workout({this.id, this.name = '', required this.startedAt, this.finishedAt});

  bool get active => finishedAt == null;
  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);

  Workout copyWith({int? id, String? name, DateTime? finishedAt}) => Workout(
        id: id ?? this.id,
        name: name ?? this.name,
        startedAt: startedAt,
        finishedAt: finishedAt ?? this.finishedAt,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'started_at': startedAt.millisecondsSinceEpoch,
        'finished_at': finishedAt?.millisecondsSinceEpoch,
      };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'] as int?,
        name: m['name'] as String? ?? '',
        startedAt: DateTime.fromMillisecondsSinceEpoch(m['started_at'] as int),
        finishedAt: m['finished_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['finished_at'] as int),
      );
}

/// One set. Weight is stored in kg.
class WorkoutSet {
  final int? id;
  final int workoutId;
  final String exerciseId;
  final int order; // position of the exercise in the workout
  final double weightKg;
  final int reps;
  final bool done;

  const WorkoutSet({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.order,
    this.weightKg = 0,
    this.reps = 0,
    this.done = false,
  });

  WorkoutSet copyWith({double? weightKg, int? reps, bool? done}) => WorkoutSet(
        id: id,
        workoutId: workoutId,
        exerciseId: exerciseId,
        order: order,
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        done: done ?? this.done,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'workout_id': workoutId,
        'exercise_id': exerciseId,
        'exercise_order': order,
        'weight_kg': weightKg,
        'reps': reps,
        'done': done ? 1 : 0,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> m) => WorkoutSet(
        id: m['id'] as int?,
        workoutId: m['workout_id'] as int,
        exerciseId: m['exercise_id'] as String,
        order: m['exercise_order'] as int,
        weightKg: (m['weight_kg'] as num).toDouble(),
        reps: m['reps'] as int,
        done: (m['done'] as int) == 1,
      );
}

class Routine {
  final int? id;
  final String name;
  final List<String> exerciseIds;

  const Routine({this.id, required this.name, required this.exerciseIds});

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'exercise_ids': jsonEncode(exerciseIds),
      };

  factory Routine.fromMap(Map<String, dynamic> m) => Routine(
        id: m['id'] as int?,
        name: m['name'] as String,
        exerciseIds: List<String>.from(jsonDecode(m['exercise_ids'] as String) as List),
      );
}

/// A finished workout with its sets, for history and PRs.
class WorkoutSummary {
  final Workout workout;
  final List<WorkoutSet> sets;
  final int prCount;

  const WorkoutSummary(this.workout, this.sets, {this.prCount = 0});

  List<WorkoutSet> get doneSets => sets.where((s) => s.done).toList();
  double get volumeKg => WorkoutMath.volume(sets);
  int get exerciseCount => sets.map((s) => s.exerciseId).toSet().length;
}

abstract final class WorkoutMath {
  /// Estimated one-rep max (Epley). Reps above 12 are unreliable, so they
  /// are capped there.
  static double estimated1RM(double weightKg, int reps) {
    if (reps <= 0 || weightKg <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps.clamp(1, 12) / 30);
  }

  /// Total kg lifted in completed sets.
  static double volume(Iterable<WorkoutSet> sets) => sets
      .where((s) => s.done)
      .fold(0.0, (sum, s) => sum + s.weightKg * s.reps);

  /// Best estimated 1RM per exercise over completed sets.
  static Map<String, double> bestByExercise(Iterable<WorkoutSet> sets) {
    final best = <String, double>{};
    for (final s in sets.where((s) => s.done)) {
      final e = estimated1RM(s.weightKg, s.reps);
      if (e > (best[s.exerciseId] ?? 0)) best[s.exerciseId] = e;
    }
    return best;
  }

  /// Exercises in [current] that beat [previousBest]. A first-ever set of an
  /// exercise is not counted as a PR (there is nothing to beat yet).
  static Set<String> personalRecords(
      Map<String, double> previousBest, Iterable<WorkoutSet> current) {
    final now = bestByExercise(current);
    return {
      for (final e in now.entries)
        if (previousBest.containsKey(e.key) && e.value > previousBest[e.key]!)
          e.key
    };
  }
}

/// One past workout's result for a single exercise (progress chart).
class ExerciseSession {
  final DateTime date;

  /// Heaviest set by estimated 1RM; 0 for bodyweight-only sessions.
  final double best1RM;
  final double topWeightKg;
  final int topReps;

  /// Most reps in one set and total reps (bodyweight progress).
  final int maxReps;
  final int totalReps;
  final double volumeKg;

  const ExerciseSession({
    required this.date,
    required this.best1RM,
    required this.topWeightKg,
    required this.topReps,
    required this.maxReps,
    required this.totalReps,
    required this.volumeKg,
  });

  /// [exerciseId]'s completed sets per finished workout, oldest first.
  static List<ExerciseSession> fromHistory(
      List<WorkoutSummary> history, String exerciseId) {
    final out = <ExerciseSession>[];
    for (final h in history.reversed) {
      final sets = h.doneSets.where((s) => s.exerciseId == exerciseId).toList();
      if (sets.isEmpty) continue;
      var top = sets.first;
      for (final s in sets) {
        if (WorkoutMath.estimated1RM(s.weightKg, s.reps) >
            WorkoutMath.estimated1RM(top.weightKg, top.reps)) {
          top = s;
        }
      }
      out.add(ExerciseSession(
        date: h.workout.startedAt,
        best1RM: WorkoutMath.estimated1RM(top.weightKg, top.reps),
        topWeightKg: top.weightKg,
        topReps: top.reps,
        maxReps: sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b),
        totalReps: sets.fold(0, (sum, s) => sum + s.reps),
        volumeKg: WorkoutMath.volume(sets),
      ));
    }
    return out;
  }
}
