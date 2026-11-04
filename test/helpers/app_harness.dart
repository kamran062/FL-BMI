import 'dart:io';

import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:bmi_health/features/recovery/recovery_provider.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/body/photos/photos_provider.dart';
import 'package:bmi_health/features/body/photos/photo_vault.dart';
import 'package:bmi_health/features/coach/ai_client.dart';

/// Call once per test file, in setUpAll.
void setUpAppHarness() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  GoogleFonts.config.allowRuntimeFetching = false;
}

typedef AppState = ({
  SettingsProvider settings,
  ProfileProvider profile,
  BmiProvider bmi,
  BodyProvider body,
  WorkoutProvider workouts,
  FuelProvider fuel,
  StepsProvider steps,
  MovementProvider movement,
  CycleProvider cycle,
  PhotosProvider photos,
  Directory photosDir,
});

/// Launches the real app as a returning user who has already answered (or
/// postponed) the profile questions, and waits past the splash.
/// [prefs] are extra SharedPreferences values, e.g. {'language': 'ur'}.
Future<AppState> launchApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  StepsSource? steps,
  RecoverySource? recovery,
  AppLock? lock,
  AiClient? ai,
}) async {
  // iPhone 14-sized screen instead of the default 800×600 test surface
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'profile_setup_dismissed': true,
    ...prefs,
  });
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
  final body = BodyProvider(db);
  final workouts = WorkoutProvider(db);
  final fuel = FuelProvider(db);
  final stepsProvider = StepsProvider(source: steps);
  final movement = MovementProvider(db);
  // Unconfigured: premium hidden, as in builds without the server URL
  final purchases = PurchaseService(publicKey: '');
  final recoveryProvider = RecoveryProvider(source: recovery);
  final cycle = CycleProvider(db, lock: lock);
  final photosDir = Directory('${dir.path}/photos');
  final photos = PhotosProvider(
      db, () async => PhotoVault(photosDir, keys: MemoryKeyStore()));
  final catalog = ExerciseCatalog.parse(
      File('assets/exercises/catalog.json').readAsStringSync());
  await tester.runAsync(() => Future.wait([
        settings.load(), profile.load(), bmi.load(), body.load(), workouts.load(),
        fuel.load(), stepsProvider.load(), movement.load(), recoveryProvider.load(), cycle.load(), photos.load(),
      ]));
  await tester.pumpWidget(BmiHealthProviders(
    settings: settings,
    profile: profile,
    bmi: bmi,
    body: body,
    workouts: workouts,
    fuel: fuel,
    steps: stepsProvider,
    movement: movement,
    purchases: purchases,
    recovery: recoveryProvider,
    cycle: cycle,
    photos: photos,
    // Unconfigured by default: AI features hidden, as in builds without URLs
    ai: ai ?? AiClient(coachUrl: '', foodUrl: ''),
    catalog: catalog,
    child: const BmiHealthApp(),
  ));
  // Splash hands off after 2.6 s
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  return (
    settings: settings, profile: profile, bmi: bmi, body: body,
    workouts: workouts, fuel: fuel, steps: stepsProvider,
    movement: movement,
    cycle: cycle,
    photos: photos,
    photosDir: photosDir,
  );
}

/// Simulates the Android system back button.
Future<void> pressBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

/// In-memory key store for the photo vault (no platform keychain in tests).
class MemoryKeyStore implements KeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
}

