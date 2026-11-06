import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/challenges/challenge_provider.dart';
import 'package:bmi_health/features/train/challenges/domain/challenge.dart';
import 'package:bmi_health/features/train/challenges/ui/guided_player_screen.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

extension ChallengeLabels on AppLocalizations {
  String level(ChallengeLevel l) => switch (l) {
        ChallengeLevel.beginner => levelBeginner,
        ChallengeLevel.intermediate => levelIntermediate,
        ChallengeLevel.advanced => levelAdvanced,
      };

  String focus(ChallengeFocus f) => switch (f) {
        ChallengeFocus.fullBody => focusFullBody,
        ChallengeFocus.upperBody => focusUpperBody,
        ChallengeFocus.coreAbs => focusCoreAbs,
        ChallengeFocus.legsGlutes => focusLegsGlutes,
        ChallengeFocus.hiit => focusHiit,
        ChallengeFocus.stretch => focusStretch,
      };
}

IconData focusIcon(ChallengeFocus f) => switch (f) {
      ChallengeFocus.fullBody => Icons.accessibility_new_rounded,
      ChallengeFocus.upperBody => Icons.fitness_center_rounded,
      ChallengeFocus.coreAbs => Icons.grid_view_rounded,
      ChallengeFocus.legsGlutes => Icons.directions_run_rounded,
      ChallengeFocus.hiit => Icons.local_fire_department_rounded,
      ChallengeFocus.stretch => Icons.self_improvement_rounded,
    };

/// BMI from the latest logged weight, else the profile weight.
double? currentBmi(BuildContext context) {
  final profile = context.read<ProfileProvider>().profile;
  final w = context.read<BodyProvider>().latestWeight?.weightKg ??
      (profile.weightInKg > 0 ? profile.weightInKg : null);
  final h = profile.heightInCm;
  return w != null && h > 0 ? BmiCalculator.calculate(w, h) : null;
}

/// Level tabs and focus cards.
class ChallengesScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ChallengesScreen({super.key, required this.onBack});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  ChallengeLevel _level = ChallengeLevel.beginner;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<ChallengeProvider>();
    final catalog = context.read<ExerciseCatalog>();
    final order = ChallengePlanner.orderedFor(context.watch<ProfileProvider>().profile);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: widget.onBack), title: Text(l.homeChallenges)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(l.homeChallengesBody, style: GoogleFonts.inter(fontSize: 14, color: fg3)),
          const SizedBox(height: 12),
          SegmentedButton<ChallengeLevel>(
            segments: [
              for (final lv in ChallengeLevel.values)
                ButtonSegment(value: lv, label: Text(l.level(lv), overflow: TextOverflow.ellipsis)),
            ],
            selected: {_level},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _level = s.first),
          ),
          const SizedBox(height: 14),
          if (c.streak > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.bmiOver),
                const SizedBox(width: 6),
                Text(l.challengeStreak(c.streak),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ]),
            ),
          for (final (i, f) in order.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FocusCard(
                focus: f,
                level: _level,
                recommended: i == 0,
                minutes: ChallengePlanner.dayPlan(f, _level, 1, catalog).estimatedTime.inMinutes,
                brand: brand,
              ),
            ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final ChallengeFocus focus;
  final ChallengeLevel level;
  final bool recommended;
  final int minutes;
  final Color brand;
  const _FocusCard({
    required this.focus,
    required this.level,
    required this.recommended,
    required this.minutes,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<ChallengeProvider>();
    final unlocked = c.isUnlocked(focus, level);
    final done = c.completedDays(focus, level).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: AppCard(
        padding: 16,
        tint: recommended && unlocked ? brand.withAlpha(24) : null,
        onTap: unlocked
            ? () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                builder: (_) => ChallengeDetailScreen(focus: focus, level: level)))
            : null,
        child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: brand.withAlpha(30),
            child: Icon(unlocked ? focusIcon(focus) : Icons.lock_rounded, color: brand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (recommended && unlocked)
                Text(l.recommended.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: brand)),
              Text(l.focus(focus),
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                unlocked
                    ? l.challengeLength(level.days, minutes)
                    : l.levelLocked(l.level(level.previous!)),
                style: GoogleFonts.inter(fontSize: 13, color: fg3),
              ),
              if (unlocked && done > 0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: done / level.days, minHeight: 6, color: brand, backgroundColor: sunken),
                ),
                const SizedBox(height: 2),
                Text(
                  c.isComplete(focus, level)
                      ? l.challengeDone
                      : l.challengeProgress(c.currentDay(focus, level), level.days),
                  style: GoogleFonts.inter(fontSize: 12, color: fg3),
                ),
              ],
            ]),
          ),
          if (unlocked) Icon(Icons.chevron_right_rounded, color: fg3),
        ]),
      ),
    );
  }
}

