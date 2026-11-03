import 'dart:io';

import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  // Fresh database per launch, so no test sees another test's data
  final dir = Directory.systemTemp.createTempSync('bmi_app_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  final db = DatabaseHelper.test(databaseFactoryFfi, '${dir.path}/app.db');
  addTearDown(db.close);
  final settings = SettingsProvider();
  final profile = ProfileProvider(ProfileRepository(db));
  final bmi = BmiProvider(db);
  await tester.runAsync(
      () => Future.wait([settings.load(), profile.load(), bmi.load()]));
  await tester.pumpWidget(BmiHealthProviders(
    settings: settings,
    profile: profile,
    bmi: bmi,
    child: const BmiHealthApp(),
  ));
  // Splash hands off after 2.6 s
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Simulates the Android system back button.
Future<void> pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
