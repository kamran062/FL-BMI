import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/core/review/review_prompter.dart';
import 'package:bmi_health/features/body/bmi/ui/tips_screen.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/today/domain/daily_goals.dart';
import 'package:bmi_health/features/today/ui/today_widgets.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/features/movement/ui/step_goal_dialog.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/movement/ui/timeline_screen.dart';
import 'package:bmi_health/features/recovery/ui/recovery_card.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/cycle/ui/cycle_screen.dart';

/// Home: today's goals, one plan with one button, quick logging, and a
/// daily streak that rewards coming back.
class TodayScreen extends StatefulWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenFuel;
  final VoidCallback onOpenBody;
  final VoidCallback onCalculateBmi;
  final VoidCallback onOpenTips;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenCycle;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenTrain;

  const TodayScreen({
    super.key,
    required this.onOpenWorkout,
    required this.onOpenFuel,
    required this.onOpenBody,
    required this.onCalculateBmi,
    required this.onOpenTips,
    required this.onOpenTimeline,
    required this.onOpenCycle,
    required this.onOpenProgress,
    required this.onOpenTrain,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  /// A perfect day was already counted as a happy moment this session.
  bool _perfectNoted = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    final profile = context.watch<ProfileProvider>().profile;
    final workouts = context.watch<WorkoutProvider>();
    final fuel = context.watch<FuelProvider>();
    final steps = context.watch<StepsProvider>();
    final challenges = context.watch<ChallengeProvider>();
    final weighIns = context.watch<BodyProvider>().weights;
    final targets = Nutrition.targetsFor(profile);
    final tip = TipsScreen.tipOfTheDay(l, DateTime.now());
    final now = DateTime.now();

    final trainedToday = challenges.doneToday ||
        workouts.history.any((h) =>
            h.workout.startedAt.year == now.year &&
            h.workout.startedAt.month == now.month &&
            h.workout.startedAt.day == now.day);
    final stepsOn = steps.status == StepsStatus.connected;
    final goals = DailyGoals.from(
      steps: stepsOn ? steps.today : null,
      stepGoal: steps.goal,
      trained: trainedToday,
      kcal: fuel.kcal,
      kcalTarget: targets.calories,
      waterMl: fuel.waterMl,
      waterGoal: targets.waterMl,
    );
    if (goals.perfect && !_perfectNoted) {
      _perfectNoted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => ReviewPrompter.perfectDay());
    }
    // Days with anything logged: workouts, challenge days, weigh-ins, and
    // food or water (the Food tab keeps the last week in memory)
    final streak = DailyStreak.count(
      DailyStreak.days([
        for (final h in workouts.history) h.workout.startedAt,
        ...challenges.completionDates,
        for (final w in weighIns) w.date,
        if (fuel.viewingToday)
          for (final d in fuel.week)
            if (d.kcal > 0) d.day,
        if (fuel.kcal > 0 || fuel.waterMl > 0) now,
      ]),
      now,
    );

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(
                title: profile.name.isEmpty ? l.greetingNoName : l.greeting(profile.name),
                large: true,
                trailing: StreakChip(days: streak),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                GoalsCard(
                  goals: goals,
                  moveValue: stepsOn ? _compact(steps.today) : l.goalConnect,
                  trainValue: trainedToday ? l.goalDone : '0/1',
                  eatValue: '${fuel.kcal}',
                  waterValue: '${(fuel.waterMl / 1000).toStringAsFixed(1)} L',
                  onMove: stepsOn ? () => showStepGoalDialog(context) : steps.connect,
                  onTrain: widget.onOpenTrain,
                  onEat: widget.onOpenFuel,
                  onWater: () => _addWater(context),
                ),
                const SizedBox(height: 14),
                TodayPlanCard(onOpenWorkout: widget.onOpenWorkout),
                const SizedBox(height: 18),
                QuickAddRow(
                  onWater: () => _addWater(context),
                  onFood: widget.onOpenFuel,
                  onWeight: widget.onOpenBody,
                ),
                const SizedBox(height: 18),
                const RecoveryCard(compact: true),
                if (context.watch<MovementProvider>().enabled) _MovementCard(onOpen: widget.onOpenTimeline),
                _CycleCard(onOpen: widget.onOpenCycle),
                OverlineLabel(l.todayMore),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ActionChip(
                    avatar: const Icon(Icons.calculate_rounded, size: 18),
                    label: Text(l.calculateBmiShort),
                    onPressed: widget.onCalculateBmi,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.route_rounded, size: 18),
                    label: Text(l.movementTitle),
                    onPressed: widget.onOpenTimeline,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: Text(l.tipsTitle),
                    onPressed: widget.onOpenTips,
                  ),
                ]),
                const SizedBox(height: 18),
                AppCard(
                  padding: 18,
                  onTap: widget.onOpenTips,
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
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(tip.body, style: GoogleFonts.inter(fontSize: 14, height: 1.45)),
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

  static String _compact(int n) => n >= 10000
      ? '${(n / 1000).toStringAsFixed(0)}k'
      : n >= 1000
          ? '${(n / 1000).toStringAsFixed(1)}k'
          : '$n';

  Future<void> _addWater(BuildContext context) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<FuelProvider>().addWater(250);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.quickWaterDone), duration: const Duration(seconds: 2)));
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

/// Shown only when the user opted in to cycle tracking (and their profile
/// offers it). Hides details while the cycle lock is on.
class _CycleCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _CycleCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CycleProvider>();
    final offered = context.watch<ProfileProvider>().profile.cycleTrackingOffered;
    if (!c.enabled || !offered) return const SizedBox.shrink();
    final l = context.l10n;
    final s = c.unlocked ? c.status : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: 18,
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.water_drop_outlined, color: AppColors.bmiObese, size: 20),
              const SizedBox(width: 6),
              OverlineLabel(l.cycleTitle),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: fg3),
            ]),
            const SizedBox(height: 6),
            if (!c.unlocked)
              Text(l.cycleLocked, style: GoogleFonts.inter(fontSize: 14, color: fg3))
            else if (s == null)
              Text(l.cycleNoData, style: GoogleFonts.inter(fontSize: 14, color: fg3))
            else ...[
              Text('${l.cycleDay(s.day)} · ${l.phase(s.phase)}',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600)),
              Text(l.nextPeriod(s, DateTime.now()),
                  style: GoogleFonts.inter(fontSize: 13, color: fg3)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Week streak; opens Progress (recap and badges).
