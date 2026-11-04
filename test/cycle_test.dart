import 'package:bmi_health/features/cycle/domain/cycle.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime d(int month, int day) => DateTime(2026, month, day);
Period p(int m, int day, {int len = 5}) =>
    Period(start: d(m, day), end: d(m, day).add(Duration(days: len - 1)));

void main() {
  test('no periods → no prediction', () {
    expect(CyclePredictor.status(const [], d(11, 4)), isNull);
  });

  test('one period: default 28-day cycle, phases by day', () {
    final s = CyclePredictor.status([p(11, 1)], d(11, 3))!;
    expect(s.day, 3);
    expect(s.phase, CyclePhase.menstrual);
    expect(s.nextPeriod, d(11, 29));
    expect(s.irregular, isFalse);

    expect(CyclePredictor.status([p(11, 1)], d(11, 8))!.phase, CyclePhase.follicular);
    expect(CyclePredictor.status([p(11, 1)], d(11, 14))!.phase, CyclePhase.ovulation);
    expect(CyclePredictor.status([p(11, 1)], d(11, 20))!.phase, CyclePhase.luteal);
  });

  test('regular 30-day cycles predict 30 days with a narrow window', () {
    final periods = [p(7, 3), p(8, 2), p(9, 1), p(10, 1), p(10, 31)];
    final s = CyclePredictor.status(periods, d(11, 4))!;
    expect(s.cycleLength, 30);
    expect(s.nextPeriod, d(11, 30));
    expect(s.nextLatest.difference(s.nextEarliest).inDays, lessThanOrEqualTo(4));
  });

  test('irregular cycles widen the window and are flagged', () {
    // 24, 38, 27, 35 days
    final periods = [p(6, 1), p(6, 25), p(8, 2), p(8, 29), p(10, 3)];
    final s = CyclePredictor.status(periods, d(10, 10))!;
    expect(s.irregular, isTrue);
    expect(s.nextLatest.difference(s.nextEarliest).inDays, greaterThanOrEqualTo(14));
  });

  test('one missed log (a 60-day gap) is not averaged in as a normal cycle', () {
    // 28, 28, then a 56-day gap (a period wasn't logged), then 28
    final periods = [p(3, 1), p(3, 29), p(4, 26), p(6, 21), p(7, 19)];
    final lengths = CyclePredictor.cycleLengths(periods);
    expect(lengths, [28, 28, 56, 28]);
    // median resists the outlier
    final s = CyclePredictor.status(periods, d(7, 25))!;
    expect(s.cycleLength, 28);
    expect(s.irregular, isFalse);
  });

  test('late when past the latest likely start', () {
    final s = CyclePredictor.status([p(9, 1), p(9, 29), p(10, 27)], d(12, 1))!;
    expect(s.late, isTrue);
  });

  test('ongoing period without an end date stays menstrual', () {
    final s = CyclePredictor.status([Period(start: d(11, 1))], d(11, 7))!;
    expect(s.phase, CyclePhase.menstrual);
  });

  test('round-trips through the database map', () {
    final m = p(11, 1).toMap();
    expect(m['start'], '2026-11-01');
    expect(Period.fromMap({...m, 'id': 3}).end, d(11, 5));
  });
}
