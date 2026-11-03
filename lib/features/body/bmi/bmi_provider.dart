import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_entry.dart';
import 'package:bmi_health/features/body/bmi/domain/goal.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';

/// Saved BMI history and the active weight goal.
class BmiProvider extends ChangeNotifier {
  BmiProvider(this._db);

  final DatabaseHelper _db;
  List<BmiEntry> _entries = [];
  Goal? _activeGoal;

  List<BmiEntry> get entries => _entries;
  BmiEntry? get lastEntry => _entries.isNotEmpty ? _entries.first : null;
  Goal? get activeGoal => _activeGoal;

  Future<void> load() async {
    _entries = await _db.getEntries();
    _activeGoal = await _db.getActiveGoal();
    notifyListeners();
  }

  /// Saves the BMI of [profile] as a new history entry.
  Future<BmiEntry> saveResult(UserProfile profile) async {
    final entry = BmiEntry(
      weight: profile.weightInKg,
      height: profile.heightInCm,
      bmi: profile.bmi,
      age: profile.age,
      gender: profile.gender,
      weightUnit: profile.weightUnit,
      heightUnit: profile.heightUnit,
      date: DateTime.now(),
    );
    final id = await _db.insertEntry(entry);
    _entries = await _db.getEntries();
    notifyListeners();
    return entry.copyWith(id: id);
  }

  Future<void> deleteEntry(int id) async {
    await _db.deleteEntry(id);
    _entries = await _db.getEntries();
    notifyListeners();
  }

  Future<void> saveGoal(Goal goal) async {
    await _db.insertGoal(goal);
    _activeGoal = goal;
    notifyListeners();
  }

  Future<void> clearGoal() async {
    await _db.deactivateGoal();
    _activeGoal = null;
    notifyListeners();
  }
}
