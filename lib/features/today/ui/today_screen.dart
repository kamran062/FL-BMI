import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/body/bmi/ui/tips_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/widgets/status_pill.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/fuel/ui/fuel_screen.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'dart:io' show Platform;
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/movement/ui/timeline_screen.dart';

/// Home dashboard: the day at a glance with one-tap actions.
class TodayScreen extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenFuel;
  final VoidCallback onOpenBody;
  final VoidCallback onCalculateBmi;
  final VoidCallback onOpenTips;
  final VoidCallback onOpenTimeline;

  const TodayScreen({
    super.key,
    required this.onOpenWorkout,
    required this.onOpenFuel,
    required this.onOpenBody,
    required this.onCalculateBmi,
    required this.onOpenTips,
    required this.onOpenTimeline,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    final profile = context.watch<ProfileProvider>().profile;
    final workouts = context.watch<WorkoutProvider>();
    final fuel = context.watch<FuelProvider>();
    final latestWeight = context.watch<BodyProvider>().latestWeight;
    final lastBmi = context.watch<BmiProvider>().lastEntry;
    final targets = Nutrition.targetsFor(profile);
    final tip = TipsScreen.tipOfTheDay(l, DateTime.now());

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final doneThisWeek = workouts.history
        .where((h) => !h.workout.startedAt.isBefore(weekStart))
        .length;
    final active = workouts.active;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(
                title: profile.name.isEmpty
                    ? l.greetingNoName
                    : l.greeting(profile.name),
                large: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                // ── Training ───────────────────────────────────────────
                AppCard(
                  padding: 18,
                  tint: brand.withAlpha(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OverlineLabel(l.navTrain),
                      const SizedBox(height: 8),
                      Text(
                        active != null
                            ? l.workoutInProgress(
                                l.minutesShort(active.duration.inMinutes))
                            : l.thisWeekWorkouts(doneThisWeek, profile.daysPerWeek),
                        style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w600, color: fg1),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: active != null ? l.resumeWorkout : l.startWorkout,
                        icon: Icons.fitness_center_rounded,
                        fullWidth: true,
                        onPressed: () async {
                          if (active == null) {
                            await context
                                .read<WorkoutProvider>()
                                .start(name: l.workoutDefaultName);
                          }
                          onOpenWorkout();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const _StepsCard(),
                _MovementCard(onOpen: onOpenTimeline),
                // ── Fuel ───────────────────────────────────────────────
                CaloriesCard(
                    eaten: fuel.kcal, target: targets.calories, onTap: onOpenFuel),
                const SizedBox(height: 14),
                WaterCard(drunk: fuel.waterMl, goal: targets.waterMl),
                const SizedBox(height: 14),
                // ── Body ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: 16,
                        onTap: onOpenBody,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OverlineLabel(l.latestWeight),
                            const SizedBox(height: 8),
                            Text(
                              latestWeight == null
                                  ? '—'
                                  : Units.weight(
                                      latestWeight.weightKg, profile.weightUnit),
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: fg1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        padding: 16,
                        onTap: onCalculateBmi,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OverlineLabel(l.calculateBmiShort),
                            const SizedBox(height: 8),
                            if (lastBmi == null)
                              Icon(Icons.calculate_rounded, color: brand, size: 28)
                            else
                              Row(children: [
                                Text(lastBmi.bmi.toStringAsFixed(1),
                                    style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: fg1)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: StatusPill(
                                      category:
                                          BmiCalculator.category(lastBmi.bmi)),
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // ── Tip ────────────────────────────────────────────────
                AppCard(
                  padding: 18,
                  onTap: onOpenTips,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(tip.icon, color: tip.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OverlineLabel(l.tipOfTheDay),
                            const SizedBox(height: 6),
                            Text(tip.title,
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: fg1)),
                            const SizedBox(height: 4),
                            Text(tip.body,
                                style: GoogleFonts.inter(
                                    fontSize: 14, height: 1.45, color: fg2)),
                            const SizedBox(height: 8),
                            Text(l.moreTips,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, color: brand)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(l.wellnessDisclaimer,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12, color: fg3)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = context.watch<StepsProvider>();
    if (steps.status == StepsStatus.unsupported) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    const color = AppColors.bmiOver;

    final Widget body = switch (steps.status) {
      StepsStatus.connected => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.stepsOf(steps.today, steps.goal),
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w700, color: fg1)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (steps.today / steps.goal).clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
                backgroundColor: sunken,
              ),
            ),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              steps.status == StepsStatus.needsInstall
                  ? l.stepsNeedsInstall
                  : (Platform.isIOS ? l.stepsConnectBodyIos : l.stepsConnectBody),
              style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.45),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: steps.status == StepsStatus.needsInstall
                  ? l.installHealthConnect
                  : l.connectSteps,
              icon: Icons.directions_walk_rounded,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: steps.connect,
            ),
          ],
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.directions_walk_rounded, color: color, size: 20),
              const SizedBox(width: 6),
              OverlineLabel(l.stepsTitle),
            ]),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _MovementCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = context.watch<MovementProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    const color = AppColors.bmiUnder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: 18,
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.route_rounded, color: color, size: 20),
              const SizedBox(width: 6),
              OverlineLabel(l.movementCardTitle),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: fg3),
            ]),
            const SizedBox(height: 8),
            if (!m.enabled) ...[
              Text(l.trackingOff,
                  style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.45)),
              const SizedBox(height: 10),
              AppButton(
                label: l.startTracking,
                icon: Icons.my_location_rounded,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => startTracking(context),
              ),
            ] else ...[
              Text(
                '${l.placesVisited(m.visits.length)} · '
                '${l.distanceKm((m.distanceM / 1000).toStringAsFixed(1))}',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w600, color: fg1),
              ),
              if (m.gymTimeThisWeek > Duration.zero)
                Text(l.gymTimeWeek(formatDuration(l, m.gymTimeThisWeek)),
                    style: GoogleFonts.inter(fontSize: 13, color: fg3)),
            ],
          ],
        ),
      ),
    );
  }
}

