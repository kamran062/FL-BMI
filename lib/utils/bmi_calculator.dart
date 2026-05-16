import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BmiCategory {
  final String key;
  final String label;
  final Color color;
  final Color tint;
  final Color ink;
  final Color tintDark;
  final Color inkDark;

  const BmiCategory({
    required this.key,
    required this.label,
    required this.color,
    required this.tint,
    required this.ink,
    required this.tintDark,
    required this.inkDark,
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
        tint: AppColors.bmiUnderTint,     ink: AppColors.bmiUnderInk,
        tintDark: AppColors.bmiUnderTintDark, inkDark: AppColors.bmiUnderInkDark,
      );
    }
    if (bmi < 25.0) {
      return const BmiCategory(
        key: 'normal', label: 'Normal',
        color: AppColors.bmiNormal,
        tint: AppColors.bmiNormalTint,     ink: AppColors.bmiNormalInk,
        tintDark: AppColors.bmiNormalTintDark, inkDark: AppColors.bmiNormalInkDark,
      );
    }
    if (bmi < 30.0) {
      return const BmiCategory(
        key: 'over', label: 'Overweight',
        color: AppColors.bmiOver,
        tint: AppColors.bmiOverTint,     ink: AppColors.bmiOverInk,
        tintDark: AppColors.bmiOverTintDark, inkDark: AppColors.bmiOverInkDark,
      );
    }
    return const BmiCategory(
      key: 'obese', label: 'Obese',
      color: AppColors.bmiObese,
      tint: AppColors.bmiObeseTint,     ink: AppColors.bmiObeseInk,
      tintDark: AppColors.bmiObeseTintDark, inkDark: AppColors.bmiObeseInkDark,
    );
  }

  static Map<String, dynamic> advice(String categoryKey) {
    const map = {
      'under': {
        'headline': 'Your weight is below the healthy range',
        'copy':
            'Being underweight can weaken immunity, reduce bone density, and affect energy levels. '
            'The goal is gradual, quality weight gain — not just eating more junk food.',
        'steps': [
          'Eat calorie-dense whole foods: nuts, nut butter, avocado, eggs, whole milk, oats, and brown rice',
          'Add 300–500 extra kcal per day — enough to gain ~0.3–0.5 kg per week sustainably',
          'Eat 3 main meals + 2–3 snacks daily; never skip breakfast',
          'Include protein at every meal — aim for 1.2–1.6 g per kg of body weight to build muscle',
          'Do resistance training 2–3× per week (squats, push-ups, rows) so gained weight becomes muscle, not just fat',
          'If weight loss is unexplained or rapid, see a doctor — it may signal an underlying condition',
        ],
        'note': 'If you have been underweight for a long time, consult a doctor or registered dietitian for personalised support.',
      },
      'normal': {
        'headline': 'You are in the healthy weight range',
        'copy':
            'A healthy BMI is a great foundation. The priority now is maintaining it through consistent '
            'habits — movement, quality nutrition, sleep, and stress management all matter.',
        'steps': [
          'Get 150–300 min of moderate aerobic activity per week: brisk walking, cycling, or swimming',
          'Add 2–3 strength training sessions per week to preserve muscle mass as you age',
          'Fill half your plate with vegetables and fruit at every main meal',
          'Limit ultra-processed foods, added sugars, and alcohol — they add calories with little nutrition',
          'Sleep 7–9 hours per night; poor sleep raises ghrelin (hunger hormone) and leads to overeating',
          'Re-check your BMI every 4–6 weeks to catch any drift early',
        ],
        'note': 'BMI is a screening tool, not a full health picture. Body composition, blood pressure, and blood sugar also matter.',
      },
      'over': {
        'headline': 'Your weight is slightly above the healthy range',
        'copy':
            'Overweight raises the risk of type 2 diabetes, high blood pressure, and joint problems over time. '
            'Even a 5–10% reduction in body weight significantly lowers these risks.',
        'steps': [
          'Create a moderate calorie deficit of 300–500 kcal/day — target 0.3–0.5 kg loss per week (sustainable pace)',
          'Walk 8,000–10,000 steps daily; start with 30 min brisk walks and build from there',
          'Swap sugary drinks (soda, juice, energy drinks) for water, sparkling water, or unsweetened tea',
          'Eat protein first at each meal — it increases satiety and reduces overall calorie intake',
          'Fill half your plate with non-starchy vegetables (broccoli, spinach, cucumber, peppers) at lunch and dinner',
          'Avoid eating within 2–3 hours of bedtime — late-night eating promotes fat storage',
        ],
        'note': 'Crash diets backfire. A 300–500 kcal deficit is enough — losing weight slowly preserves muscle and is easier to maintain.',
      },
      'obese': {
        'headline': 'Your weight is in the obese range',
        'copy':
            'Obesity is associated with increased risk of heart disease, type 2 diabetes, sleep apnea, and joint pain. '
            'The good news: even modest weight loss of 5–10% of your body weight produces meaningful health improvements.',
        'steps': [
          'Set your first target at 5–10% of current weight — for an 100 kg person, that is just 5–10 kg',
          'Aim for 0.5–1.0 kg loss per week; faster rates typically cause muscle loss and a rebound',
          'Start with low-impact daily movement: 30 min walking, swimming, or stationary cycling — knees and joints will thank you',
          'Cut out ultra-processed foods, fried food, and added sugars first — these alone can reduce 500+ kcal/day',
          'Build meals around protein (chicken, fish, legumes, eggs) and vegetables; they keep you full longer',
          'See your doctor for a baseline check — blood pressure, blood sugar, and cholesterol — and ask about structured support programs',
        ],
        'note': 'BMI alone does not diagnose health. Speak with a doctor or registered dietitian for a plan tailored to your medical history.',
      },
    };
    return map[categoryKey] ?? map['normal']!;
  }
}
