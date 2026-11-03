import 'dart:io';

import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:flutter_test/flutter_test.dart';

List<WorkoutSet> session(double kg, List<int> reps) => [
      for (final r in reps)
        WorkoutSet(workoutId: 1, exerciseId: 'x', order: 0,
            weightKg: kg, reps: r, done: true)
    ];

void main() {
  const bar = ExerciseEquipment.barbell;

  test('first time: start at the bottom of the range', () {
    expect(Progression.suggest(const [], bar).reason, SuggestionReason.firstTime);
  });

  test('all sets at 12 reps → add 2.5 kg and drop to 8', () {
    final s = Progression.suggest([session(60, [12, 12, 12])], bar);
    expect(s.reason, SuggestionReason.increase);
    expect(s.weightKg, 62.5);
    expect(s.reps, 8);
  });

  test('inside the range → one more rep at the same weight', () {
    final s = Progression.suggest([session(60, [10, 9, 9])], bar);
    expect(s.reason, SuggestionReason.addRep);
    expect(s.weightKg, 60);
    expect(s.reps, 10); // weakest set + 1
  });

  test('missing the range twice at the same weight → 10 % deload', () {
    final s = Progression.suggest(
        [session(100, [6, 5, 5]), session(100, [6, 6, 5])], bar);
    expect(s.reason, SuggestionReason.deload);
    expect(s.weightKg, 90);
  });

  test('bodyweight progresses by reps only, past 12', () {
    final s = Progression.suggest(
        [session(0, [15, 15])], ExerciseEquipment.bodyweight);
    expect(s.reason, SuggestionReason.addRep);
    expect(s.reps, 16);
  });

  test('every program uses only exercises from the catalog', () {
    final catalog = ExerciseCatalog.parse(
        File('assets/exercises/catalog.json').readAsStringSync());
    for (final p in Programs.all) {
      for (final d in p.days) {
        for (final id in d.exerciseIds) {
          expect(catalog.byId(id), isNotNull, reason: '${p.id}: $id');
        }
      }
      expect(p.nameIn('ur'), isNotEmpty);
    }
  });

  test('home users only see the bodyweight program', () {
    final home = equipmentFor(null).length; // gym → all
    expect(home, ExerciseEquipment.values.length);
    final none = {ExerciseEquipment.bodyweight};
    expect(Programs.all.where((p) => p.fits(none)).map((p) => p.id),
        ['fullbody_home']);
  });

  test('weekly sets: primary counts 1, secondary 0.5', () {
    final catalog = ExerciseCatalog.parse(
        File('assets/exercises/catalog.json').readAsStringSync());
    WorkoutSet set(String id) => WorkoutSet(
        workoutId: 1, exerciseId: id, order: 0, weightKg: 60, reps: 10, done: true);
    // bench: chest + triceps/shoulders
    final v = MuscleVolume.weeklySets(
        [set('barbell_bench_press'), set('barbell_bench_press')], catalog);
    expect(v[Muscle.chest], 2);
    expect(v[Muscle.triceps], 1);
    expect(v[Muscle.quads], 0);
    expect(MuscleVolume.underTrained(v), contains(Muscle.quads));
    expect(MuscleVolume.underTrained(v), contains(Muscle.chest)); // 2 < 4
  });
}

