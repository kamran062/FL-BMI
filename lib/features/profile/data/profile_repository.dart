import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';

/// Loads and saves the single user profile.
///
/// Until v1.0.x the profile lived in SharedPreferences. The first load after
/// upgrading imports those values into the database and removes the old keys.
class ProfileRepository {
  ProfileRepository(this._db);

  final DatabaseHelper _db;

  static const _legacyKeys = [
    'profile_height', 'profile_height_unit',
    'profile_weight', 'profile_weight_unit',
    'profile_age', 'profile_gender',
  ];

  Future<UserProfile> load() async {
    final saved = await _db.getProfile();
    if (saved != null) return saved;

    // First run on this version: import (or create) and persist.
    final prefs = await SharedPreferences.getInstance();
    final imported = UserProfile(
      height: prefs.getDouble('profile_height') ?? 172,
      heightUnit: prefs.getString('profile_height_unit') ?? 'cm',
      weight: prefs.getDouble('profile_weight') ?? 70,
      weightUnit: prefs.getString('profile_weight_unit') ?? 'kg',
      age: prefs.getInt('profile_age') ?? 30,
      gender: prefs.getString('profile_gender') ?? 'f',
    );
    // Save before removing the old keys, so an interruption can't lose data.
    await _db.saveProfile(imported);
    for (final key in _legacyKeys) {
      await prefs.remove(key);
    }
    return imported;
  }

  Future<void> save(UserProfile profile) => _db.saveProfile(profile);
}
