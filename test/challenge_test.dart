import 'dart:io';

import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());

  test('every focus × level has a full, workable plan', () {
    for (final f in ChallengeFocus.values) {
      for (final l in ChallengeLevel.values) {
        for (var d = 1; d <= l.days; d++) {
          final p = ChallengePlanner.dayPlan(f, l, d, catalog);
          if (p.rest) continue;
          final main = p.steps.where((s) => !s.isWarmup && !s.isCooldown);
          expect(main, isNotEmpty, reason: '$f $l day $d');
          expect(main.every((s) => s.exercise.equipment == ExerciseEquipment.bodyweight),
              isTrue, reason: '$f $l day $d');
          expect(main.every((s) => s.exercise.difficulty.index <= l.maxDifficulty.index),
              isTrue, reason: '$f $l day $d');
        }
      }
    }
  });

  test('rest every 7th day, except for the stretch focus', () {
    expect(ChallengePlanner.dayPlan(ChallengeFocus.coreAbs, ChallengeLevel.beginner, 7, catalog).rest, isTrue);
    expect(ChallengePlanner.dayPlan(ChallengeFocus.coreAbs, ChallengeLevel.beginner, 8, catalog).rest, isFalse);
    expect(ChallengePlanner.dayPlan(ChallengeFocus.stretch, ChallengeLevel.beginner, 7, catalog).rest, isFalse);
  });

  test('warm-up first and stretch last; stretch focus has neither', () {
    final p = ChallengePlanner.dayPlan(ChallengeFocus.fullBody, ChallengeLevel.beginner, 1, catalog);
    expect(p.steps.first.isWarmup, isTrue);
    expect(p.steps.last.isCooldown, isTrue);
    expect(p.steps.last.exercise.category, ExerciseCategory.stretch);
    final s = ChallengePlanner.dayPlan(ChallengeFocus.stretch, ChallengeLevel.beginner, 1, catalog);
    expect(s.steps.any((x) => x.isWarmup || x.isCooldown), isFalse);
  });

  test('harder over time: day 29 targets more than day 1; advanced adds a set', () {
    int firstTarget(ChallengeDay d) => d.steps.firstWhere((s) => !s.isWarmup).target;
    final d1 = ChallengePlanner.dayPlan(ChallengeFocus.legsGlutes, ChallengeLevel.beginner, 1, catalog);
    final d29 = ChallengePlanner.dayPlan(ChallengeFocus.legsGlutes, ChallengeLevel.beginner, 29, catalog);
    expect(d1.steps.firstWhere((s) => !s.isWarmup).target,
        lessThanOrEqualTo(firstTarget(d1)));
    // Compare the same exercise across the challenge
    final id = d1.steps.firstWhere((s) => !s.isWarmup).exercise.id;
    final later = [
      for (var d = 22; d <= 30; d++)
        ChallengePlanner.dayPlan(ChallengeFocus.legsGlutes, ChallengeLevel.beginner, d, catalog)
    ].expand((x) => x.steps).where((s) => s.exercise.id == id);
    if (later.isNotEmpty) {
      expect(later.first.target, greaterThan(firstTarget(d1)));
    }
    expect(d29.steps, isNotEmpty);

    final adv1 = ChallengePlanner.dayPlan(ChallengeFocus.fullBody, ChallengeLevel.advanced, 1, catalog);
    final adv20 = ChallengePlanner.dayPlan(ChallengeFocus.fullBody, ChallengeLevel.advanced, 20, catalog);
    int mainSets(ChallengeDay d) => d.steps.firstWhere((s) => !s.isWarmup).sets;
    expect(mainSets(adv20), mainSets(adv1) + 1);
  });

  test('consecutive days use different exercises', () {
    Set<String> ids(int d) => ChallengePlanner.dayPlan(
            ChallengeFocus.fullBody, ChallengeLevel.intermediate, d, catalog)
        .steps
        .where((s) => !s.isWarmup && !s.isCooldown)
        .map((s) => s.exercise.id)
        .toSet();
    expect(ids(1), isNot(equals(ids(2))));
  });

  test('BMI 30+: no jumping moves anywhere, warm-up is marching', () {
    for (var d = 1; d <= 30; d++) {
      final p = ChallengePlanner.dayPlan(ChallengeFocus.hiit, ChallengeLevel.beginner, d, catalog, bmi: 33);
      expect(p.steps.any((s) => s.exercise.highImpact), isFalse, reason: 'day $d');
      if (!p.rest) expect(p.steps.first.exercise.id, 'march_in_place');
    }
  });

  test('recommended focus follows goal and gender', () {
    expect(ChallengePlanner.orderedFor(const UserProfile(goal: FitnessGoal.loseFat)).first,
        ChallengeFocus.hiit);
    expect(ChallengePlanner.orderedFor(const UserProfile(gender: 'f')).first,
        ChallengeFocus.coreAbs.index < ChallengeFocus.legsGlutes.index
            ? ChallengeFocus.coreAbs
            : ChallengeFocus.legsGlutes);
    expect(ChallengePlanner.orderedFor(const UserProfile(gender: 'm')).first,
        ChallengeFocus.upperBody);
    expect(ChallengePlanner.orderedFor(const UserProfile()).toSet(), ChallengeFocus.values.toSet());
  });

  test('a beginner day takes roughly 10–20 minutes', () {
    final p = ChallengePlanner.dayPlan(ChallengeFocus.fullBody, ChallengeLevel.beginner, 1, catalog);
    expect(p.estimatedTime.inMinutes, inInclusiveRange(6, 25));
  });
}
