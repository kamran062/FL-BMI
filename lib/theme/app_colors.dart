import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const brand500 = Color(0xFF1FB573);
  static const brand600 = Color(0xFF18A065);
  static const brand700 = Color(0xFF128055);
  static const brand400 = Color(0xFF4ECB95);
  static const brand300 = Color(0xFF8FE0BA);
  static const brand200 = Color(0xFFC6EFDA);
  static const brand100 = Color(0xFFE8F7EF);
  static const brand50  = Color(0xFFF4FBF7);

  // BMI categories
  static const bmiUnder      = Color(0xFF3B82F6);
  static const bmiNormal     = Color(0xFF1FB573);
  static const bmiOver       = Color(0xFFF59E0B);
  static const bmiObese      = Color(0xFFEF4444);

  static const bmiUnderTint  = Color(0xFFEAF1FE);
  static const bmiNormalTint = Color(0xFFE8F7EF);
  static const bmiOverTint   = Color(0xFFFEF4E2);
  static const bmiObeseTint  = Color(0xFFFDEAEA);

  static const bmiUnderInk   = Color(0xFF1D4ED8);
  static const bmiNormalInk  = Color(0xFF128055);
  static const bmiOverInk    = Color(0xFF9A6500);
  static const bmiObeseInk   = Color(0xFFB91C1C);

  // Light neutrals
  static const bgCanvas  = Color(0xFFFAFAF7);
  static const bgSurface = Color(0xFFFFFFFF);
  static const bgSunken  = Color(0xFFF1F2EE);
  static const bgTint    = Color(0xFFF4FBF7);

  static const fg1 = Color(0xFF0E1411);
  static const fg2 = Color(0xFF4A5450);
  static const fg3 = Color(0xFF8A938F);
  static const fgOnBrand = Color(0xFFFFFFFF);

  static const borderSubtle = Color(0x1A0E1411);
  static const borderFaint  = Color(0x0F0E1411);

  // Dark neutrals
  static const darkBgCanvas  = Color(0xFF0E1411);
  static const darkBgSurface = Color(0xFF161D1A);
  static const darkBgSunken  = Color(0xFF0A100D);
  static const darkBgTint    = Color(0xFF122620);

  static const darkFg1 = Color(0xFFF5F7F4);
  static const darkFg2 = Color(0xFFB0B8B4);
  static const darkFg3 = Color(0xFF6E7873);

  static const darkBorderSubtle = Color(0x1AFFFFFF);
  static const darkBorderFaint  = Color(0x0FFFFFFF);

  static const darkBrand500 = Color(0xFF2BC480);

  static Color bmiUnderTintDark   = const Color(0xFF3B82F6).withOpacity(0.12);
  static Color bmiNormalTintDark  = const Color(0xFF1FB573).withOpacity(0.12);
  static Color bmiOverTintDark    = const Color(0xFFF59E0B).withOpacity(0.12);
  static Color bmiObeseTintDark   = const Color(0xFFEF4444).withOpacity(0.12);
}
