class BmiEntry {
  final int? id;
  final double weight;
  final double height;
  final double bmi;
  final int age;
  final String gender;
  final String weightUnit;
  final String heightUnit;
  final DateTime date;

  const BmiEntry({
    this.id,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.age,
    required this.gender,
    required this.weightUnit,
    required this.heightUnit,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'weight': weight,
    'height': height,
    'bmi': bmi,
    'age': age,
    'gender': gender,
    'weight_unit': weightUnit,
    'height_unit': heightUnit,
    'date': date.millisecondsSinceEpoch,
  };

  factory BmiEntry.fromMap(Map<String, dynamic> m) => BmiEntry(
    id: m['id'] as int?,
    weight: (m['weight'] as num).toDouble(),
    height: (m['height'] as num).toDouble(),
    bmi: (m['bmi'] as num).toDouble(),
    age: m['age'] as int,
    gender: m['gender'] as String,
    weightUnit: m['weight_unit'] as String,
    heightUnit: m['height_unit'] as String,
    date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
  );

  BmiEntry copyWith({
    int? id, double? weight, double? height, double? bmi,
    int? age, String? gender, String? weightUnit, String? heightUnit,
    DateTime? date,
  }) => BmiEntry(
    id: id ?? this.id,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    bmi: bmi ?? this.bmi,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    weightUnit: weightUnit ?? this.weightUnit,
    heightUnit: heightUnit ?? this.heightUnit,
    date: date ?? this.date,
  );
}
