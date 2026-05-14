import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BmiCategory {
  final String key;
  final String label;
  final Color color;
  final Color tint;
  final Color ink;

  const BmiCategory({
    required this.key,
    required this.label,
    required this.color,
    required this.tint,
    required this.ink,
  });
}

class BmiCalculator {
  BmiCalculator._();

  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final m = heightCm / 100;
    return weightKg / (m * m);
  }

  static BmiCategory category(double bmi) {
    if (bmi < 18.5) {
      return const BmiCategory(
        key: 'under', label: 'Underweight',
        color: AppColors.bmiUnder,
        tint: AppColors.bmiUnderTint,
        ink: AppColors.bmiUnderInk,
      );
    }
    if (bmi < 25.0) {
      return const BmiCategory(
        key: 'normal', label: 'Normal',
        color: AppColors.bmiNormal,
        tint: AppColors.bmiNormalTint,
        ink: AppColors.bmiNormalInk,
      );
    }
    if (bmi < 30.0) {
      return const BmiCategory(
        key: 'over', label: 'Overweight',
        color: AppColors.bmiOver,
        tint: AppColors.bmiOverTint,
        ink: AppColors.bmiOverInk,
      );
    }
    return const BmiCategory(
      key: 'obese', label: 'Obese',
      color: AppColors.bmiObese,
      tint: AppColors.bmiObeseTint,
      ink: AppColors.bmiObeseInk,
    );
  }

  static Map<String, dynamic> advice(String categoryKey) {
    const map = {
      'under': {
        'headline': 'Slightly below the normal range',
        'copy': 'A small calorie surplus and strength work can help you reach a healthy range.',
        'steps': [
          'Aim for +300 kcal/day from whole foods',
          'Add 2 strength sessions a week',
          'Track weight every 3 days',
        ],
      },
      'normal': {
        'headline': 'You are in the healthy range',
        'copy': 'Maintain with consistent movement, sleep, and balanced meals.',
        'steps': [
          'Walk 7,000+ steps daily',
          'Sleep 7–9 hours',
          'Re-check BMI in 4 weeks',
        ],
      },
      'over': {
        'headline': 'Slightly above the normal range',
        'copy': 'A small, sustained calorie deficit moves you back to the normal range without crash dieting.',
        'steps': [
          'Aim for a 0.5 kg loss this week',
          'Add 30 min daily movement',
          'Drink water before meals',
        ],
      },
      'obese': {
        'headline': 'Above the normal range',
        'copy': 'Steady, gentle changes work best. Consider a check-in with a clinician for personalized guidance.',
        'steps': [
          'Aim for 0.5–1.0 kg loss per week',
          'Replace sugary drinks with water',
          'Walk 30 minutes after meals',
        ],
      },
    };
    return map[categoryKey] ?? map['normal']!;
  }
}
