import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bmi_health/features/profile/domain/user_profile.dart';

enum Muscle {
  chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves,
  core,
}

enum ExerciseEquipment { barbell, dumbbell, machine, cable, bodyweight, band, kettlebell }

enum Difficulty { beginner, intermediate, advanced }

/// Recommended sets × reps (or seconds for timed holds) and rest.
class Prescription {
  final int sets;
  final int repMin;
  final int repMax;

  /// True for holds such as the plank: reps are seconds.
  final bool timed;
  final int restSec;

  const Prescription({
    this.sets = 3,
    this.repMin = 8,
    this.repMax = 12,
    this.timed = false,
    this.restSec = 90,
  });

  factory Prescription.fromJson(Map<String, dynamic>? j) => j == null
      ? const Prescription()
      : Prescription(
          sets: j['sets'] as int,
          repMin: j['repMin'] as int,
          repMax: j['repMax'] as int,
          timed: j['timed'] as bool? ?? false,
          restSec: j['restSec'] as int,
        );
}

class Exercise {
  final String id;
  final Map<String, String> name; // locale → name
  final Muscle primary;
  final List<Muscle> secondary;
  final ExerciseEquipment equipment;
  final Difficulty difficulty;
  final Map<String, List<String>> steps; // locale → steps
  final Map<String, List<String>> tips;
  final Map<String, List<String>> mistakes;
  final Prescription prescription;

  /// Jumping / impact moves; avoided for high BMI and beginners.
  final bool highImpact;

  /// Demonstrator video URLs (HLS/MP4). null until the clip is filmed.
  final String? maleVideo;
  final String? femaleVideo;

  const Exercise({
    required this.id,
    required this.name,
    required this.primary,
    this.secondary = const [],
    required this.equipment,
    required this.difficulty,
    this.steps = const {},
    this.tips = const {},
    this.mistakes = const {},
    this.prescription = const Prescription(),
    this.highImpact = false,
    this.maleVideo,
    this.femaleVideo,
  });

  /// Name in [locale], falling back to English.
  String nameIn(String locale) => name[locale] ?? name['en'] ?? id;

  List<String> stepsIn(String locale) => steps[locale] ?? steps['en'] ?? const [];
  List<String> tipsIn(String locale) => tips[locale] ?? tips['en'] ?? const [];
  List<String> mistakesIn(String locale) =>
      mistakes[locale] ?? mistakes['en'] ?? const [];

  /// The clip matching the profile's demonstrator (ROADMAP §3), falling back
  /// to the other demonstrator if only one has been filmed.
  String? videoFor(Sex demonstrator) => demonstrator == Sex.male
      ? (maleVideo ?? femaleVideo)
      : (femaleVideo ?? maleVideo);

  factory Exercise.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? n) =>
        values.firstWhere((v) => v.name == n);
    final videos = (j['videos'] as Map?) ?? const {};
    Map<String, List<String>> texts(String key) => {
          for (final e in ((j[key] as Map?) ?? const {}).entries)
            e.key as String: List<String>.from(e.value as List)
        };
    return Exercise(
      id: j['id'] as String,
      name: Map<String, String>.from(j['name'] as Map),
      primary: byName(Muscle.values, j['primary']),
      secondary: [
        for (final m in (j['secondary'] as List? ?? const []))
          byName(Muscle.values, m)
      ],
      equipment: byName(ExerciseEquipment.values, j['equipment']),
      difficulty: byName(Difficulty.values, j['difficulty']),
      steps: texts('steps'),
      tips: texts('tips'),
      mistakes: texts('mistakes'),
      prescription: Prescription.fromJson(j['prescription'] as Map<String, dynamic>?),
      highImpact: j['highImpact'] as bool? ?? false,
      maleVideo: videos['male'] as String?,
      femaleVideo: videos['female'] as String?,
    );
  }
}

/// Equipment the user can use, from their profile answer.
Set<ExerciseEquipment> equipmentFor(Equipment? e) => switch (e) {
      Equipment.none => {ExerciseEquipment.bodyweight},
      Equipment.home => {
          ExerciseEquipment.bodyweight, ExerciseEquipment.dumbbell,
          ExerciseEquipment.band, ExerciseEquipment.kettlebell,
        },
      Equipment.gym || null => ExerciseEquipment.values.toSet(),
    };

/// Exercise catalog. Bundled with the app (assets/exercises/catalog.json);
/// a remote, versioned catalog can replace the source later.
class ExerciseCatalog {
  ExerciseCatalog(this.exercises)
      : _byId = {for (final e in exercises) e.id: e};

  final List<Exercise> exercises;
  final Map<String, Exercise> _byId;

  Exercise? byId(String id) => _byId[id];

  /// Same main muscle, closest difficulty first, preferring different
  /// equipment ("machine busy? do this instead").
  List<Exercise> alternativesFor(Exercise e,
      {Set<ExerciseEquipment>? available, int max = 3}) {
    final options = exercises
        .where((x) =>
            x.id != e.id &&
            x.primary == e.primary &&
            (available == null || available.contains(x.equipment)))
        .toList()
      ..sort((a, b) {
        int score(Exercise x) =>
            (x.difficulty.index - e.difficulty.index).abs() * 2 +
            (x.equipment == e.equipment ? 1 : 0);
        final c = score(a).compareTo(score(b));
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    return options.take(max).toList();
  }

  static ExerciseCatalog parse(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return ExerciseCatalog([
      for (final e in data['exercises'] as List)
        Exercise.fromJson(e as Map<String, dynamic>)
    ]);
  }

  static Future<ExerciseCatalog> loadBundled() async =>
      parse(await rootBundle.loadString('assets/exercises/catalog.json'));
}
