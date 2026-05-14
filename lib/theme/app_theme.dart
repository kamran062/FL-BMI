import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 64, fontWeight: FontWeight.w700,
        letterSpacing: -0.03 * 64, color: primary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 40, fontWeight: FontWeight.w700,
        letterSpacing: -0.03 * 40, color: primary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.015 * 28, color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22, fontWeight: FontWeight.w600,
        letterSpacing: -0.015 * 22, color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 17, fontWeight: FontWeight.w400, color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15, fontWeight: FontWeight.w400, color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13, fontWeight: FontWeight.w500, color: primary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15, fontWeight: FontWeight.w600,
        letterSpacing: -0.005 * 15, color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13, fontWeight: FontWeight.w500, color: primary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 11, color: primary,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand500,
        onPrimary: AppColors.fgOnBrand,
        secondary: AppColors.brand400,
        surface: AppColors.bgSurface,
        onSurface: AppColors.fg1,
        surfaceContainerHighest: AppColors.bgSunken,
        outline: AppColors.borderSubtle,
      ),
      scaffoldBackgroundColor: AppColors.bgCanvas,
      textTheme: _buildTextTheme(AppColors.fg1),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCanvas,
        foregroundColor: AppColors.fg1,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.brand500,
        thumbColor: AppColors.brand500,
        inactiveTrackColor: AppColors.bgSunken,
        overlayColor: Color(0x201FB573),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.fgOnBrand : AppColors.bgSurface),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.brand500 : AppColors.bgSunken),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderFaint,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.brand500,
        unselectedItemColor: AppColors.fg3,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkBrand500,
        onPrimary: AppColors.fgOnBrand,
        secondary: AppColors.brand400,
        surface: AppColors.darkBgSurface,
        onSurface: AppColors.darkFg1,
        surfaceContainerHighest: AppColors.darkBgSunken,
        outline: AppColors.darkBorderSubtle,
      ),
      scaffoldBackgroundColor: AppColors.darkBgCanvas,
      textTheme: _buildTextTheme(AppColors.darkFg1),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgCanvas,
        foregroundColor: AppColors.darkFg1,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBrand500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.darkBrand500,
        thumbColor: AppColors.darkBrand500,
        inactiveTrackColor: AppColors.darkBgSunken,
        overlayColor: Color(0x202BC480),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.fgOnBrand : AppColors.darkFg1),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.darkBrand500 : AppColors.darkBgSunken),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderFaint,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.darkBrand500,
        unselectedItemColor: AppColors.darkFg3,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
