/// Conversions between stored values (kg, cm) and the user's display units.
///
/// Weight shows in the profile's weight unit ('kg' | 'lbs'). Lengths show in
/// cm, or inches when the profile's height unit is 'ft'.
abstract final class Units {
  static const kgPerLb = 0.453592;
  static const cmPerIn = 2.54;

  static double kgTo(String weightUnit, double kg) =>
      weightUnit == 'lbs' ? kg / kgPerLb : kg;

  static double toKg(String weightUnit, double value) =>
      weightUnit == 'lbs' ? value * kgPerLb : value;

  /// 'cm' or 'in', from the profile's height unit.
  static String lengthUnit(String heightUnit) =>
      heightUnit == 'cm' ? 'cm' : 'in';

  static double cmTo(String lengthUnit, double cm) =>
      lengthUnit == 'in' ? cm / cmPerIn : cm;

  static double toCm(String lengthUnit, double value) =>
      lengthUnit == 'in' ? value * cmPerIn : value;

  /// e.g. "81.4 kg" / "179.5 lbs"
  static String weight(double kg, String weightUnit) =>
      '${kgTo(weightUnit, kg).toStringAsFixed(1)} $weightUnit';

  /// e.g. "84.0 cm" / "33.1 in"
  static String length(double cm, String lengthUnit) =>
      '${cmTo(lengthUnit, cm).toStringAsFixed(1)} $lengthUnit';
}
