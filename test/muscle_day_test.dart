import 'dart:io';

import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/muscle_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());
  final gym = ExerciseEquipment.values.toSet();
  final home = equipmentFor(Equipment.none);

  test('catalog: every exercise has Urdu steps, tips, mistakes and a prescription', () {
    expect(catalog.exercises.length, greaterThanOrEqualTo(99));
    for (final e in catalog.exercises) {
      expect(e.stepsIn('ur'), isNotEmpty, reason: e.id);
      expect(e.stepsIn('ur').length, e.stepsIn('en').length, reason: e.id);
      expect(e.tipsIn('ur'), isNotEmpty, reason: e.id);
      expect(e.mistakesIn('en'), isNotEmpty, reason: e.id);
      expect(e.prescription.repMin, lessThanOrEqualTo(e.prescription.repMax), reason: e.id);
      expect(e.prescription.restSec, inInclusiveRange(10, 240), reason: e.id); // stretches: 15 s
    }
  });

  test('chest day in the gym: compound lifts first, no duplicates', () {
    final p = MuscleDayBuilder.build(MuscleDay.chest, catalog,
        equipment: gym, experience: Experience.intermediate);
    expect(p.exercises, hasLength(5));
    expect(p.exercises.map((e) => e.id).toSet(), hasLength(5));
    expect(p.exercises.every((e) => e.primary == Muscle.chest), isTrue);
    expect(p.exercises.first.secondary, isNotEmpty); // a compound press first
    expect(p.exercises.first.equipment, ExerciseEquipment.barbell);
    expect(p.exercises.every((e) => e.difficulty != Difficulty.advanced), isTrue);
  });

  test('beginner gets 4 beginner exercises, starting on machines/dumbbells', () {
    final p = MuscleDayBuilder.build(MuscleDay.back, catalog,
        equipment: gym, experience: Experience.beginner);
    expect(p.exercises, hasLength(4));
    expect(p.exercises.every((e) => e.difficulty == Difficulty.beginner), isTrue);
    expect(p.exercises.first.equipment, isNot(ExerciseEquipment.barbell));
  });

  test('home user only gets bodyweight exercises', () {
    final p = MuscleDayBuilder.build(MuscleDay.chest, catalog,
        equipment: home, experience: Experience.intermediate);
    expect(p.exercises, isNotEmpty);
    expect(p.exercises.every((e) => e.equipment == ExerciseEquipment.bodyweight), isTrue);
  });

  test('BMI 30+: no jumping moves, plan marked joint-friendly', () {
    final normal = MuscleDayBuilder.build(MuscleDay.legs, catalog,
        equipment: home, experience: Experience.advanced, bmi: 24);
    final high = MuscleDayBuilder.build(MuscleDay.legs, catalog,
        equipment: home, experience: Experience.advanced, bmi: 32);
    expect(normal.jointFriendly, isFalse);
    expect(high.jointFriendly, isTrue);
    expect(high.exercises.any((e) => e.highImpact), isFalse);
    expect(normal.exercises.length, high.exercises.length);
  });

  test('multi-muscle days cover each muscle', () {
    final arms = MuscleDayBuilder.build(MuscleDay.arms, catalog,
        equipment: gym, experience: Experience.intermediate);
    expect(arms.exercises.map((e) => e.primary).toSet(), {Muscle.biceps, Muscle.triceps});
    final legs = MuscleDayBuilder.build(MuscleDay.legs, catalog,
        equipment: gym, experience: Experience.advanced);
    expect(legs.exercises.map((e) => e.primary).toSet(),
        containsAll([Muscle.quads, Muscle.hamstrings, Muscle.glutes]));
  });

  test('same profile, same plan; time estimate is sensible', () {
    final a = MuscleDayBuilder.build(MuscleDay.shoulders, catalog, equipment: gym);
    final b = MuscleDayBuilder.build(MuscleDay.shoulders, catalog, equipment: gym);
    expect(a.exercises.map((e) => e.id), b.exercises.map((e) => e.id));
    expect(a.estimatedTime.inMinutes, inInclusiveRange(15, 75));
  });

  test('alternatives: same muscle, available equipment', () {
    final bench = catalog.byId('barbell_bench_press')!;
    final alts = catalog.alternativesFor(bench, available: gym);
    expect(alts, hasLength(3));
    expect(alts.every((e) => e.primary == Muscle.chest && e.id != bench.id), isTrue);
    final atHome = catalog.alternativesFor(bench, available: home);
    expect(atHome.every((e) => e.equipment == ExerciseEquipment.bodyweight), isTrue);
  });
}
