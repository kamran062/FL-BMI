import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BmiCalculator.calculate', () {
    test('computes weight / height²', () {
      expect(BmiCalculator.calculate(70, 175), closeTo(22.86, 0.01));
      expect(BmiCalculator.calculate(100, 180), closeTo(30.86, 0.01));
    });

    test('returns 0 for non-positive height', () {
      expect(BmiCalculator.calculate(70, 0), 0);
      expect(BmiCalculator.calculate(70, -10), 0);
    });
  });

  group('BmiCalculator.category', () {
    test('uses WHO adult cut-offs at the exact boundaries', () {
      expect(BmiCalculator.category(18.49).key, 'under');
      expect(BmiCalculator.category(18.5).key, 'normal');
      expect(BmiCalculator.category(24.99).key, 'normal');
      expect(BmiCalculator.category(25.0).key, 'over');
      expect(BmiCalculator.category(29.99).key, 'over');
      expect(BmiCalculator.category(30.0).key, 'obese');
    });

    test('every category has advice', () {
      for (final key in ['under', 'normal', 'over', 'obese']) {
        final advice = BmiCalculator.advice(key);
        expect(advice['headline'], isNotEmpty);
        expect(advice['steps'], isNotEmpty);
      }
    });
  });

  group('BmiCalculator.validate', () {
    test('accepts realistic values', () {
      expect(BmiCalculator.validate(heightCm: 172, weightKg: 70), isNull);
    });

    test('accepts the exact range limits', () {
      expect(BmiCalculator.validate(heightCm: 50, weightKg: 2), isNull);
      expect(BmiCalculator.validate(heightCm: 272, weightKg: 635), isNull);
    });

    test('rejects heights outside the range', () {
      expect(BmiCalculator.validate(heightCm: 1, weightKg: 70), contains('height'));
      expect(BmiCalculator.validate(heightCm: 300, weightKg: 70), contains('height'));
      expect(BmiCalculator.validate(heightCm: double.nan, weightKg: 70), contains('height'));
    });

    test('rejects weights outside the range', () {
      expect(BmiCalculator.validate(heightCm: 172, weightKg: 0), contains('weight'));
      expect(BmiCalculator.validate(heightCm: 172, weightKg: 1000), contains('weight'));
    });
  });
}
