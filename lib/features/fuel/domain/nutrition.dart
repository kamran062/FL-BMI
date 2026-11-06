import 'package:bmi_health/features/profile/domain/user_profile.dart';

/// Daily targets derived from the profile.
class NutritionTargets {
  final int bmr;
  final int tdee;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int waterMl;

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterMl,
  });
}

abstract final class Nutrition {
  /// Mifflin-St Jeor resting energy, kcal/day. Sex-specific (ROADMAP §3):
  /// male +5, female −161.
  static double bmr({
    required Sex sex,
    required double weightKg,
    required double heightCm,
    required int age,
  }) =>
      10 * weightKg + 6.25 * heightCm - 5 * age + (sex == Sex.male ? 5 : -161);

  /// Activity multiplier from planned training days per week.
  static double activityFactor(int daysPerWeek) => switch (daysPerWeek) {
        <= 1 => 1.2,
        2 => 1.375,
        3 || 4 => 1.55,
        _ => 1.725,
      };

  /// Calorie change for the fitness goal.
  static double goalFactor(FitnessGoal? goal) => switch (goal) {
        FitnessGoal.loseFat => 0.80,
        FitnessGoal.buildMuscle => 1.10,
        FitnessGoal.getStronger => 1.05,
        FitnessGoal.stayFit || null => 1.0,
      };

  /// Protein per kg body weight for the goal.
  static double proteinPerKg(FitnessGoal? goal) => switch (goal) {
        FitnessGoal.loseFat => 2.0,
        FitnessGoal.buildMuscle || FitnessGoal.getStronger => 1.8,
        FitnessGoal.stayFit || null => 1.4,
      };

  /// Never recommend fewer calories than this without medical supervision.
  static int calorieFloor(Sex sex) => sex == Sex.male ? 1500 : 1200;

  static NutritionTargets targetsFor(UserProfile p) {
    final sex = p.formulaSex;
    final kg = p.weightInKg;
    final bmrV = bmr(sex: sex, weightKg: kg, heightCm: p.heightInCm, age: p.age);
    final tdee = bmrV * activityFactor(p.daysPerWeek);
    final target = (tdee * goalFactor(p.goal))
        .round()
        .clamp(calorieFloor(sex), 6000);
    final protein = (kg * proteinPerKg(p.goal)).round();
    final fat = (target * 0.25 / 9).round(); // 25 % of calories
    final carbs = ((target - protein * 4 - fat * 9) / 4).round().clamp(0, 2000);
    // ~35 ml per kg, rounded to a glass (250 ml)
    final water = ((kg * 35) / 250).round() * 250;
    return NutritionTargets(
      bmr: bmrV.round(),
      tdee: tdee.round(),
      calories: target,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      waterMl: water.clamp(1500, 5000),
    );
  }
}

/// A quick calorie entry. Macros are optional.
class FoodLog {
  final int? id;
  final DateTime date;
  final String name;
  final int kcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  const FoodLog({
    this.id,
    required this.date,
    this.name = '',
    required this.kcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date.millisecondsSinceEpoch,
        'name': name,
        'kcal': kcal,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
      };

  factory FoodLog.fromMap(Map<String, dynamic> m) => FoodLog(
        id: m['id'] as int?,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        name: m['name'] as String? ?? '',
        kcal: m['kcal'] as int,
        proteinG: (m['protein_g'] as num?)?.toDouble(),
        carbsG: (m['carbs_g'] as num?)?.toDouble(),
        fatG: (m['fat_g'] as num?)?.toDouble(),
      );
}
