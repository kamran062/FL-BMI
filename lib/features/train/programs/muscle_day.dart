import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';

/// One-tap workouts by body part ("chest day").
enum MuscleDay {
  chest([Muscle.chest]),
  back([Muscle.back]),
  shoulders([Muscle.shoulders]),
  arms([Muscle.biceps, Muscle.triceps]),
  legs([Muscle.quads, Muscle.hamstrings, Muscle.glutes, Muscle.calves]),
  glutes([Muscle.glutes, Muscle.hamstrings]),
  core([Muscle.core]);

  const MuscleDay(this.muscles);
  final List<Muscle> muscles;
}

class MuscleDayPlan {
  final MuscleDay day;
  final List<Exercise> exercises;

  /// True when jumping/impact moves were left out because of BMI.
  final bool jointFriendly;

  const MuscleDayPlan(this.day, this.exercises, {this.jointFriendly = false});

  int get totalSets => exercises.fold(0, (s, e) => s + e.prescription.sets);

  /// Rough length: work + rest per set.
  Duration get estimatedTime => Duration(
      seconds: exercises.fold(
          0, (s, e) => s + e.prescription.sets * (45 + e.prescription.restSec)));
}

/// Builds a workout for a body part from the catalog (ROADMAP 3.1 extension).
///
/// Compound lifts first, then accessories; respects the user's equipment
/// and experience; with a BMI of 30+ jumping moves are swapped for
/// joint-friendly ones. Deterministic, so the same profile gets the same
/// plan (users can still swap exercises in the logger).
abstract final class MuscleDayBuilder {
  static const jointFriendlyBmi = 30.0;

  static MuscleDayPlan build(
    MuscleDay day,
    ExerciseCatalog catalog, {
    required Set<ExerciseEquipment> equipment,
    Experience? experience,
    double? bmi,
  }) {
    final level = experience ?? Experience.beginner;
    final maxDiff = switch (level) {
      Experience.beginner => Difficulty.beginner,
      Experience.intermediate => Difficulty.intermediate,
      Experience.advanced => Difficulty.advanced,
    };
    final count = switch (level) {
      Experience.beginner => 4,
      Experience.intermediate => 5,
      Experience.advanced => 6,
    };
    final jointFriendly = (bmi ?? 0) >= jointFriendlyBmi;

    bool ok(Exercise e) =>
        equipment.contains(e.equipment) &&
        e.difficulty.index <= maxDiff.index &&
        !(e.highImpact && (jointFriendly || level == Experience.beginner));

    // Heavier, more productive tools first for experienced lifters;
    // machines and dumbbells first for beginners (easier to learn safely).
    int toolRank(ExerciseEquipment q) => level == Experience.beginner
        ? const [ExerciseEquipment.machine, ExerciseEquipment.dumbbell, ExerciseEquipment.cable,
                 ExerciseEquipment.bodyweight, ExerciseEquipment.band, ExerciseEquipment.kettlebell,
                 ExerciseEquipment.barbell].indexOf(q)
        : const [ExerciseEquipment.barbell, ExerciseEquipment.dumbbell, ExerciseEquipment.machine,
                 ExerciseEquipment.cable, ExerciseEquipment.kettlebell, ExerciseEquipment.bodyweight,
                 ExerciseEquipment.band].indexOf(q);

    bool compound(Exercise e) => e.secondary.isNotEmpty;

    // Per-muscle queues: compounds first, then by tool, then by id.
    final queues = <Muscle, List<Exercise>>{
      for (final m in day.muscles)
        m: catalog.exercises.where((e) => e.primary == m && ok(e)).toList()
          ..sort((a, b) {
            final c = (compound(a) ? 0 : 1).compareTo(compound(b) ? 0 : 1);
            if (c != 0) return c;
            final t = toolRank(a.equipment).compareTo(toolRank(b.equipment));
            return t != 0 ? t : a.id.compareTo(b.id);
          })
    };

    // Round-robin across the day's muscles; avoid the same tool twice in a
    // row within a muscle when there is a choice.
    final picked = <Exercise>[];
    final lastTool = <Muscle, ExerciseEquipment>{};
    while (picked.length < count && queues.values.any((q) => q.isNotEmpty)) {
      for (final m in day.muscles) {
        if (picked.length >= count) break;
        final q = queues[m]!;
        if (q.isEmpty) continue;
        final i = q.indexWhere((e) => e.equipment != lastTool[m]);
        final next = q.removeAt(i < 0 ? 0 : i);
        lastTool[m] = next.equipment;
        picked.add(next);
      }
    }
    // Big lifts first in the session.
    picked.sort((a, b) => (compound(a) ? 0 : 1).compareTo(compound(b) ? 0 : 1));
    return MuscleDayPlan(day, picked, jointFriendly: jointFriendly);
  }
}
