import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mifflin-St Jeor matches reference values', () {
    // 80 kg, 180 cm, 30 y male: 800 + 1125 − 150 + 5 = 1780
    expect(Nutrition.bmr(sex: Sex.male, weightKg: 80, heightCm: 180, age: 30), 1780);
    // 60 kg, 165 cm, 30 y female: 600 + 1031.25 − 150 − 161 = 1320.25
    expect(Nutrition.bmr(sex: Sex.female, weightKg: 60, heightCm: 165, age: 30),
        closeTo(1320.25, 0.001));
  });

  test('targets follow goal and training days', () {
    const base = UserProfile(gender: 'm', weight: 80, height: 180, age: 30,
        daysPerWeek: 4, goal: FitnessGoal.stayFit);
    final maintain = Nutrition.targetsFor(base);
    expect(maintain.tdee, (1780 * 1.55).round());
    expect(maintain.calories, maintain.tdee);

    final cut = Nutrition.targetsFor(base.copyWith(goal: FitnessGoal.loseFat));
    expect(cut.calories, (maintain.tdee * 0.8).round());
    expect(cut.proteinG, 160); // 2 g/kg

    final bulk = Nutrition.targetsFor(base.copyWith(goal: FitnessGoal.buildMuscle));
    expect(bulk.calories, greaterThan(maintain.calories));
  });

  test('macros add up to the calorie target (±1 g rounding)', () {
    final t = Nutrition.targetsFor(const UserProfile(gender: 'f', weight: 65,
        height: 165, age: 28, goal: FitnessGoal.loseFat));
    final kcal = t.proteinG * 4 + t.carbsG * 4 + t.fatG * 9;
    expect(kcal, closeTo(t.calories, 12));
  });

  test('never goes below the safety floor', () {
    final t = Nutrition.targetsFor(const UserProfile(gender: 'f', weight: 40,
        height: 150, age: 70, daysPerWeek: 2, goal: FitnessGoal.loseFat));
    expect(t.calories, 1200);
  });

  test('"other" uses the chosen formula basis', () {
    const p = UserProfile(gender: 'o', weight: 70, height: 170, age: 30);
    expect(Nutrition.targetsFor(p.copyWith(formulaBasis: Sex.male)).bmr,
        Nutrition.targetsFor(p.copyWith(formulaBasis: Sex.female)).bmr + 166);
  });

  test('water goal ≈ 35 ml/kg in 250 ml steps', () {
    final t = Nutrition.targetsFor(const UserProfile(weight: 70));
    expect(t.waterMl, 2500); // 2450 → nearest glass
    expect(t.waterMl % 250, 0);
  });

  test('fuel log counts today only and water never goes negative', () async {
    sqfliteFfiInit();
    final tmp = Directory.systemTemp.createTempSync('fuel_test');
    final db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/f.db');
    var now = DateTime(2026, 11, 3, 23, 0);
    final fuel = FuelProvider(db, clock: () => now);
    await fuel.load();

    await fuel.addFood(kcal: 600, name: 'Biryani', proteinG: 25);
    await fuel.addWater(500);
    await fuel.addWater(-1000);
    expect(fuel.kcal, 600);
    expect(fuel.proteinG, 25);
    expect(fuel.waterMl, 0);

    now = DateTime(2026, 11, 4, 7, 0); // next morning
    await fuel.load();
    expect(fuel.kcal, 0);

    await db.close();
    tmp.deleteSync(recursive: true);
  });
}
