import 'package:flutter/foundation.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';

/// The user's profile: body measurements, gender, goals and preferences.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;
  UserProfile _profile = const UserProfile();

  UserProfile get profile => _profile;

  Future<void> load() async {
    _profile = await _repository.load();
    notifyListeners();
  }

  /// Updates in memory and notifies immediately (screens such as the
  /// calculator read the new value synchronously), then persists.
  Future<void> update(UserProfile profile) async {
    _profile = profile;
    notifyListeners();
    await _repository.save(profile);
  }
}
