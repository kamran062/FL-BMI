import 'dart:io';

import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory tmp;
  late DatabaseHelper db;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('profile_repo_test');
    db = DatabaseHelper.test(databaseFactoryFfi, '${tmp.path}/p.db');
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('imports a v1.0 profile from SharedPreferences and removes the old keys',
      () async {
    SharedPreferences.setMockInitialValues({
      'profile_height': 65.0, 'profile_height_unit': 'ft',
      'profile_weight': 150.0, 'profile_weight_unit': 'lbs',
      'profile_age': 41, 'profile_gender': 'm',
      'onboarding_done': true, // unrelated keys stay
    });

    final profile = await ProfileRepository(db).load();
    expect(profile.height, 65.0);
    expect(profile.heightUnit, 'ft');
    expect(profile.weight, 150.0);
    expect(profile.weightUnit, 'lbs');
    expect(profile.age, 41);
    expect(profile.gender, 'm');
    expect(profile.completed, isFalse); // existing users still see setup

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('profile_height'), isNull);
    expect(prefs.getBool('onboarding_done'), isTrue);
    expect(await db.getProfile(), isNotNull);
  });

  test('a fresh install starts from defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final profile = await ProfileRepository(db).load();
    expect(profile.height, 172);
    expect(profile.weight, 70);
  });

  test('saved profile round-trips through the database', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ProfileRepository(db);
    await repo.load();
    const saved = UserProfile(
      name: 'Kamran', gender: 'o',
      formulaBasis: Sex.male, demonstratorPref: DemonstratorPref.female,
      goal: FitnessGoal.buildMuscle, experience: Experience.intermediate,
      equipment: Equipment.home, daysPerWeek: 5,
      cycleTrackingEnabled: true, completed: true,
    );
    await repo.save(saved);

    final loaded = await ProfileRepository(db).load();
    expect(loaded.toMap(), saved.toMap());
  });
}
