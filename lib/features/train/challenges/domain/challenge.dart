import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';

/// Home Challenges (no equipment): pick a level and a focus, then follow a
/// day-by-day plan that gets a little harder each week.
enum ChallengeLevel {
  beginner(30, Difficulty.beginner, 4, 2),
  intermediate(45, Difficulty.intermediate, 5, 3),
  advanced(60, Difficulty.advanced, 6, 3);

  const ChallengeLevel(this.days, this.maxDifficulty, this.exercisesPerDay, this.baseSets);
  final int days;
  final Difficulty maxDifficulty;
  final int exercisesPerDay;
  final int baseSets;

  ChallengeLevel? get previous => index == 0 ? null : ChallengeLevel.values[index - 1];
}

enum ChallengeFocus {
  fullBody,
  upperBody,
  coreAbs,
  legsGlutes,
  hiit,
  stretch;

  /// Which catalog exercises belong to this focus.
  bool includes(Exercise e) => switch (this) {
        ChallengeFocus.fullBody => e.category == ExerciseCategory.strength,
        ChallengeFocus.upperBody => e.category == ExerciseCategory.strength &&
            const {Muscle.chest, Muscle.back, Muscle.shoulders, Muscle.triceps, Muscle.biceps}
                .contains(e.primary),
        ChallengeFocus.coreAbs =>
          e.category == ExerciseCategory.strength && e.primary == Muscle.core,
        ChallengeFocus.legsGlutes => e.category == ExerciseCategory.strength &&
            const {Muscle.quads, Muscle.hamstrings, Muscle.glutes, Muscle.calves}
                .contains(e.primary),
        ChallengeFocus.hiit => e.category == ExerciseCategory.cardio ||
            (e.category == ExerciseCategory.strength && e.highImpact),
        ChallengeFocus.stretch => e.category == ExerciseCategory.stretch,
      };

  bool get hasRestDays => this != ChallengeFocus.stretch;
}

/// One exercise in a day: sets × target reps (or seconds when [timed]).
class ChallengeStep {
  final Exercise exercise;
  final int sets;
  final int target;
  final bool timed;
  final int restSec;

  /// Warm-up and cool-down steps are a single short block.
  final bool isWarmup;
  final bool isCooldown;

  const ChallengeStep(this.exercise, this.sets, this.target,
      {required this.timed, required this.restSec, this.isWarmup = false, this.isCooldown = false});

  Prescription get asPrescription => Prescription(
      sets: sets, repMin: target, repMax: target, timed: timed, restSec: restSec);
}

class ChallengeDay {
  final int day;
  final bool rest;
  final List<ChallengeStep> steps;
  const ChallengeDay(this.day, this.steps, {this.rest = false});

  /// Rough length: ~3 s per rep (or the hold time) plus rests.
  Duration get estimatedTime => Duration(
      seconds: steps.fold(0, (s, st) {
        final work = st.timed ? st.target : st.target * 3;
        return s + st.sets * (work + st.restSec);
      }));
}

abstract final class ChallengePlanner {
  static String key(ChallengeFocus f, ChallengeLevel l) => '${f.name}_${l.name}';

  static const jointFriendlyBmi = 30.0;

  /// The plan for [day] (1-based). Same inputs → same plan.
  static ChallengeDay dayPlan(
    ChallengeFocus focus,
    ChallengeLevel level,
    int day,
    ExerciseCatalog catalog, {
    double? bmi,
  }) {
    assert(day >= 1 && day <= level.days);
    if (focus.hasRestDays && day % 7 == 0) return ChallengeDay(day, const [], rest: true);

    final lowImpact = (bmi ?? 0) >= jointFriendlyBmi;
    bool allowed(Exercise e) =>
        e.equipment == ExerciseEquipment.bodyweight &&
        e.difficulty.index <= level.maxDifficulty.index &&
        !(lowImpact && e.highImpact);

    final warmup = focus == ChallengeFocus.stretch ? null : _warmup(catalog, lowImpact);
    // The warm-up move is not repeated in the main block.
    final pool = catalog.exercises
        .where((e) => focus.includes(e) && allowed(e) && e.id != warmup?.exercise.id)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (pool.isEmpty) return ChallengeDay(day, const []);

    // Rotate through the pool so consecutive days differ.
    final n = level.exercisesPerDay.clamp(1, pool.length);
    final trainingDay = focus.hasRestDays ? day - day ~/ 7 : day;
    final start = ((trainingDay - 1) * 2) % pool.length;
    final picked = [for (var i = 0; i < n; i++) pool[(start + i) % pool.length]];

    // Progress from the bottom to the top of each exercise's range across
    // the challenge; advanced adds a set from week 3.
    final progress = level.days <= 1 ? 1.0 : (day - 1) / (level.days - 1);
    int targetFor(Prescription p) =>
        (p.repMin + (p.repMax - p.repMin) * progress).round().clamp(p.repMin, p.repMax);
    final week = (day - 1) ~/ 7 + 1;
    final extraSet = level == ChallengeLevel.advanced && week >= 3 ? 1 : 0;

    final steps = <ChallengeStep?>[
      warmup,
      for (final e in picked)
        ChallengeStep(
          e,
          (focus == ChallengeFocus.stretch ? e.prescription.sets : level.baseSets) + extraSet,
          targetFor(e.prescription),
          timed: e.prescription.timed,
          restSec: e.prescription.restSec.clamp(15, 90),
        ),
      if (focus != ChallengeFocus.stretch) _cooldown(catalog, picked, day),
    ].whereType<ChallengeStep>().toList();
    return ChallengeDay(day, steps);
  }

  static ChallengeStep? _warmup(ExerciseCatalog c, bool lowImpact) {
    final e = c.byId(lowImpact ? 'march_in_place' : 'jumping_jack') ?? c.byId('march_in_place');
    if (e == null) return null;
    return ChallengeStep(e, 1, 30, timed: true, restSec: 15, isWarmup: true);
  }

  /// A stretch for the muscle worked most, rotating with the day.
  static ChallengeStep? _cooldown(ExerciseCatalog c, List<Exercise> worked, int day) {
    final stretches = c.exercises.where((e) => e.category == ExerciseCategory.stretch).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (stretches.isEmpty) return null;
    final muscles = worked.map((e) => e.primary).toSet();
    final matching = stretches.where((s) => muscles.contains(s.primary)).toList();
    final list = matching.isEmpty ? stretches : matching;
    return ChallengeStep(list[day % list.length], 1, 30, timed: true, restSec: 0, isCooldown: true);
  }

  /// Focus order for this user: recommended first (by goal and gender);
  /// every focus stays available to everyone.
  static List<ChallengeFocus> orderedFor(UserProfile p) {
    int score(ChallengeFocus f) {
      var s = 0;
      if (p.goal == FitnessGoal.loseFat && f == ChallengeFocus.hiit) s += 3;
      if (p.goal == FitnessGoal.buildMuscle && f == ChallengeFocus.upperBody) s += 2;
      if (p.gender == 'f' && (f == ChallengeFocus.legsGlutes || f == ChallengeFocus.coreAbs)) s += 2;
      if (p.gender == 'm' && f == ChallengeFocus.upperBody) s += 2;
      if (f == ChallengeFocus.fullBody) s += 1;
      return s;
    }
    return [...ChallengeFocus.values]..sort((a, b) {
        final c = score(b).compareTo(score(a));
        return c != 0 ? c : a.index.compareTo(b.index);
      });
  }
}
