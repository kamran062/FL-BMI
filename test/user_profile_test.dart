import 'package:bmi_health/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.heightInCm', () {
    test('passes centimetres through', () {
      expect(const UserProfile(height: 172).heightInCm, 172);
    });

    test('converts total inches', () {
      const p = UserProfile(height: 70, heightUnit: 'ft');
      expect(p.heightInCm, closeTo(177.8, 0.01));
    });

    test('reads legacy feet.inches values below 12', () {
      // Legacy format stores inches ×100 in the decimals
      const fiveTen = UserProfile(height: 5.10, heightUnit: 'ft');
      const fiveEight = UserProfile(height: 5.08, heightUnit: 'ft');
      expect(fiveTen.heightInCm, closeTo(70 * 2.54, 0.01));
      expect(fiveEight.heightInCm, closeTo(68 * 2.54, 0.01));
    });
  });

  group('UserProfile.weightInKg', () {
    test('passes kilograms through', () {
      expect(const UserProfile(weight: 70).weightInKg, 70);
    });

    test('converts pounds', () {
      const p = UserProfile(weight: 154, weightUnit: 'lbs');
      expect(p.weightInKg, closeTo(69.85, 0.01));
    });
  });

  test('toMap / fromMap round-trip keeps every field', () {
    const p = UserProfile(
      height: 65,
      heightUnit: 'ft',
      weight: 150,
      weightUnit: 'lbs',
      age: 42,
      gender: 'm',
    );
    final back = UserProfile.fromMap(p.toMap());
    expect(back.height, p.height);
    expect(back.heightUnit, p.heightUnit);
    expect(back.weight, p.weight);
    expect(back.weightUnit, p.weightUnit);
    expect(back.age, p.age);
    expect(back.gender, p.gender);
  });
}
