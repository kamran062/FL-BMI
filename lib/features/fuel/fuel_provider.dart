import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';

/// Calories eaten on one day (for the weekly chart).
typedef DayKcal = ({DateTime day, int kcal});

/// The food log and water intake. [food], [kcal] and [waterMl] are always
/// today's (used by Today); the Fuel tab can browse other days via
/// [viewDay] and the `day*` getters. "Today" starts at local midnight and
/// is re-checked on every load, so the day rolls over correctly.
class FuelProvider extends ChangeNotifier {
  FuelProvider(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final DatabaseHelper _db;
  final DateTime Function() _now;

  List<FoodLog> _food = [];
  int _waterMl = 0;

  /// Null while viewing today, so the view follows the date change.
  DateTime? _viewDay;
  List<FoodLog> _dayFood = [];
  int _dayWaterMl = 0;
  List<DayKcal> _week = [];

  List<FoodLog> get food => _food;
  int get kcal => _totalKcal(_food);
  double get proteinG => _sum(_food, (f) => f.proteinG);
  int get waterMl => _waterMl;

  /// The day shown in the Fuel tab (midnight).
  DateTime get viewDay => _viewDay ?? today;
  bool get viewingToday => _viewDay == null;
  List<FoodLog> get dayFood => _dayFood;
  int get dayKcal => _totalKcal(_dayFood);
  double get dayProteinG => _sum(_dayFood, (f) => f.proteinG);
  double get dayCarbsG => _sum(_dayFood, (f) => f.carbsG);
  double get dayFatG => _sum(_dayFood, (f) => f.fatG);
  int get dayWaterMl => _dayWaterMl;

  /// Whether any entry of the viewed day has a carbs / fat value.
  bool get dayHasCarbs => _dayFood.any((f) => f.carbsG != null);
  bool get dayHasFat => _dayFood.any((f) => f.fatG != null);

  /// Seven days ending with [viewDay], oldest first.
  List<DayKcal> get week => _week;

  static int _totalKcal(List<FoodLog> l) => l.fold(0, (s, f) => s + f.kcal);
  static double _sum(List<FoodLog> l, double? Function(FoodLog) v) =>
      l.fold(0.0, (s, f) => s + (v(f) ?? 0));

  DateTime get today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _next(DateTime d) => DateTime(d.year, d.month, d.day + 1);

  Future<void> load() async {
    final t = today;
    if (_viewDay != null && !_viewDay!.isBefore(t)) _viewDay = null;
    final d = viewDay;
    // One query covers the week chart and the viewed day.
    final from = DateTime(d.year, d.month, d.day - 6);
    final all = await _db.getFoodBetween(from, _next(d));
    List<FoodLog> on(DateTime day) => [
          for (final f in all)
            if (!f.date.isBefore(day) && f.date.isBefore(_next(day))) f
        ];
    _week = [
      for (var i = 0; i < 7; i++)
        if (DateTime(from.year, from.month, from.day + i) case final day)
          (day: day, kcal: _totalKcal(on(day)))
    ];
    _dayFood = on(d);
    _dayWaterMl = await _db.getWaterBetween(d, _next(d));
    if (_viewDay == null) {
      _food = _dayFood;
      _waterMl = _dayWaterMl;
    } else {
      _food = await _db.getFoodBetween(t, _next(t));
      _waterMl = await _db.getWaterBetween(t, _next(t));
    }
    notifyListeners();
  }

  /// Shows [day] in the Fuel tab. Future days are not allowed.
  Future<void> showDay(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    _viewDay = d.isBefore(today) ? d : null;
    await load();
  }

  Future<void> previousDay() => showDay(viewDay.subtract(const Duration(hours: 12)));

  Future<void> nextDay() async {
    if (viewingToday) return;
    await showDay(_next(viewDay));
  }

  /// New entries go to the viewed day: now for today, otherwise the same
  /// time of day on the past day (keeps entries in the order they are added).
  DateTime get _entryTime {
    final n = _now();
    final d = _viewDay;
    return d == null
        ? n
        : DateTime(d.year, d.month, d.day, n.hour, n.minute, n.second);
  }

  Future<void> addFood({
    required int kcal,
    String name = '',
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    if (kcal <= 0) return;
    await _db.insertFood(FoodLog(
        date: _entryTime,
        name: name.trim(),
        kcal: kcal,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG));
    await load();
  }

  /// Saves changes to an existing entry (keeps its date).
  Future<void> updateFood(FoodLog f) async {
    if (f.id == null || f.kcal <= 0) return;
    await _db.updateFood(f);
    await load();
  }

  Future<void> deleteFood(int id) async {
    await _db.deleteFood(id);
    await load();
  }

  /// Adds (or with a negative amount removes) water, never below zero.
  /// Today's total unless [viewedDay] (the Fuel tab's day).
  Future<void> addWater(int ml, {bool viewedDay = false}) async {
    final onView = viewedDay && !viewingToday;
    final current = onView ? _dayWaterMl : _waterMl;
    final delta = ml < 0 ? -current.clamp(0, -ml) : ml;
    if (delta == 0) return;
    await _db.insertWater(onView ? _entryTime : _now(), delta);
    await load();
  }
}
