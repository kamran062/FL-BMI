import 'dart:math' as math;
import 'package:bmi_health/features/profile/domain/user_profile.dart';

/// One weigh-in. Weight is always stored in kg; the UI converts.
class WeightLog {
  final int? id;
  final DateTime date;
  final double weightKg;

  const WeightLog({this.id, required this.date, required this.weightKg});

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date.millisecondsSinceEpoch,
    'weight_kg': weightKg,
  };

  factory WeightLog.fromMap(Map<String, dynamic> m) => WeightLog(
    id: m['id'] as int?,
    date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
    weightKg: (m['weight_kg'] as num).toDouble(),
  );
}

/// Tape measurements, all in cm. Any field may be missing.
/// [chest] is shown as "Bust" for female profiles (ROADMAP §3).
class Measurement {
  final int? id;
  final DateTime date;
  final double? neck;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arm;
  final double? thigh;

  const Measurement({
    this.id,
    required this.date,
    this.neck, this.chest, this.waist, this.hips, this.arm, this.thigh,
  });

  bool get isEmpty =>
      [neck, chest, waist, hips, arm, thigh].every((v) => v == null);

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date.millisecondsSinceEpoch,
    'neck': neck, 'chest': chest, 'waist': waist,
    'hips': hips, 'arm': arm, 'thigh': thigh,
  };

  factory Measurement.fromMap(Map<String, dynamic> m) {
    double? d(String k) => (m[k] as num?)?.toDouble();
    return Measurement(
      id: m['id'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      neck: d('neck'), chest: d('chest'), waist: d('waist'),
      hips: d('hips'), arm: d('arm'), thigh: d('thigh'),
    );
  }
}

/// Which measurements a profile is asked for. Hips are needed for the female
/// body-fat formula; everyone can still fill in every field.
enum MeasureField { neck, chest, waist, hips, arm, thigh }

List<MeasureField> measureFieldsFor(Sex sex) => switch (sex) {
      Sex.male => const [
          MeasureField.chest, MeasureField.waist, MeasureField.neck,
          MeasureField.arm, MeasureField.thigh, MeasureField.hips,
        ],
      Sex.female => const [
          MeasureField.chest, MeasureField.waist, MeasureField.hips,
          MeasureField.neck, MeasureField.arm, MeasureField.thigh,
        ],
    };

abstract final class BodyFat {
  /// US Navy circumference method (Hodgdon & Beckett), metric form.
  /// Needs neck + waist (male) or neck + waist + hips (female), in cm.
  /// Returns null when a measurement is missing or the inputs are
  /// physically impossible for the formula (e.g. waist ≤ neck).
  static double? navy({
    required Sex sex,
    required double heightCm,
    double? neck,
    double? waist,
    double? hips,
  }) {
    if (neck == null || waist == null || heightCm <= 0) return null;
    final double result;
    switch (sex) {
      case Sex.male:
        final d = waist - neck;
        if (d <= 0) return null;
        result = 495 /
                (1.0324 -
                    0.19077 * _log10(d) +
                    0.15456 * _log10(heightCm)) -
            450;
      case Sex.female:
        if (hips == null) return null;
        final d = waist + hips - neck;
        if (d <= 0) return null;
        result = 495 /
                (1.29579 -
                    0.35004 * _log10(d) +
                    0.22100 * _log10(heightCm)) -
            450;
    }
    // Outside this range the inputs are typos, not a real body.
    return (result < 2 || result > 70) ? null : result;
  }

  /// Body-fat estimate for a profile from its latest measurements.
  static double? forProfile(UserProfile profile, Measurement? m) => m == null
      ? null
      : navy(
          sex: profile.formulaSex,
          heightCm: profile.heightInCm,
          neck: m.neck,
          waist: m.waist,
          hips: m.hips,
        );

  static double _log10(num x) => math.log(x) / math.ln10;
}

/// Trailing average weight over [days] calendar days ending at each log.
/// Smooths day-to-day water swings so the trend is readable.
/// [logs] must be sorted oldest first; the result has one value per log.
List<double> movingAverage(List<WeightLog> logs, {int days = 7}) {
  final out = <double>[];
  var start = 0;
  var sum = 0.0;
  for (var i = 0; i < logs.length; i++) {
    sum += logs[i].weightKg;
    final windowStart = logs[i].date.subtract(Duration(days: days - 1));
    while (logs[start].date.isBefore(_dayStart(windowStart))) {
      sum -= logs[start].weightKg;
      start++;
    }
    out.add(sum / (i - start + 1));
  }
  return out;
}

DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
