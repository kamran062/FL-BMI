import 'package:flutter/foundation.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';

/// Weight history and tape measurements.
class BodyProvider extends ChangeNotifier {
  BodyProvider(this._db);

  final DatabaseHelper _db;
  List<WeightLog> _weights = [];
  List<Measurement> _measurements = [];

  /// Oldest first.
  List<WeightLog> get weights => _weights;
  WeightLog? get latestWeight => _weights.isEmpty ? null : _weights.last;

  /// Newest first.
  List<Measurement> get measurements => _measurements;
  Measurement? get latestMeasurement =>
      _measurements.isEmpty ? null : _measurements.first;

  Future<void> load() async {
    _weights = await _db.getWeightLogs();
    _measurements = await _db.getMeasurements();
    notifyListeners();
  }

  Future<void> logWeight(double kg, {DateTime? at}) async {
    await _db.insertWeightLog(WeightLog(date: at ?? DateTime.now(), weightKg: kg));
    _weights = await _db.getWeightLogs();
    notifyListeners();
  }

  Future<void> updateWeight(WeightLog log) async {
    if (log.id == null) return;
    await _db.updateWeightLog(log);
    _weights = await _db.getWeightLogs();
    notifyListeners();
  }

  Future<void> deleteWeight(int id) async {
    await _db.deleteWeightLog(id);
    _weights = await _db.getWeightLogs();
    notifyListeners();
  }

  Future<void> addMeasurement(Measurement m) async {
    if (m.isEmpty) return;
    await _db.insertMeasurement(m);
    _measurements = await _db.getMeasurements();
    notifyListeners();
  }

  /// Saves an edited measurement; one with every field cleared is deleted.
  Future<void> updateMeasurement(Measurement m) async {
    if (m.id == null) return;
    if (m.isEmpty) return deleteMeasurement(m.id!);
    await _db.updateMeasurement(m);
    _measurements = await _db.getMeasurements();
    notifyListeners();
  }

  Future<void> deleteMeasurement(int id) async {
    await _db.deleteMeasurement(id);
    _measurements = await _db.getMeasurements();
    notifyListeners();
  }
}
