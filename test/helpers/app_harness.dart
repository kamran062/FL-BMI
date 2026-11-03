import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Call once per test file, in setUpAll.
void setUpAppHarness() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Launches the real app as a returning user and waits past the splash.
/// [prefs] are extra SharedPreferences values, e.g. {'language': 'ur'}.
Future<void> launchApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  // iPhone 14-sized screen instead of the default 800×600 test surface
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'onboarding_done': true, ...prefs});
  PackageInfo.setMockInitialValues(
    appName: 'BMI Health', packageName: 'com.bmihealth.bmi_health',
    version: '1.0.1', buildNumber: '3', buildSignature: '',
  );
  final provider = AppProvider();
  await tester.runAsync(provider.init);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: const BmiHealthApp(),
    ),
  );
  // Splash hands off after 2.6 s
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Simulates the Android system back button.
Future<void> pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
