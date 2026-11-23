import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/today/domain/daily_goals.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/challenges/ui/challenges_screen.dart';
import 'package:bmi_health/features/train/challenges/ui/guided_player_screen.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/programs/muscle_day.dart';
import 'package:bmi_health/features/train/programs/progression.dart';
import 'package:bmi_health/features/train/ui/train_screen.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

const _moveColor = Color(0xFF3B82F6);
const _eatColor = AppColors.bmiOver;
const _waterColor = Color(0xFF22B8CF);

/// 🔥 n — days in a row with anything logged. Tap for an explanation.
class StreakChip extends StatelessWidget {
  final int days;
  const StreakChip({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final on = days > 0;
    return Semantics(
      button: true,
      label: l.streakChip(days),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showDialog<void>(
          context: context,
          builder: (d) => AlertDialog(
            icon: const Icon(Icons.local_fire_department_rounded, color: AppColors.bmiOver, size: 36),
            title: Text(l.streakHelpTitle),
            content: Text(l.streakHelpBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d), child: Text(MaterialLocalizations.of(d).okButtonLabel)),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.bmiOver.withAlpha(on ? 40 : 18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.local_fire_department_rounded,
                size: 20, color: on ? AppColors.bmiOver : AppColors.bmiOver.withAlpha(120)),
            const SizedBox(width: 4),
            Text('$days', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

/// Four rings: Move (steps), Train, Eat (calories), Water.
class GoalsCard extends StatelessWidget {
  final DailyGoals goals;
  final String moveValue, trainValue, eatValue, waterValue;
  final VoidCallback onMove, onTrain, onEat, onWater;

  const GoalsCard({
    super.key,
    required this.goals,
    required this.moveValue,
    required this.trainValue,
    required this.eatValue,
    required this.waterValue,
    required this.onMove,
    required this.onTrain,
    required this.onEat,
    required this.onWater,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final total = goals.move == null ? 3 : 4;
    return AppCard(
      padding: 18,
      tint: goals.perfect ? brand.withAlpha(30) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: OverlineLabel(l.todayGoalsTitle)),
            Text(l.todayGoalsProgress(goals.completed, total),
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: fg3)),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GoalRing(label: l.goalMove, value: moveValue, progress: goals.move ?? 0,
                  color: _moveColor, icon: Icons.directions_walk_rounded, onTap: onMove),
              GoalRing(label: l.goalTrain, value: trainValue, progress: goals.train,
                  color: brand, icon: Icons.fitness_center_rounded, onTap: onTrain),
              GoalRing(label: l.goalEat, value: eatValue, progress: goals.eat,
                  color: _eatColor, icon: Icons.restaurant_rounded, onTap: onEat),
              GoalRing(label: l.goalWater, value: waterValue, progress: goals.water,
                  color: _waterColor, icon: Icons.water_drop_rounded, onTap: onWater),
            ],
          ),
          if (goals.perfect) ...[
            const SizedBox(height: 14),
            Row(children: [
              Icon(Icons.celebration_rounded, color: brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.todayPerfectDay,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: brand)),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class GoalRing extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const GoalRing({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final done = progress >= 1;
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(children: [
            SizedBox(
              width: 64,
              height: 64,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, p, _) => CustomPaint(
                  painter: _RingPainter(p, color, color.withAlpha(isDark ? 45 : 35)),
                  child: Center(
                    child: Icon(done ? Icons.check_rounded : icon, color: color, size: done ? 28 : 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(value, style: GoogleFonts.inter(fontSize: 12, color: fg3)),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, track;
  _RingPainter(this.progress, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    const w = 7.0;
    final rect = Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress.clamp(0, 1), false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}

/// One clear thing to do today, with a single button.
class TodayPlanCard extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  const TodayPlanCard({super.key, required this.onOpenWorkout});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final plan = _plan(context);

    return AppCard(
      padding: 18,
      tint: brand.withAlpha(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.planTitle),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: brand.withAlpha(40), borderRadius: BorderRadius.circular(14)),
              child: Icon(plan.icon, color: brand, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plan.title,
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: fg1)),
                const SizedBox(height: 2),
                Text(plan.subtitle, style: GoogleFonts.inter(fontSize: 14, height: 1.35, color: fg2)),
              ]),
            ),
          ]),
          if (plan.action != null) ...[
            const SizedBox(height: 14),
            AppButton(
              label: plan.actionLabel!,
              icon: plan.actionIcon,
              fullWidth: true,
              onPressed: plan.action,
            ),
          ],
        ],
      ),
    );
  }

  _Plan _plan(BuildContext context) {
    final l = context.l10n;
    final workouts = context.watch<WorkoutProvider>();
    final challenges = context.watch<ChallengeProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final catalog = context.read<ExerciseCatalog>();
    final now = DateTime.now();

    // 1. A workout is open: finish it
    final active = workouts.active;
    if (active != null) {
      return _Plan(
        icon: Icons.play_circle_fill_rounded,
        title: l.resumeWorkout,
        subtitle: l.workoutInProgress(l.minutesShort(active.duration.inMinutes)),
        actionLabel: l.resumeWorkout,
        actionIcon: Icons.play_arrow_rounded,
        action: onOpenWorkout,
      );
    }

    final trainedToday = challenges.doneToday ||
        workouts.history.any((h) =>
            h.workout.startedAt.year == now.year &&
            h.workout.startedAt.month == now.month &&
            h.workout.startedAt.day == now.day);
    if (trainedToday) {
      return _Plan(icon: Icons.check_circle_rounded, title: l.planDoneTitle, subtitle: l.planDoneBody);
    }

    // 2. A challenge in progress: today's day
    final latest = challenges.latest;
    if (latest != null) {
      final day = challenges.currentDay(latest.focus, latest.level);
      final dayPlan =
          ChallengePlanner.dayPlan(latest.focus, latest.level, day, catalog, bmi: currentBmi(context));
      final dayLabel = l.challengeProgress(day, latest.level.days);
      if (dayPlan.rest) {
        return _Plan(
          icon: Icons.self_improvement_rounded,
          title: '${l.focus(latest.focus)} · ${l.restDay}',
          subtitle: l.planRestBody,
          actionLabel: l.planRestDone,
          actionIcon: Icons.check_rounded,
          action: () => challenges.completeRestDay(latest.focus, latest.level, day),
        );
      }
      return _Plan(
        icon: focusIcon(latest.focus),
        title: l.focus(latest.focus),
        subtitle: l.planChallengeSub(dayLabel, dayPlan.estimatedTime.inMinutes.clamp(1, 999)),
        actionLabel: l.planStart,
        actionIcon: Icons.play_arrow_rounded,
        action: () => _startChallenge(context, latest.focus, latest.level, dayPlan),
      );
    }

    // 3. Gym users: the muscles they've trained least this week
    if (profile.equipment == Equipment.gym) {
      final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final sets = [
        for (final h in workouts.history)
          if (!h.workout.startedAt.isBefore(weekStart)) ...h.sets
      ];
      final day = MuscleDay.suggested(MuscleVolume.weeklySets(sets, catalog));
      return _Plan(
        icon: Icons.fitness_center_rounded,
        title: l.dayWorkout(muscleDayName(l, day)),
        subtitle: l.planGymSub,
        actionLabel: l.planStart,
        actionIcon: Icons.play_arrow_rounded,
        action: () => showMuscleDay(context, day),
      );
    }

    // 4. Everyone else: the recommended 30-day home plan
    final focus = ChallengePlanner.orderedFor(profile).first;
    const level = ChallengeLevel.beginner;
    final first = ChallengePlanner.dayPlan(focus, level, 1, catalog, bmi: currentBmi(context));
    return _Plan(
      icon: focusIcon(focus),
      title: l.planFirstTitle,
      subtitle: l.planFirstSub(l.focus(focus)),
      actionLabel: l.planStart,
      actionIcon: Icons.play_arrow_rounded,
      action: () => _startChallenge(context, focus, level, first),
    );
  }

  Future<void> _startChallenge(
      BuildContext context, ChallengeFocus focus, ChallengeLevel level, ChallengeDay plan) async {
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (_) => GuidedPlayerScreen(focus: focus, level: level, plan: plan),
    ));
  }
}

class _Plan {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? action;
  const _Plan({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.action,
  });
}

/// Big one-tap buttons: water, food, weight.
class QuickAddRow extends StatelessWidget {
  final VoidCallback onWater, onFood, onWeight;
  const QuickAddRow({super.key, required this.onWater, required this.onFood, required this.onWeight});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget tile(IconData icon, Color color, String label, VoidCallback onTap) => Expanded(
          child: AppCard(
            padding: 14,
            onTap: onTap,
            child: Column(children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      OverlineLabel(l.quickAddTitle),
      const SizedBox(height: 10),
      Row(children: [
        tile(Icons.water_drop_rounded, _waterColor, l.quickWater, onWater),
        const SizedBox(width: 10),
        tile(Icons.restaurant_rounded, _eatColor, l.quickFood, onFood),
        const SizedBox(width: 10),
        tile(Icons.monitor_weight_rounded, _moveColor, l.quickWeight, onWeight),
      ]),
    ]);
  }
}
