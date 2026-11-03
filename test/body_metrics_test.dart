import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

const _in = 2.54;
final _d0 = DateTime(2026, 11, 1);

void main() {
  group('BodyFat.navy', () {
    // Worked examples from the original inch-based US Navy formula:
    //   male:   waist 34, neck 15, height 70 in          → 17.5 %
    //   female: waist 30, hips 38, neck 13, height 65 in → 28.6 %
    // The metric form agrees within ~0.3 points.
    test('male matches the US Navy worked example', () {
      final bf = BodyFat.navy(
        sex: Sex.male, heightCm: 70 * _in, neck: 15 * _in, waist: 34 * _in,
      );
      expect(bf, closeTo(17.5, 0.3));
    });

    test('female matches the US Navy worked example', () {
      final bf = BodyFat.navy(
        sex: Sex.female, heightCm: 65 * _in,
        neck: 13 * _in, waist: 30 * _in, hips: 38 * _in,
      );
      expect(bf, closeTo(28.5, 0.4));
    });

    test('female needs hips; male does not', () {
      expect(BodyFat.navy(sex: Sex.female, heightCm: 165, neck: 33, waist: 76),
          isNull);
      expect(BodyFat.navy(sex: Sex.male, heightCm: 178, neck: 38, waist: 86),
          isNotNull);
    });

    test('impossible inputs return null instead of nonsense', () {
      // waist smaller than neck
      expect(BodyFat.navy(sex: Sex.male, heightCm: 178, neck: 40, waist: 35),
          isNull);
      // missing values
      expect(BodyFat.navy(sex: Sex.male, heightCm: 178, waist: 86), isNull);
      // typo-sized waist → result far outside human range
      expect(BodyFat.navy(sex: Sex.male, heightCm: 178, neck: 38, waist: 400),
          isNull);
    });

    test('forProfile uses the profile formula basis for "other"', () {
      final m = Measurement(date: _d0, neck: 34, waist: 80, hips: 98);
      const asFemale = UserProfile(gender: 'o', formulaBasis: Sex.female);
      const asMale = UserProfile(gender: 'o', formulaBasis: Sex.male);
      expect(BodyFat.forProfile(asFemale, m), isNot(BodyFat.forProfile(asMale, m)));
      expect(BodyFat.forProfile(asFemale, null), isNull);
    });
  });

  group('movingAverage', () {
    WeightLog log(int day, double kg) =>
        WeightLog(date: DateTime(2026, 11, day, 8), weightKg: kg);

    test('averages the last 7 calendar days', () {
      final logs = [
        log(1, 80), log(2, 82), log(3, 81), // all within one week
        log(10, 78), // days 1–3 fall out of its window
      ];
      expect(movingAverage(logs), [80, 81, 81, 78]);
    });

    test('empty input gives empty output', () {
      expect(movingAverage(const []), isEmpty);
    });
  });

  test('measurement map round-trip keeps missing fields as null', () {
    final m = Measurement(date: _d0, waist: 81.5, neck: 36);
    final back = Measurement.fromMap({...m.toMap(), 'id': 3});
    expect(back.waist, 81.5);
    expect(back.neck, 36);
    expect(back.hips, isNull);
    expect(back.id, 3);
  });

  test('female profiles are asked for hips before neck', () {
    final f = measureFieldsFor(Sex.female);
    expect(f.indexOf(MeasureField.hips), lessThan(f.indexOf(MeasureField.neck)));
    expect(measureFieldsFor(Sex.male), contains(MeasureField.hips));
  });
}
