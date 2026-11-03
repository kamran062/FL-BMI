/// Biological basis for sex-specific formulas (BMR, US Navy body fat) and
/// the exercise demonstrator. Users with gender 'o' choose one explicitly.
enum Sex { male, female }

/// Which demonstrator the exercise videos show. [auto] follows the profile.
enum DemonstratorPref { auto, male, female }

enum FitnessGoal { loseFat, buildMuscle, getStronger, stayFit }

enum Experience { beginner, intermediate, advanced }

enum Equipment { gym, home, none }

class UserProfile {
  final String name;
  final double height;
  final String heightUnit; // 'cm' | 'ft'
  final double weight;
  final String weightUnit; // 'kg' | 'lbs'
  final int age;
  final String gender; // 'm' | 'f' | 'o'

  // ── Profile v2 (Phase 1.1) ──────────────────────────────────────────
  final DemonstratorPref demonstratorPref;

  /// Only asked when [gender] is 'o'; ignored otherwise.
  final Sex formulaBasis;
  final FitnessGoal? goal;
  final Experience? experience;
  final Equipment? equipment;
  final int daysPerWeek;
  final bool cycleTrackingEnabled;

  /// True once the user has answered the profile questions.
  final bool completed;

  static const minDaysPerWeek = 2;
  static const maxDaysPerWeek = 6;

  const UserProfile({
    this.name = '',
    this.height = 172,
    this.heightUnit = 'cm',
    this.weight = 70,
    this.weightUnit = 'kg',
    this.age = 30,
    this.gender = 'f',
    this.demonstratorPref = DemonstratorPref.auto,
    this.formulaBasis = Sex.female,
    this.goal,
    this.experience,
    this.equipment,
    this.daysPerWeek = 3,
    this.cycleTrackingEnabled = false,
    this.completed = false,
  });

  UserProfile copyWith({
    String? name,
    double? height, String? heightUnit,
    double? weight, String? weightUnit,
    int? age, String? gender,
    DemonstratorPref? demonstratorPref,
    Sex? formulaBasis,
    FitnessGoal? goal,
    Experience? experience,
    Equipment? equipment,
    int? daysPerWeek,
    bool? cycleTrackingEnabled,
    bool? completed,
  }) => UserProfile(
    name: name ?? this.name,
    height: height ?? this.height,
    heightUnit: heightUnit ?? this.heightUnit,
    weight: weight ?? this.weight,
    weightUnit: weightUnit ?? this.weightUnit,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    demonstratorPref: demonstratorPref ?? this.demonstratorPref,
    formulaBasis: formulaBasis ?? this.formulaBasis,
    goal: goal ?? this.goal,
    experience: experience ?? this.experience,
    equipment: equipment ?? this.equipment,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    cycleTrackingEnabled: cycleTrackingEnabled ?? this.cycleTrackingEnabled,
    completed: completed ?? this.completed,
  );

  double get heightInCm {
    if (heightUnit == 'cm') return height;
    // Values < 12 are the legacy feet.inches format, where the decimals are
    // inches ×100 (5.10 → 5'10", 5.08 → 5'8"); ≥ 12 are total inches
    if (height < 12) {
      final feet = height.truncate();
      final inches = ((height - feet) * 100).round().clamp(0, 11);
      return (feet * 12 + inches) * 2.54;
    }
    return height * 2.54;
  }

  double get weightInKg {
    if (weightUnit == 'kg') return weight;
    return weight * 0.453592;
  }

  // ── Gender-specific behaviour (ROADMAP §3) ──────────────────────────

  /// Basis for sex-specific formulas: from gender, or the user's choice
  /// when gender is 'o'.
  Sex get formulaSex => switch (gender) {
        'm' => Sex.male,
        'f' => Sex.female,
        _ => formulaBasis,
      };

  /// Which demonstrator exercise videos show: the explicit preference,
  /// otherwise the one matching the profile.
  Sex get demonstrator => switch (demonstratorPref) {
        DemonstratorPref.male => Sex.male,
        DemonstratorPref.female => Sex.female,
        DemonstratorPref.auto => formulaSex,
      };

  /// Cycle tracking is offered to female and 'other' profiles (opt-in).
  bool get cycleTrackingOffered => gender != 'm';

  // ── Persistence ─────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'name': name,
    'height': height,
    'height_unit': heightUnit,
    'weight': weight,
    'weight_unit': weightUnit,
    'age': age,
    'gender': gender,
    'demonstrator_pref': demonstratorPref.name,
    'formula_basis': formulaBasis.name,
    'goal': goal?.name,
    'experience': experience?.name,
    'equipment': equipment?.name,
    'days_per_week': daysPerWeek,
    'cycle_tracking': cycleTrackingEnabled ? 1 : 0,
    'completed': completed ? 1 : 0,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] as String? ?? '',
    height: (m['height'] as num?)?.toDouble() ?? 172,
    heightUnit: m['height_unit'] as String? ?? 'cm',
    weight: (m['weight'] as num?)?.toDouble() ?? 70,
    weightUnit: m['weight_unit'] as String? ?? 'kg',
    age: m['age'] as int? ?? 30,
    gender: m['gender'] as String? ?? 'f',
    demonstratorPref: _byName(DemonstratorPref.values, m['demonstrator_pref'])
        ?? DemonstratorPref.auto,
    formulaBasis: _byName(Sex.values, m['formula_basis']) ?? Sex.female,
    goal: _byName(FitnessGoal.values, m['goal']),
    experience: _byName(Experience.values, m['experience']),
    equipment: _byName(Equipment.values, m['equipment']),
    daysPerWeek: (m['days_per_week'] as int? ?? 3)
        .clamp(minDaysPerWeek, maxDaysPerWeek),
    cycleTrackingEnabled: (m['cycle_tracking'] as int? ?? 0) == 1,
    completed: (m['completed'] as int? ?? 0) == 1,
  );
}

/// Unknown names (e.g. written by a newer app version) read as null
/// instead of crashing.
T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
