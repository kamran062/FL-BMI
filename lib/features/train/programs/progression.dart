import 'dart:math' as math;

import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';

/// What to lift next time (ROADMAP 3.2).
class Suggestion {
  final double weightKg;
  final int reps;
  final SuggestionReason reason;

  const Suggestion(this.weightKg, this.reps, this.reason);
}

enum SuggestionReason {
  /// Hit the top of the rep range on every set → add weight.
  increase,

  /// Within the range → add a rep at the same weight.
  addRep,

  /// Missed the bottom of the range twice in a row → back off ~10 %.
  deload,

  /// No history yet.
  firstTime,

  /// Scheduled lighter week after a block of hard weeks.
  deloadWeek,

  /// Hit the top of the range but rated it 9.5+ → stay at this weight.
  hold,
}

/// Double progression: work up the rep range at a fixed weight, then add
/// weight and start again at the bottom of the range.
abstract final class Progression {
  static const repMin = 8;
  static const repMax = 12;

  /// Smallest practical jump: barbells 2.5 kg, dumbbells/cables/machines
  /// 1–2 kg; bodyweight exercises progress by reps only.
  static double increment(ExerciseEquipment e) => switch (e) {
        ExerciseEquipment.barbell => 2.5,
        ExerciseEquipment.dumbbell || ExerciseEquipment.kettlebell => 2.0,
        ExerciseEquipment.cable || ExerciseEquipment.machine => 2.5,
        ExerciseEquipment.band || ExerciseEquipment.bodyweight => 0,
      };

  /// [sessions]: completed sets of this exercise, one list per workout,
  /// oldest first.
  ///
  /// Effort ratings (RPE) refine it: very hard top sets hold the weight,
  /// easy ones (7 or less) jump two steps. In a [deloadWeek] everything is
  /// about 10 % lighter (bodyweight: about 30 % fewer reps).
  static Suggestion suggest(List<List<WorkoutSet>> sessions, ExerciseEquipment eq, {bool deloadWeek = false}) {
    final s = _suggest(sessions, eq);
    if (!deloadWeek || s.reason == SuggestionReason.firstTime) return s;
    final step = increment(eq);
    if (step == 0 || s.weightKg == 0) {
      return Suggestion(s.weightKg, (s.reps * 0.7).round().clamp(1, 50), SuggestionReason.deloadWeek);
    }
    // Nearest plate step, so it stays close to 10 %
    return Suggestion((s.weightKg * 0.9 / step).roundToDouble() * step, s.reps, SuggestionReason.deloadWeek);
  }

  static Suggestion _suggest(List<List<WorkoutSet>> sessions, ExerciseEquipment eq) {
    final done = [
      for (final s in sessions)
        if (s.any((x) => x.counts)) s.where((x) => x.counts).toList()
    ];
    if (done.isEmpty) return const Suggestion(0, repMin, SuggestionReason.firstTime);

    final last = done.last;
    final top = last.reduce((a, b) => a.weightKg >= b.weightKg ? a : b);
    final atTop = last.where((s) => s.weightKg == top.weightKg);
    final minReps = atTop.map((s) => s.reps).reduce((a, b) => a < b ? a : b);
    final step = increment(eq);

    // Two sessions in a row below the range at the same weight → deload
    if (done.length >= 2 && minReps < repMin && step > 0) {
      final prev = done[done.length - 2];
      final prevTop = prev.reduce((a, b) => a.weightKg >= b.weightKg ? a : b);
      final prevMin = prev
          .where((s) => s.weightKg == prevTop.weightKg)
          .map((s) => s.reps)
          .reduce((a, b) => a < b ? a : b);
      if (prevTop.weightKg == top.weightKg && prevMin < repMin) {
        final back = _round(top.weightKg * 0.9, step);
        return Suggestion(back, repMin, SuggestionReason.deload);
      }
    }

    if (minReps >= repMax && step > 0) {
      final rated = atTop.map((s) => s.rpe).whereType<double>().toList();
      final effort = rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length;
      if (effort != null && effort >= 9.5) {
        return Suggestion(top.weightKg, repMax, SuggestionReason.hold);
      }
      final jump = effort != null && effort <= 7 ? step * 2 : step;
      return Suggestion(top.weightKg + jump, repMin, SuggestionReason.increase);
    }
    return Suggestion(top.weightKg, (minReps + 1).clamp(1, step > 0 ? repMax : 50),
        SuggestionReason.addRep);
  }

  static double _round(double kg, double step) =>
      (kg / step).floorToDouble() * step;
}

/// A ready-made weekly plan (ROADMAP 3.1).
class Program {
  final String id;
  final Map<String, String> name;
  final int daysPerWeek;
  final Set<ExerciseEquipment> needs;
  final List<ProgramDay> days;

