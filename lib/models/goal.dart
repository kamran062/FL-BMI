class Goal {
  final int? id;
  final double currentWeight;
  final double targetWeight;
  final int weeks;
  final DateTime startDate;
  final bool active;

  const Goal({
    this.id,
    required this.currentWeight,
    required this.targetWeight,
    required this.weeks,
    required this.startDate,
    this.active = true,
  });

  double get diff => currentWeight - targetWeight;
  double get perWeek => weeks > 0 ? diff.abs() / weeks : 0;
  bool get isSafe => perWeek <= 1.0;
  DateTime get targetDate => startDate.add(Duration(days: weeks * 7));

  String get direction {
    if (diff > 0.05) return 'lose';
    if (diff < -0.05) return 'gain';
    return 'maintain';
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'current_weight': currentWeight,
    'target_weight': targetWeight,
    'weeks': weeks,
    'start_date': startDate.millisecondsSinceEpoch,
    'active': active ? 1 : 0,
  };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
    id: m['id'] as int?,
    currentWeight: (m['current_weight'] as num).toDouble(),
    targetWeight: (m['target_weight'] as num).toDouble(),
    weeks: m['weeks'] as int,
    startDate: DateTime.fromMillisecondsSinceEpoch(m['start_date'] as int),
    active: (m['active'] as int) == 1,
  );
}
