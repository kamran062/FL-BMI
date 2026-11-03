import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';

/// Today's calorie log and water intake. "Today" starts at local midnight
/// and is re-checked on every load, so the day rolls over correctly.
class FuelProvider extends ChangeNotifier {
  FuelProvider(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final DatabaseHelper _db;
  final DateTime Function() _now;

  List<FoodLog> _food = [];
  int _waterMl = 0;

  List<FoodLog> get food => _food;
  int get kcal => _food.fold(0, (sum, f) => sum + f.kcal);
  double get proteinG => _food.fold(0.0, (sum, f) => sum + (f.proteinG ?? 0));
  int get waterMl => _waterMl;

  DateTime get _today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> load() async {
    _food = await _db.getFoodSince(_today);
    _waterMl = await _db.getWaterSince(_today);
    notifyListeners();
  }

  Future<void> addFood({required int kcal, String name = '', double? proteinG}) async {
    if (kcal <= 0) return;
    await _db.insertFood(FoodLog(
        date: _now(), name: name.trim(), kcal: kcal, proteinG: proteinG));
    await load();
  }

  Future<void> deleteFood(int id) async {
    await _db.deleteFood(id);
    await load();
  }

  /// Adds (or with a negative amount removes) water, never below zero.
  Future<void> addWater(int ml) async {
    final delta = ml < 0 ? -_waterMl.clamp(0, -ml) : ml;
    if (delta == 0) return;
    await _db.insertWater(_now(), delta);
    await load();
  }
}
