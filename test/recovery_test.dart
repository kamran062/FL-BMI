import 'package:bmi_health/features/recovery/domain/recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recovery score', () {
    test('nothing to go on → no score', () {
      expect(Recovery.compute(const RecoveryInputs()), isNull);
    });

    test('well rested with a watch → train hard', () {
      final r = Recovery.compute(const RecoveryInputs(
        sleepHours: 8.2, restingHr: 56, restingHrBaseline: 57,
        hrv: 62, hrvBaseline: 60, recentSets: 10, usualSets: 12, soreness: 1,
      ))!;
      expect(r.score, greaterThanOrEqualTo(90));
      expect(r.advice, TrainingAdvice.trainHard);
      expect(r.limiter, isNull);
    });

    test('no wearable: sleep, load and check-in still give a score', () {
      final r = Recovery.compute(const RecoveryInputs(
          sleepHours: 7, recentSets: 12, usualSets: 12, soreness: 2))!;
      expect(r.used, {RecoveryFactor.sleep, RecoveryFactor.load, RecoveryFactor.soreness});
      expect(r.score, inInclusiveRange(70, 90));
    });

    test('illness spike: resting HR far above baseline caps the score', () {
      final r = Recovery.compute(const RecoveryInputs(
        sleepHours: 8.5, restingHr: 70, restingHrBaseline: 57, soreness: 1,
      ))!;
      expect(r.score, lessThanOrEqualTo(45));
      expect(r.advice, TrainingAdvice.rest);
      expect(r.limiter, RecoveryFactor.restingHr);
    });

    test('overtraining: double the usual load and sore → light or rest', () {
      final r = Recovery.compute(const RecoveryInputs(
          sleepHours: 7.5, recentSets: 30, usualSets: 12, soreness: 4))!;
      expect(r.advice, isNot(TrainingAdvice.trainHard));
      expect(r.limiter, RecoveryFactor.load);
    });

    test('short sleep is named as the limiter', () {
      final r = Recovery.compute(const RecoveryInputs(sleepHours: 4.5, soreness: 2))!;
      expect(r.limiter, RecoveryFactor.sleep);
      expect(r.advice, TrainingAdvice.rest);
    });
  });

  group('Sleep', () {
    DateTime t(int day, int h, [int m = 0]) => DateTime(2026, 11, day, h, m);

    test('watch segments are merged into nights; naps ignored', () {
      final nights = SleepSummary.mergeSegments([
        SleepNight(t(1, 23), t(2, 3)),
        SleepNight(t(2, 3, 20), t(2, 7)), // woke 20 min → same night
        SleepNight(t(2, 14), t(2, 15)), // nap
      ]);
      expect(nights, hasLength(1));
      expect(nights.single.duration, const Duration(hours: 8));
      expect(nights.single.wakeDay, DateTime(2026, 11, 2));
    });

    test('average, debt and regular bedtimes across midnight', () {
      final s = SleepSummary.of([
        SleepNight(t(1, 23, 30), t(2, 7)), // 7.5 h
        SleepNight(t(3, 0, 15), t(3, 7)), // 6.75 h, bedtime after midnight
        SleepNight(t(3, 23, 45), t(4, 8)), // 8.25 h
      ])!;
      expect(s.nights, 3);
      expect(s.average, const Duration(hours: 7, minutes: 30));
      expect(s.debt, const Duration(minutes: 30 + 75));
      expect(s.regular, isTrue); // 23:30 / 00:15 / 23:45 are close
    });

    test('irregular bedtimes are flagged', () {
      final s = SleepSummary.of([
        SleepNight(t(1, 21), t(2, 5)),
        SleepNight(t(3, 2), t(3, 10)),
      ])!;
      expect(s.regular, isFalse);
    });
  });
}
