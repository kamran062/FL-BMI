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
                const SizedBox(height: 20),
                OverlineLabel(l.programs),
                const SizedBox(height: 8),
                SizedBox(
                  height: 168,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final (i, p) in Programs.orderedFor(profile).indexed)
                        _ProgramCard(
                          program: p,
                          recommended: i == 0,
                          enabled: active == null,
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
  final ValueChanged<ProgramDay> onStartDay;

  const _ProgramCard({
    required this.program,
    required this.recommended,
    required this.enabled,
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
              const Spacer(),
              // One row of day buttons; scrolls if a program has many days
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final d in program.days)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
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

