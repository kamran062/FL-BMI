import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/muscle_day.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:bmi_health/features/train/challenges/ui/challenges_screen.dart';
import 'package:bmi_health/features/train/workouts/ui/workout_detail_screen.dart';

/// Train tab: start or resume a workout, routines, library, history.
class TrainScreen extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenRepCounter;

  const TrainScreen({
    super.key,
    required this.onOpenWorkout,
    required this.onOpenLibrary,
    required this.onOpenRepCounter,
  });

  Future<void> _start(BuildContext context, {Routine? routine}) async {
    final l = context.l10n;
    await context
        .read<WorkoutProvider>()
        .start(routine: routine, name: l.workoutDefaultName);
    onOpenWorkout();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final workouts = context.watch<WorkoutProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final unit = profile.weightUnit;
    final active = workouts.active;
    final empty = GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5);

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: ScreenHeader(title: l.trainTitle, large: true)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                if (active != null)
                  AppCard(
                    padding: 16,
                    tint: brand.withAlpha(30),
                    onTap: onOpenWorkout,
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded, color: brand, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.resumeWorkout,
                                  style: GoogleFonts.inter(
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                              Text(l.workoutInProgress(
                                  l.minutesShort(active.duration.inMinutes))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  AppButton(
                    label: l.startEmptyWorkout,
                    icon: Icons.add_rounded,
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => _start(context),
                  ),
                if (workouts.deloadDue(profile.daysPerWeek)) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    padding: 16,
                    tint: AppColors.bmiOver.withAlpha(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.battery_charging_full_rounded, color: AppColors.bmiOver),
                          const SizedBox(width: 8),
                          Text(l.trainDeloadTitle,
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 6),
                        Text(l.trainDeloadBody, style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(onPressed: workouts.skipDeload, child: Text(l.trainDeloadSkip)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: AppButton(
                      label: l.exerciseLibrary,
                      icon: Icons.menu_book_rounded,
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: onOpenLibrary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: l.repCounter,
                      icon: Icons.videocam_rounded,
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: onOpenRepCounter,
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                AppCard(
                  padding: 4,
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                          builder: (c) => ChallengesScreen(onBack: () => Navigator.pop(c)))),
                  child: ListTile(
                    leading: const Icon(Icons.home_rounded, color: AppColors.bmiOver),
                    title: Text(l.homeChallenges,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    subtitle: Text(l.homeChallengesBody),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                OverlineLabel(l.muscleDayTitle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in MuscleDay.values)
                      ActionChip(
                        avatar: const Icon(Icons.fitness_center_rounded, size: 16),
                        label: Text(muscleDayName(l, d)),
                        onPressed: active != null ? null : () => _showMuscleDay(context, d),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                OverlineLabel(l.programs),
                const SizedBox(height: 8),
                SizedBox(
                  height: 190,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (i, p) in Programs.orderedFor(profile).indexed)
                        _ProgramCard(
                          program: p,
                          recommended: i == 0,
                          enabled: active == null,
                          week: ProgramWeek.of(p, workouts.history, DateTime.now()),
                          onStartDay: (day) => _start(context,
                              routine: Routine(
                                  name: '${p.nameIn(l.localeName)} · ${day.nameIn(l.localeName)}',
                                  exerciseIds: day.exerciseIds)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _MuscleMapCard(),
                const SizedBox(height: 20),
                OverlineLabel(l.routines),
                const SizedBox(height: 8),
                if (workouts.routines.isEmpty)
                  Text(l.routinesEmpty, style: empty)
                else
                  for (final r in workouts.routines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: 4,
                        child: ListTile(
                          title: Text(r.name,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text(l.exercisesCount(r.exerciseIds.length)),
                          trailing: IconButton(
                            icon: Icon(Icons.play_arrow_rounded, color: brand),
                            onPressed: active == null
                                ? () => _start(context, routine: r)
                                : null,
                          ),
                          onLongPress: () => workouts.deleteRoutine(r.id!),
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                OverlineLabel(l.recentWorkouts),
                const SizedBox(height: 8),
                if (workouts.history.isEmpty)
                  Text(l.noWorkoutsYet, style: empty)
                else
                  for (final h in workouts.history.take(20))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: 4,
                        child: ListTile(
                          onTap: () => WorkoutDetailScreen.open(context, h.workout.id!),
                          title: Text(
                              h.workout.name.isEmpty
                                  ? l.workoutDefaultName
                                  : h.workout.name,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${DateFormat('d MMM', l.localeName).format(h.workout.startedAt)}'
                            ' · ${l.minutesShort(h.workout.duration.inMinutes)}'
                            ' · ${l.volumeLabel(Units.weight(h.volumeKg, unit))}',
                          ),
                          trailing: h.prCount > 0
                              ? Chip(
                                  label: Text('🏆 ${l.prCount(h.prCount)}'),
                                  visualDensity: VisualDensity.compact,
                                )
                              : null,
                        ),
                      ),
                    ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Program program;
  final bool recommended;
  final bool enabled;
  final ProgramWeek week;
  final ValueChanged<ProgramDay> onStartDay;

  const _ProgramCard({
    required this.program,
    required this.recommended,
    required this.enabled,
    required this.week,
    required this.onStartDay,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: SizedBox(
        width: 230,
        child: AppCard(
          padding: 14,
          tint: recommended ? brand.withAlpha(24) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommended)
                Text(l.recommended.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700, color: brand)),
              Text(program.nameIn(l.localeName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              Text(l.programDays(program.daysPerWeek),
                  style: GoogleFonts.inter(fontSize: 12, color: fg3)),
              if (week.started) ...[
                const SizedBox(height: 6),
                _WeekDots(week: week, color: brand),
              ],
              const Spacer(),
              // One row of day buttons; scrolls if a program has many days
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (i, d) in program.days.indexed)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          // Trained this week ✓; the next day once started
                          avatar: week.doneDays.contains(i)
                              ? Icon(Icons.check_rounded, size: 16, color: brand)
                              : week.started && i == week.nextDay && !week.complete
                                  ? Icon(Icons.play_arrow_rounded, size: 16, color: brand)
                                  : null,
                          tooltip: week.started && i == week.nextDay ? l.trainNext : null,
                          label: Text(d.nameIn(l.localeName)),
                          onPressed: enabled ? () => onStartDay(d) : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "This week 2/3" with one dot per planned day.
class _WeekDots extends StatelessWidget {
  final ProgramWeek week;
  final Color color;
  const _WeekDots({required this.week, required this.color});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    return Row(children: [
      for (var i = 0; i < week.target; i++)
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsetsDirectional.only(end: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < week.done ? color : sunken,
          ),
        ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          week.complete ? l.trainWeekDone : l.trainThisWeek(week.done, week.target),
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    ]);
  }
}

/// Weekly sets per muscle as heat bars (ROADMAP 3.3).
class _MuscleMapCard extends StatelessWidget {
  const _MuscleMapCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final volume = MuscleVolume.weeklySets(
        context.watch<WorkoutProvider>().setsSince(weekStart),
        context.read<ExerciseCatalog>());
    final under = MuscleVolume.underTrained(volume);

    Color heat(double sets) => sets >= MuscleVolume.target
        ? AppColors.bmiObese
        : sets >= MuscleVolume.low
            ? AppColors.bmiOver
            : sets > 0
                ? AppColors.bmiNormal
                : sunken;

    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.muscleMapTitle),
          const SizedBox(height: 4),
          Text(l.muscleMapHint,
              style: GoogleFonts.inter(fontSize: 12, color: fg3, height: 1.4)),
          const SizedBox(height: 10),
          for (final m in Muscle.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                SizedBox(
                  width: 110,
                  child: Text(l.muscle(m),
                      style: GoogleFonts.inter(fontSize: 13, color: fg2)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (volume[m]! / MuscleVolume.target).clamp(0.0, 1.0),
                      minHeight: 8,
                      color: heat(volume[m]!),
                      backgroundColor: sunken,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(l.setsCount(_fmt(volume[m]!)),
                      textAlign: TextAlign.end,
                      style: GoogleFonts.inter(fontSize: 12, color: fg3)),
                ),
              ]),
            ),
          if (under.isNotEmpty && under.length < Muscle.values.length) ...[
            const SizedBox(height: 8),
            Text(l.undertrained(under.map(l.muscle).join(', ')),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

String muscleDayName(AppLocalizations l, MuscleDay d) => switch (d) {
      MuscleDay.chest => l.dayChest,
      MuscleDay.back => l.dayBack,
      MuscleDay.shoulders => l.dayShoulders,
      MuscleDay.arms => l.dayArms,
      MuscleDay.legs => l.dayLegs,
      MuscleDay.glutes => l.dayGlutes,
      MuscleDay.core => l.dayCore,
    };

/// Builds the day's plan from profile, equipment and BMI, shows it, and
/// starts it with the recommended sets prefilled.
void _showMuscleDay(BuildContext context, MuscleDay day) {
  final profile = context.read<ProfileProvider>().profile;
  // Latest logged weight, else the one from the profile
  final weight = context.read<BodyProvider>().latestWeight?.weightKg ??
      (profile.weightInKg > 0 ? profile.weightInKg : null);
  final height = profile.heightInCm;
  final bmi = weight != null && height > 0 ? BmiCalculator.calculate(weight, height) : null;
  final plan = MuscleDayBuilder.build(
    day,
    context.read<ExerciseCatalog>(),
    equipment: equipmentFor(profile.equipment),
    experience: profile.experience,
    bmi: bmi,
  );
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheet) => _MuscleDaySheet(plan: plan, parent: context),
  );
}

class _MuscleDaySheet extends StatelessWidget {
  final MuscleDayPlan plan;
  final BuildContext parent;
  const _MuscleDaySheet({required this.plan, required this.parent});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final name = muscleDayName(l, plan.day);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          children: [
            Text(l.dayWorkout(name),
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
            if (plan.exercises.isNotEmpty)
              Text(
                l.planSummary(plan.exercises.length, plan.totalSets, plan.estimatedTime.inMinutes),
                style: GoogleFonts.inter(fontSize: 14, color: fg3),
              ),
            const SizedBox(height: 6),
            if (plan.jointFriendly)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  const Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.bmiOver),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.jointFriendlyNote,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.bmiOver)),
                  ),
                ]),
              ),
            Text(plan.exercises.isEmpty ? l.noExercisesForDay : l.planBasedOn,
                style: GoogleFonts.inter(fontSize: 13, color: fg3)),
            const SizedBox(height: 8),
            for (final (i, e) in plan.exercises.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(e.nameIn(l.localeName),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text([
                  e.prescription.timed
                      ? l.setsSeconds(e.prescription.sets, e.prescription.repMin, e.prescription.repMax)
                      : l.setsReps(e.prescription.sets, e.prescription.repMin, e.prescription.repMax),
                  l.restBetween('${e.prescription.restSec ~/ 60}:${(e.prescription.restSec % 60).toString().padLeft(2, '0')}'),
                ].join(' · ')),
                trailing: const Icon(Icons.info_outline_rounded),
                onTap: () => parent.push(Routes.exercise(e.id)),
              ),
            const SizedBox(height: 12),
            if (plan.exercises.isNotEmpty)
              AppButton(
                label: l.startThisWorkout,
                icon: Icons.play_arrow_rounded,
                fullWidth: true,
                onPressed: () async {
                  final workouts = parent.read<WorkoutProvider>();
                  Navigator.pop(context);
                  await workouts.start(
                    routine: Routine(
                        name: l.dayWorkout(name),
                        exerciseIds: [for (final e in plan.exercises) e.id]),
                    targets: {for (final e in plan.exercises) e.id: e.prescription},
                  );
                  if (parent.mounted) parent.push(Routes.workout);
                },
              ),
          ],
        ),
      ),
    );
  }
}

