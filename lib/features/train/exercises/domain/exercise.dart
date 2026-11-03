import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bmi_health/features/profile/domain/user_profile.dart';

enum Muscle {
  chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves,
  core,
}

enum ExerciseEquipment { barbell, dumbbell, machine, cable, bodyweight, band, kettlebell }

enum Difficulty { beginner, intermediate, advanced }

class Exercise {
  final String id;
  final Map<String, String> name; // locale → name
  final Muscle primary;
  final List<Muscle> secondary;
  final ExerciseEquipment equipment;
  final Difficulty difficulty;
  final Map<String, List<String>> steps; // locale → steps

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
    this.maleVideo,
    this.femaleVideo,
  });

  /// Name in [locale], falling back to English.
  String nameIn(String locale) => name[locale] ?? name['en'] ?? id;

  List<String> stepsIn(String locale) => steps[locale] ?? steps['en'] ?? const [];

  /// The clip matching the profile's demonstrator (ROADMAP §3), falling back
  /// to the other demonstrator if only one has been filmed.
  String? videoFor(Sex demonstrator) => demonstrator == Sex.male
      ? (maleVideo ?? femaleVideo)
      : (femaleVideo ?? maleVideo);

  factory Exercise.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? n) =>
        values.firstWhere((v) => v.name == n);
    final videos = (j['videos'] as Map?) ?? const {};
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
      steps: {
        for (final e in ((j['steps'] as Map?) ?? const {}).entries)
          e.key as String: List<String>.from(e.value as List)
      },
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
