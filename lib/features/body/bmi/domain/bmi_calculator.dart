import 'package:flutter/material.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

class BmiCategory {
  final String key;
  final Color color;
  final Color tint;
  final Color ink;
  final Color tintDark;
  final Color inkDark;

  const BmiCategory({
    required this.key,
    required this.color,
    required this.tint,
    required this.ink,
    required this.tintDark,
    required this.inkDark,
  });
}

/// Which input is out of range. The UI turns this into a message.
enum BmiInputError { height, weight }

class BmiCalculator {
  BmiCalculator._();

  // Accepted input range, based on the shortest/tallest and lightest/heaviest
  // recorded people. Anything outside is a typo, not a real measurement.
  static const minHeightCm = 50.0;
  static const maxHeightCm = 272.0;
  static const minWeightKg = 2.0;
  static const maxWeightKg = 635.0;

  /// Returns which input is out of range, or null when the values are usable.
  static BmiInputError? validate({required double heightCm, required double weightKg}) {
    if (heightCm.isNaN || heightCm < minHeightCm || heightCm > maxHeightCm) {
      return BmiInputError.height;
    }
    if (weightKg.isNaN || weightKg < minWeightKg || weightKg > maxWeightKg) {
      return BmiInputError.weight;
    }
    return null;
  }

  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final m = heightCm / 100;
    return weightKg / (m * m);
  }

  static BmiCategory category(double bmi) {
    if (bmi < 18.5) {
      return const BmiCategory(
        key: 'under',
        color: AppColors.bmiUnder,
        tint: AppColors.bmiUnderTint,     ink: AppColors.bmiUnderInk,
        tintDark: AppColors.bmiUnderTintDark, inkDark: AppColors.bmiUnderInkDark,
      );
    }
    if (bmi < 25.0) {
      return const BmiCategory(
        key: 'normal',
        color: AppColors.bmiNormal,
        tint: AppColors.bmiNormalTint,     ink: AppColors.bmiNormalInk,
        tintDark: AppColors.bmiNormalTintDark, inkDark: AppColors.bmiNormalInkDark,
      );
    }
    if (bmi < 30.0) {
      return const BmiCategory(
        key: 'over',
        color: AppColors.bmiOver,
        tint: AppColors.bmiOverTint,     ink: AppColors.bmiOverInk,
        tintDark: AppColors.bmiOverTintDark, inkDark: AppColors.bmiOverInkDark,
      );
    }
    return const BmiCategory(
      key: 'obese',
      color: AppColors.bmiObese,
      tint: AppColors.bmiObeseTint,     ink: AppColors.bmiObeseInk,
      tintDark: AppColors.bmiObeseTintDark, inkDark: AppColors.bmiObeseInkDark,
    );
  }
}
