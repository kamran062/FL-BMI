// Demo build for screen recordings (store video, screenshots). Never shipped:
// it isn't the app's entry point. Fills a fresh install with a believable
// month of data, fakes Health Connect steps/sleep, and shows no ads.
//
//   adb uninstall com.bmihealth.bmi_health.dev   # start clean
//   flutter run -t tool/demo/demo_main.dart --flavor dev
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/storage/backup_exclusion.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_entry.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';
import 'package:bmi_health/features/body/photos/photo_vault.dart';
import 'package:bmi_health/features/body/photos/photos_provider.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/recovery/recovery_provider.dart';
import 'package:bmi_health/features/recovery/domain/recovery.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/wear/wear_bridge.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final db = DatabaseHelper.instance;
  final prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool('demo_seeded') ?? false)) {
    await _seed(db, prefs);
    await prefs.setBool('demo_seeded', true);
  }

  final settings = SettingsProvider();
  final profile = ProfileProvider(ProfileRepository(db));
  final bmi = BmiProvider(db);
  final body = BodyProvider(db);
  final workouts = WorkoutProvider(db);
  final fuel = FuelProvider(db);
  final steps = StepsProvider(source: _DemoSteps());
  final movement = MovementProvider(db);
  final recovery = RecoveryProvider(source: _DemoRecovery());
  final cycle = CycleProvider(db);
  final challenges = ChallengeProvider(db);
  final photos = PhotosProvider(db, () async => PhotoVault(await BackupExclusion.photosDir()));
  final catalog = await ExerciseCatalog.loadBundled();
  await Future.wait([
    settings.load(), profile.load(), bmi.load(), body.load(), workouts.load(),
    fuel.load(), steps.load(), movement.load(), recovery.load(), cycle.load(), photos.load(), challenges.load(),
  ]);

  // No AdService.initialize() and no store connection: a clean demo.
  runApp(BmiHealthProviders(
    settings: settings,
    profile: profile,
    bmi: bmi,
    body: body,
    workouts: workouts,
    fuel: fuel,
    steps: steps,
    movement: movement,
    purchases: PurchaseService.instance,
    recovery: recovery,
    cycle: cycle,
    photos: photos,
    db: db,
    wear: WearBridge(workouts, catalog),
    challenges: challenges,
    catalog: catalog,
    child: const BmiHealthApp(),
  ));
}

DateTime _day(int daysAgo, [int hour = 0, int minute = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day - daysAgo, hour, minute);
}

