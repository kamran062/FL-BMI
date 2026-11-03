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

/// Train tab: start or resume a workout, routines, library, history.
class TrainScreen extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenLibrary;

  const TrainScreen(
      {super.key, required this.onOpenWorkout, required this.onOpenLibrary});

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
    final unit = context.watch<ProfileProvider>().profile.weightUnit;
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
                AppButton(
                  label: l.exerciseLibrary,
                  icon: Icons.menu_book_rounded,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: onOpenLibrary,
                ),
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