  const Program({
    required this.id,
    required this.name,
    required this.daysPerWeek,
    required this.needs,
    required this.days,
  });

  String nameIn(String locale) => name[locale] ?? name['en']!;

  /// Usable with this equipment.
  bool fits(Set<ExerciseEquipment> available) => needs.every(available.contains);
}

class ProgramDay {
  final Map<String, String> name;
  final List<String> exerciseIds;
  const ProgramDay(this.name, this.exerciseIds);

  String nameIn(String locale) => name[locale] ?? name['en']!;
}

/// Built-in programs. Every program is open to everyone; gender only
/// changes the order they are suggested in (ROADMAP §3).
abstract final class Programs {
  static const all = <Program>[
    Program(
      id: 'fullbody_home',
      name: {'en': 'Full body at home', 'ur': 'گھر پر پورے جسم کی ورزش'},
      daysPerWeek: 3,
      needs: {ExerciseEquipment.bodyweight},
      days: [
        ProgramDay({'en': 'Full body A', 'ur': 'پورا جسم A'},
            ['bodyweight_squat', 'push_up', 'glute_bridge', 'plank']),
        ProgramDay({'en': 'Full body B', 'ur': 'پورا جسم B'},
            ['walking_lunge', 'knee_push_up', 'bench_dip', 'standing_calf_raise']),
      ],
    ),
    Program(
      id: 'fullbody_beginner',
      name: {'en': 'Beginner full body (gym)', 'ur': 'ابتدائی پورا جسم (جم)'},
      daysPerWeek: 3,
      needs: {ExerciseEquipment.machine, ExerciseEquipment.dumbbell, ExerciseEquipment.cable},
      days: [
        ProgramDay({'en': 'Full body A', 'ur': 'پورا جسم A'},
            ['leg_press', 'dumbbell_bench_press', 'lat_pulldown', 'dumbbell_shoulder_press', 'plank']),
        ProgramDay({'en': 'Full body B', 'ur': 'پورا جسم B'},
            ['goblet_squat', 'seated_cable_row', 'incline_dumbbell_press', 'dumbbell_curl', 'tricep_pushdown']),
      ],
    ),
    Program(
      id: 'glutes_lower',
      name: {'en': 'Glutes & lower body', 'ur': 'کولہے اور نچلا جسم'},
      daysPerWeek: 3,
      needs: {ExerciseEquipment.barbell, ExerciseEquipment.dumbbell, ExerciseEquipment.kettlebell},
      days: [
        ProgramDay({'en': 'Glutes', 'ur': 'کولہے'},
            ['hip_thrust', 'romanian_deadlift', 'walking_lunge', 'glute_bridge']),
        ProgramDay({'en': 'Legs & core', 'ur': 'ٹانگیں اور پیٹ'},
            ['goblet_squat', 'kettlebell_swing', 'standing_calf_raise', 'plank']),
        ProgramDay({'en': 'Upper body', 'ur': 'اوپری جسم'},
            ['dumbbell_bench_press', 'dumbbell_row', 'lateral_raise', 'dumbbell_curl']),
      ],
    ),
    Program(
      id: 'ppl',
      name: {'en': 'Push / Pull / Legs', 'ur': 'پش / پُل / ٹانگیں'},
      daysPerWeek: 3,
      needs: {ExerciseEquipment.barbell, ExerciseEquipment.dumbbell, ExerciseEquipment.cable},
      days: [
        ProgramDay({'en': 'Push', 'ur': 'پش'},
            ['barbell_bench_press', 'overhead_press', 'incline_dumbbell_press', 'lateral_raise', 'tricep_pushdown']),
        ProgramDay({'en': 'Pull', 'ur': 'پُل'},
            ['barbell_deadlift', 'lat_pulldown', 'seated_cable_row', 'barbell_curl']),
        ProgramDay({'en': 'Legs', 'ur': 'ٹانگیں'},
            ['barbell_back_squat', 'romanian_deadlift', 'leg_press', 'standing_calf_raise']),
      ],
    ),
    Program(
      id: 'strength_5x5',
      name: {'en': 'Strength 5×5', 'ur': 'طاقت 5×5'},
      daysPerWeek: 3,
      needs: {ExerciseEquipment.barbell},
      days: [
        ProgramDay({'en': 'Workout A', 'ur': 'ورزش A'},
            ['barbell_back_squat', 'barbell_bench_press', 'dumbbell_row']),
        ProgramDay({'en': 'Workout B', 'ur': 'ورزش B'},
            ['barbell_back_squat', 'overhead_press', 'barbell_deadlift']),
      ],
    ),
  ];