/// Day grid, today's plan and the start button.
class ChallengeDetailScreen extends StatelessWidget {
  final ChallengeFocus focus;
  final ChallengeLevel level;
  const ChallengeDetailScreen({super.key, required this.focus, required this.level});

  Future<void> _start(BuildContext context, ChallengeDay plan) async {
    final l = context.l10n;
    final workouts = context.read<WorkoutProvider>();
    if (workouts.active != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.finishActiveFirst)));
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GuidedPlayerScreen(focus: focus, level: level, plan: plan),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<ChallengeProvider>();
    final catalog = context.read<ExerciseCatalog>();
    final current = c.currentDay(focus, level);
    final done = c.completedDays(focus, level);
    final plan = ChallengePlanner.dayPlan(focus, level, current, catalog, bmi: currentBmi(context));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.focus(focus)} · ${l.level(level)}'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (_) => c.restart(focus, level),
            itemBuilder: (_) => [PopupMenuItem(value: 0, child: Text(l.restartChallenge))],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(
            c.isComplete(focus, level) ? l.challengeDone : l.challengeProgress(current, level.days),
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          // Day grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var d = 1; d <= level.days; d++)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done.contains(d) ? brand : sunken,
                    border: d == current && !done.contains(d)
                        ? Border.all(color: brand, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: done.contains(d)
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : focus.hasRestDays && d % 7 == 0
                          ? Icon(Icons.bedtime_outlined, size: 14, color: fg3)
                          : Text('$d',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: d == current ? FontWeight.w700 : FontWeight.w400)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (!c.isComplete(focus, level)) ...[
            if (plan.rest)
              AppCard(
                padding: 18,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  OverlineLabel(l.restDay),
                  const SizedBox(height: 6),
                  Text(l.restDayBody, style: GoogleFonts.inter(fontSize: 15, height: 1.45)),
                  const SizedBox(height: 12),
                  AppButton(
                    label: l.markRested,
                    icon: Icons.bedtime_rounded,
                    fullWidth: true,
                    onPressed: () => c.completeRestDay(focus, level, current),
                  ),
                ]),
              )
            else ...[
              Row(children: [
                OverlineLabel(l.todayPlan),
                const Spacer(),
                Text('~${plan.estimatedTime.inMinutes} min',
                    style: GoogleFonts.inter(fontSize: 13, color: fg3)),
              ]),
              const SizedBox(height: 6),
              for (final s in plan.steps)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: brand.withAlpha(24),
                    child: Icon(
                      s.isWarmup
                          ? Icons.whatshot_outlined
                          : s.isCooldown
                              ? Icons.self_improvement_rounded
                              : Icons.fitness_center_rounded,
                      color: brand,
                      size: 20,
                    ),
                  ),
                  title: Text(s.exercise.nameIn(l.localeName)),
                  subtitle: Text([
                    if (s.isWarmup) l.warmUp,
                    if (s.isCooldown) l.coolDown,
                    '${s.sets} × ${s.timed ? l.secondsTarget(s.target) : l.repsTarget(s.target)}',
                  ].join(' · ')),
                ),
              const SizedBox(height: 12),
              AppButton(
                label: l.startDay(current),
                icon: Icons.play_arrow_rounded,
                fullWidth: true,
                onPressed: plan.steps.isEmpty ? null : () => _start(context, plan),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