Future<void> _seed(DatabaseHelper db, SharedPreferences prefs) async {
  await prefs.setBool('onboarding_done', true);
  await prefs.setBool('profile_setup_dismissed', true);
  await prefs.setString('theme', 'dark');
  await prefs.setString('language', 'en');
  await prefs.setBool('steps_connected', true);
  await prefs.setBool('recovery_connected', true);
  final t = DateTime.now();
  await prefs.setInt('soreness_${t.year}-${t.month}-${t.day}', 2);

  const height = 175.0;
  await db.saveProfile(const UserProfile(
    name: 'Ali',
    height: height,
    weight: 79.4,
    age: 28,
    gender: 'm',
    formulaBasis: Sex.male,
    goal: FitnessGoal.loseFat,
    experience: Experience.intermediate,
    equipment: Equipment.gym,
    daysPerWeek: 4,
    completed: true,
  ));

  // Ten weeks of weigh-ins, 86 → 79.4 kg with day-to-day wobble
  final rnd = math.Random(7);
  for (var i = 70; i >= 0; i -= 2) {
    final kg = 79.4 + (86 - 79.4) * (i / 70) + (rnd.nextDouble() - 0.5) * 0.6;
    final w = double.parse(kg.toStringAsFixed(1));
    await db.insertWeightLog(WeightLog(date: _day(i, 7, 30), weightKg: i == 0 ? 79.4 : w));
    if (i % 14 == 0) {
      final bmi = w / math.pow(height / 100, 2);
      await db.insertEntry(BmiEntry(
          weight: w, height: height, bmi: double.parse(bmi.toStringAsFixed(1)), age: 28, gender: 'm',
          weightUnit: 'kg', heightUnit: 'cm', date: _day(i, 7, 35)));
    }
  }
  await db.insertMeasurement(Measurement(date: _day(56), waist: 95, chest: 104, arm: 34, neck: 39));
  await db.insertMeasurement(Measurement(date: _day(1), waist: 88.5, chest: 102, arm: 35, neck: 38.5));

  // Four weeks of a 4-day split, getting a little stronger each week
  const days = [
    ('Push', [('barbell_bench_press', 60.0, 8), ('overhead_press', 37.5, 8), ('incline_dumbbell_press', 22.0, 10), ('tricep_pushdown', 25.0, 12)]),
    ('Pull', [('barbell_row', 55.0, 8), ('lat_pulldown', 50.0, 10), ('dumbbell_curl', 12.0, 12), ('face_pull', 20.0, 15)]),
    ('Legs', [('barbell_back_squat', 80.0, 6), ('romanian_deadlift', 70.0, 8), ('leg_press', 140.0, 10), ('standing_calf_raise', 0.0, 15)]),
    ('Upper', [('pull_up', 0.0, 8), ('dumbbell_bench_press', 26.0, 10), ('seated_cable_row', 50.0, 10), ('lateral_raise', 8.0, 15)]),
  ];
  // Last two days are rest days, so the recovery score is green
  const offsets = [28, 26, 24, 22, 21, 19, 17, 15, 14, 12, 10, 8, 7, 5, 4, 3];
  for (var i = 0; i < offsets.length; i++) {
    final (name, exercises) = days[i % 4];
    final week = i ~/ 4;
    final start = _day(offsets[i], 18, 10);
    final id = await db.insertWorkout(Workout(
        name: name, startedAt: start, finishedAt: start.add(Duration(minutes: 52 + (i * 7) % 15))));
    for (var e = 0; e < exercises.length; e++) {
      final (ex, kg, reps) = exercises[e];
      final step = kg >= 50 ? 2.5 : (kg > 0 ? 1.0 : 0.0);
      if (kg >= 50) {
        await db.insertSet(WorkoutSet(
            workoutId: id, exerciseId: ex, order: e, weightKg: kg * 0.5, reps: 10, done: true, type: SetType.warmup));
      }
      for (var s = 0; s < 3; s++) {
        await db.insertSet(WorkoutSet(
            workoutId: id, exerciseId: ex, order: e,
            weightKg: kg + step * week, reps: reps + (kg == 0 ? week : 0) - (s == 2 ? 1 : 0),
            done: true, rpe: s == 2 ? 8.5 : null));
      }
    }
  }

  // Home challenge: six days in a row, up to yesterday
  final key = ChallengePlanner.key(ChallengeFocus.coreAbs, ChallengeLevel.beginner);
  for (var d = 1; d <= 6; d++) {
    await db.completeChallengeDay(key, d, _day(7 - d, 7, 0));
  }

  // Today's food and water
  final food = [
    (_day(0, 8, 30), 'Aloo paratha', 290, 6.0, 38.0, 13.0),
    (_day(0, 8, 35), 'Chai with milk', 90, 3.0, 12.0, 3.0),
    (_day(0, 13, 20), 'Chicken biryani', 500, 25.0, 60.0, 18.0),
    (_day(0, 16, 0), 'Greek yogurt', 120, 15.0, 8.0, 3.0),
  ];
  for (final (at, name, kcal, p, c, f) in food) {
    await db.insertFood(FoodLog(date: at, name: name, kcal: kcal, proteinG: p, carbsG: c, fatG: f));
  }
  for (final h in [8, 11, 14, 16]) {
    await db.insertWater(_day(0, h), 500);
  }
}

class _DemoSteps implements StepsSource {
  @override
  Future<StepsStatus> status({required bool userConnected}) async => StepsStatus.connected;
  @override
  Future<bool> requestAccess() async => true;
  @override
  Future<void> install() async {}
  @override
  Future<int> stepsBetween(DateTime from, DateTime to) async {
    final days = to.difference(from).inHours / 24;
    if (days <= 1.01) {
      final today = DateTime.now();
      if (from.year == today.year && from.month == today.month && from.day == today.day) return 8742;
      return 6000 + (from.day * 937) % 5200;
    }
    return (days * 8600).round();
  }
}

class _DemoRecovery implements RecoverySource {
  @override
  Future<bool> available() async => true;
  @override
  Future<bool> hasAccess() async => true;
  @override
  Future<bool> requestAccess() async => true;
  @override
  Future<List<SleepNight>> sleepSegments(DateTime from, DateTime to) async => [
        for (var d = to.difference(from).inDays; d >= 0; d--)
          SleepNight(
            DateTime(to.year, to.month, to.day - d - 1, 23, 10 + (d * 13) % 40),
            DateTime(to.year, to.month, to.day - d, 6, 40 + (d * 7) % 35),
          ),
      ];
  @override
  Future<List<DailyValue>> restingHr(DateTime from, DateTime to) async => [
        for (var d = to.difference(from).inDays; d >= 0; d--)
          (day: DateTime(to.year, to.month, to.day - d), value: 58.0 + (d % 3)),
      ];
  @override
  Future<List<DailyValue>> hrv(DateTime from, DateTime to) async => [
        for (var d = to.difference(from).inDays; d >= 0; d--)
          (day: DateTime(to.year, to.month, to.day - d), value: 64.0 - (d % 4)),
      ];
}
