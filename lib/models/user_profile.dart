class UserProfile {
  final double height;
  final String heightUnit; // 'cm' | 'ft'
  final double weight;
  final String weightUnit; // 'kg' | 'lbs'
  final int age;
  final String gender; // 'm' | 'f' | 'o'

  const UserProfile({
    this.height = 172,
    this.heightUnit = 'cm',
    this.weight = 70,
    this.weightUnit = 'kg',
    this.age = 30,
    this.gender = 'f',
  });

  UserProfile copyWith({
    double? height, String? heightUnit,
    double? weight, String? weightUnit,
    int? age, String? gender,
  }) => UserProfile(
    height: height ?? this.height,
    heightUnit: heightUnit ?? this.heightUnit,
    weight: weight ?? this.weight,
    weightUnit: weightUnit ?? this.weightUnit,
    age: age ?? this.age,
    gender: gender ?? this.gender,
  );

  double get heightInCm {
    if (heightUnit == 'cm') return height;
    // height stored as feet (decimal: 5.10 = 5ft 10in)
    final feet = height.truncate();
    final inches = (height - feet) * 100;
    return feet * 30.48 + inches * 2.54;
  }

  double get weightInKg {
    if (weightUnit == 'kg') return weight;
    return weight * 0.453592;
  }

  Map<String, dynamic> toMap() => {
    'height': height,
    'height_unit': heightUnit,
    'weight': weight,
    'weight_unit': weightUnit,
    'age': age,
    'gender': gender,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    height: (m['height'] as num?)?.toDouble() ?? 172,
    heightUnit: m['height_unit'] as String? ?? 'cm',
    weight: (m['weight'] as num?)?.toDouble() ?? 70,
    weightUnit: m['weight_unit'] as String? ?? 'kg',
    age: m['age'] as int? ?? 30,
    gender: m['gender'] as String? ?? 'f',
  );
}