  /// Programs ordered for this user: ones their equipment supports first,
  /// then by goal, then a gender-based nudge (ROADMAP §3). Nothing is hidden.
  static List<Program> orderedFor(UserProfile p) {
    final available = equipmentFor(p.equipment);
    int score(Program prog) {
      var s = prog.fits(available) ? 100 : 0;
      if (p.goal == FitnessGoal.getStronger && prog.id == 'strength_5x5') s += 20;
      if (p.goal == FitnessGoal.buildMuscle && prog.id == 'ppl') s += 20;
      if (p.experience == Experience.beginner &&
          prog.id.startsWith('fullbody')) {
        s += 15;
      }
      if (p.formulaSex == Sex.female && prog.id == 'glutes_lower') s += 10;
      if (p.formulaSex == Sex.male && prog.id == 'ppl') s += 5;
      return s;
    }
    return [...all]..sort((a, b) => score(b).compareTo(score(a)));
  }

  static Program? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Weekly training volume per muscle (ROADMAP 3.3 heatmap).
abstract final class MuscleVolume {
  /// Hard sets per muscle: a completed set counts 1 for the exercise's
  /// primary muscle and 0.5 for each secondary muscle.
  static Map<Muscle, double> weeklySets(
      Iterable<WorkoutSet> sets, ExerciseCatalog catalog) {
    final out = {for (final m in Muscle.values) m: 0.0};
    for (final s in sets.where((s) => s.counts)) {
      final e = catalog.byId(s.exerciseId);
      if (e == null) continue;
      out[e.primary] = out[e.primary]! + 1;
      for (final m in e.secondary) {
        out[m] = out[m]! + 0.5;
      }
    }
    return out;
  }

  /// 10+ hard sets a week is a common target for growth; below 4 counts as
  /// under-trained.
  static const target = 10.0;
  static const low = 4.0;

  static List<Muscle> underTrained(Map<Muscle, double> volume) =>
      [for (final e in volume.entries) if (e.value < low) e.key];
}

/// This week's progress on a program, read from workout history.
/// Program workouts are named "program · day" (in either language).
class ProgramWeek {
  final int done;
  final int target;

  /// Days of the program (by index) already trained this week.
  final Set<int> doneDays;

  /// The day to train next: the one after the last program workout.
  final int nextDay;

  const ProgramWeek(
      {required this.done, required this.target, required this.doneDays, required this.nextDay});

  bool get started => done > 0;
  bool get complete => done >= target;

  /// The program day a workout name belongs to, or null.
  static int? dayOf(Program p, String workoutName) {
    for (final (i, d) in p.days.indexed) {
      for (final locale in p.name.keys) {
        if (workoutName == '${p.nameIn(locale)} · ${d.nameIn(locale)}') return i;
      }
    }
    return null;
  }

  /// [history] is newest first; weeks start on Monday.
  static ProgramWeek of(Program p, List<WorkoutSummary> history, DateTime now) {
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    var done = 0;
    final days = <int>{};
    int? last;
    for (final h in history) {
      final day = dayOf(p, h.workout.name);
      if (day == null) continue;
      last ??= day;
      if (!h.workout.startedAt.isBefore(weekStart)) {
        done++;
        days.add(day);
      }
    }
    return ProgramWeek(
      done: done,
      target: p.daysPerWeek,
      doneDays: days,
      nextDay: last == null ? 0 : (last + 1) % p.days.length,
    );
  }
}

/// Planned lighter weeks (ROADMAP 3.1): after [hardWeeks] hard training
/// weeks in a row, the next week is a deload week, then the count restarts.
abstract final class Deload {
  static const hardWeeks = 5;

  /// Monday 00:00 of [d]'s week.
  static DateTime weekStart(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

  /// Hard weeks in a row right before [now]'s week. A week is hard with at
  /// least `daysPerWeek - 1` workouts (and at least 2).
  static int streak(Iterable<WorkoutSummary> history, DateTime now, int daysPerWeek) {
    final need = math.max(2, daysPerWeek - 1);
    final perWeek = <DateTime, int>{};
    for (final h in history) {
      final w = weekStart(h.workout.startedAt);
      perWeek[w] = (perWeek[w] ?? 0) + 1;
    }
    var week = weekStart(now);
    week = DateTime(week.year, week.month, week.day - 7);
    var n = 0;
    while ((perWeek[week] ?? 0) >= need) {
      n++;
      week = DateTime(week.year, week.month, week.day - 7);
    }
    return n;
  }

  /// Whether [now]'s week should be a deload week.
  static bool due(Iterable<WorkoutSummary> history, DateTime now, int daysPerWeek) {
    final n = streak(history, now, daysPerWeek);
    return n >= hardWeeks && n % (hardWeeks + 1) == hardWeeks;
  }
}
