import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/features/movement/ui/timeline_screen.dart' show formatDuration;
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/progress/domain/achievements.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

extension AchievementLabels on AppLocalizations {
  String badge(Achievement b) => switch (b) {
        Achievement.firstWorkout => badgeFirstWorkout,
        Achievement.workouts10 => badgeWorkouts10,
        Achievement.workouts50 => badgeWorkouts50,
        Achievement.workouts100 => badgeWorkouts100,
        Achievement.streak4 => badgeStreak4,
        Achievement.streak12 => badgeStreak12,
        Achievement.firstPr => badgeFirstPr,
        Achievement.prs10 => badgePrs10,
        Achievement.ton => badgeTon,
        Achievement.steps10k => badgeSteps10k,
      };
}

/// Streak, badges and the monthly recap (ROADMAP 5.1, 5.2).
class ProgressScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProgressScreen({super.key, required this.onBack});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _shot = ScreenshotController();
  bool _lastMonth = false;
  ({double km, Duration gym})? _movement;

  (DateTime, DateTime) get _range {
    final n = DateTime.now();
    final start = _lastMonth ? DateTime(n.year, n.month - 1) : DateTime(n.year, n.month);
    return (start, DateTime(start.year, start.month + 1));
  }

  @override
  void initState() {
    super.initState();
    _loadMovement();
  }

  Future<void> _loadMovement() async {
    final m = context.read<MovementProvider>();
    if (!m.enabled) return;
    final (from, to) = _range;
    final t = await m.totalsBetween(from, to);
    if (mounted) setState(() => _movement = t);
  }

  Future<void> _share() async {
    final l = context.l10n;
    try {
      final bytes = await _shot.capture(pixelRatio: 3);
      if (bytes == null) return;
      final file = File('${(await getTemporaryDirectory()).path}/recap.png');
      await file.writeAsBytes(bytes);
      AdService.instance.beginExternalUi();
      try {
        await Share.shareXFiles([XFile(file.path)]);
      } finally {
        AdService.instance.endExternalUi();
      }
    } catch (e, st) {
      reportError(e, st, reason: 'share-recap');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.shareError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final history = context.watch<WorkoutProvider>().history;
    final goal = context.watch<ProfileProvider>().profile.daysPerWeek;
    final days = [for (final h in history) h.workout.startedAt];
    final now = DateTime.now();
    final streak = Streaks.weeks(days, goal, now);

    // Best streak ever: check every week end in history.
    var best = streak;
    for (final d in days) {
      final s = Streaks.weeks(days, goal, weekStart(d).add(const Duration(days: 6)));
      if (s > best) best = s;
    }
    final badges = Achievements.evaluate(
      workouts: history.length,
      bestWeekStreak: best,
      prs: history.fold(0, (s, h) => s + h.prCount),
      totalVolumeKg: history.fold(0.0, (s, h) => s + h.volumeKg),
      bestStepsDay: context.watch<StepsProvider>().bestDay,
    );

    final (from, to) = _range;
    final recap = Recap.of(history, from, to,
        distanceKm: _movement?.km,
        gymTime: _movement?.gym,
        weights: [
          for (final w in context.watch<BodyProvider>().weights) (date: w.date, kg: w.weightKg)
        ]);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: widget.onBack), title: Text(l.progressTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AppCard(
            padding: 18,
            child: Row(children: [
              Icon(Icons.local_fire_department_rounded, color: AppColors.bmiOver, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.weekStreak(streak),
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(l.streakGoal(goal), style: GoogleFonts.inter(fontSize: 13, color: fg3)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            ChoiceChip(
              label: Text(l.thisMonth),
              selected: !_lastMonth,
              onSelected: (_) => setState(() {
                _lastMonth = false;
                _movement = null;
                _loadMovement();
              }),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l.lastMonth),
              selected: _lastMonth,
              onSelected: (_) => setState(() {
                _lastMonth = true;
                _movement = null;
                _loadMovement();
              }),
            ),
            const Spacer(),
            if (!recap.isEmpty)
              TextButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l.shareRecap),
              ),
          ]),
          const SizedBox(height: 8),
          // The shared image: totals only, never places or routes.
          Screenshot(
            controller: _shot,
            child: _RecapCard(recap: recap, brand: brand),
          ),
          const SizedBox(height: 18),
          Row(children: [
            OverlineLabel(l.badgesTitle),
            const Spacer(),
            Text(l.badgesEarned(badges.where((b) => b.earned).length, badges.length),
                style: GoogleFonts.inter(fontSize: 13, color: fg3)),
          ]),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: [
              for (final b in badges)
                AppCard(
                  padding: 10,
                  child: Row(children: [
                    Icon(b.earned ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                        color: b.earned ? AppColors.bmiOver : fg3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.badge(b.badge),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: b.earned ? null : fg3)),
                          if (!b.earned) ...[
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: b.progress, minHeight: 3),
                          ],
                        ],
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  final Recap recap;
  final Color brand;
  const _RecapCard({required this.recap, required this.brand});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = recap;
    final kg = NumberFormat.decimalPattern(l.localeName).format(r.volumeKg.round());
    final lines = <(IconData, String)>[
      if (r.workouts > 0) (Icons.fitness_center_rounded, l.recapWorkouts(r.workouts)),
      if (r.sets > 0) (Icons.stacked_bar_chart_rounded, l.recapSets(r.sets, kg)),
      if (r.prs > 0) (Icons.emoji_events_rounded, l.recapPrs(r.prs)),
      if (r.trainingTime > Duration.zero) (Icons.timer_outlined, l.recapTime(formatDuration(l, r.trainingTime))),
      if ((r.distanceKm ?? 0) >= 0.1)
        (Icons.directions_walk_rounded, l.recapDistance(r.distanceKm!.toStringAsFixed(1))),
      if ((r.gymTime ?? Duration.zero) > Duration.zero)
        (Icons.place_rounded, l.recapGym(formatDuration(l, r.gymTime!))),
      if (r.weightChangeKg != null)
        (Icons.monitor_weight_outlined,
            l.recapWeight('${r.weightChangeKg! > 0 ? '+' : ''}${r.weightChangeKg!.toStringAsFixed(1)}')),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [brand, brand.withAlpha(200)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat.yMMMM(l.localeName).format(r.from),
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 10),
          if (lines.isEmpty)
            Text(l.recapEmpty, style: const TextStyle(color: Colors.white))
          else
            for (final (icon, text) in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(text,
                        style: GoogleFonts.inter(fontSize: 15, color: Colors.white)),
                  ),
                ]),
              ),
          const SizedBox(height: 10),
          Text(l.appName,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}
