import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/train/exercises/ui/exercise_media.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/app/router.dart';
import 'package:bmi_health/features/train/workouts/domain/workout.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:go_router/go_router.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onClose;

  const ExerciseDetailScreen(
      {super.key, required this.exercise, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = l.localeName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final demonstrator = context.watch<ProfileProvider>().profile.demonstrator;
    final steps = exercise.stepsIn(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.nameIn(locale)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded), onPressed: onClose),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _ExerciseVideo(exercise: exercise, demonstrator: demonstrator),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(l.exerciseEquipment(exercise.equipment))),
              Chip(label: Text(l.difficulty(exercise.difficulty))),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.targetMuscles),
                const SizedBox(height: 8),
                Text(l.muscle(exercise.primary),
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700, color: brand)),
                if (exercise.secondary.isNotEmpty)
                  Text(exercise.secondary.map(l.muscle).join(' · '),
                      style: GoogleFonts.inter(fontSize: 14, color: fg2)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.howTo),
                const SizedBox(height: 8),
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: brand.withAlpha(30),
                          child: Text('${i + 1}',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: brand)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(steps[i],
                              style: GoogleFonts.inter(
                                  fontSize: 15, height: 1.45, color: fg1)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ProgressCard(exercise: exercise),
          const SizedBox(height: 12),
          _RecommendedCard(exercise: exercise),
          if (exercise.tipsIn(locale).isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulletCard(
              title: l.tipsTitle,
              items: exercise.tipsIn(locale),
              icon: Icons.lightbulb_outline_rounded,
              color: brand,
            ),
          ],
          if (exercise.mistakesIn(locale).isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulletCard(
              title: l.mistakesTitle,
              items: exercise.mistakesIn(locale),
              icon: Icons.close_rounded,
              color: AppColors.bmiObese,
            ),
          ],
          const SizedBox(height: 12),
          _AlternativesCard(exercise: exercise),
          const SizedBox(height: 16),
          Text(l.wellnessDisclaimer,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: fg2)),
        ],
      ),
    );
  }
}

String _clock(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Best set (estimated 1RM) or volume per session, from workout history.
/// Bodyweight-only moves chart reps instead.
class _ProgressCard extends StatefulWidget {
  final Exercise exercise;
  const _ProgressCard({required this.exercise});

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> {
  bool _volume = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final unit = context.watch<ProfileProvider>().profile.weightUnit;
    final sessions = ExerciseSession.fromHistory(
        context.watch<WorkoutProvider>().history, widget.exercise.id);

    if (sessions.isEmpty) {
      return AppCard(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OverlineLabel(l.trainProgressTitle),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.show_chart_rounded, color: fg3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.trainProgressEmpty,
                    style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.4)),
              ),
            ]),
          ],
        ),
      );
    }

    final weighted = sessions.any((s) => s.best1RM > 0);
    final values = [
      for (final s in sessions)
        weighted
            ? Units.kgTo(unit, _volume ? s.volumeKg : s.best1RM)
            : (_volume ? s.totalReps : s.maxReps).toDouble()
    ];
    final best = sessions.reduce((a, b) =>
        (weighted ? a.best1RM >= b.best1RM : a.maxReps >= b.maxReps) ? a : b);
    final bestText = weighted
        ? '${_trim(Units.kgTo(unit, best.topWeightKg))} $unit × ${best.topReps}'
        : l.trainRepsCount(best.maxReps);

    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: OverlineLabel(l.trainProgressTitle)),
            Text(l.trainSessions(sessions.length),
                style: GoogleFonts.inter(fontSize: 12, color: fg3)),
          ]),
          const SizedBox(height: 8),
          Text(l.trainBestEver(bestText),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          if (weighted)
            Text(l.trainEst1rm(Units.weight(best.best1RM, unit)),
                style: GoogleFonts.inter(fontSize: 13, color: fg2)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            ChoiceChip(
              label: Text(weighted ? l.trainBestSet : l.trainMostReps),
              selected: !_volume,
              onSelected: (_) => setState(() => _volume = false),
            ),
            ChoiceChip(
              label: Text(weighted ? l.trainVolume : l.trainTotalReps),
              selected: _volume,
              onSelected: (_) => setState(() => _volume = true),
            ),
          ]),
          const SizedBox(height: 12),
          _SessionChart(values: values, color: brand),
        ],
      ),
    );
  }
}

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

class _SessionChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  const _SessionChart({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    // Last 30 sessions keeps the chart readable.
    final v = values.length > 30 ? values.sublist(values.length - 30) : values;
    final lo = v.reduce((a, b) => a < b ? a : b);
    final hi = v.reduce((a, b) => a > b ? a : b);
    final pad = ((hi - lo) * 0.2).clamp(1.0, 50.0);
    // Time runs left→right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 120,
        child: LineChart(
          LineChartData(
            minY: (lo - pad).clamp(0.0, double.infinity),
            maxY: hi + pad,
            minX: 0,
            maxX: v.length == 1 ? 1 : (v.length - 1).toDouble(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: [for (var i = 0; i < v.length; i++) FlSpot(i.toDouble(), v[i])],
                isCurved: true,
                curveSmoothness: 0.2,
                preventCurveOverShooting: true,
                color: color,
                barWidth: 2.5,
                dotData: FlDotData(
                  getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
                ),
                belowBarData: BarAreaData(show: true, color: color.withAlpha(30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Exercise exercise;
  const _RecommendedCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = exercise.prescription;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.recommended),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.repeat_rounded, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p.timed
                    ? l.setsSeconds(p.sets, p.repMin, p.repMax)
                    : l.setsReps(p.sets, p.repMin, p.repMax),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.timer_outlined, size: 20, color: fg2),
            const SizedBox(width: 8),
            Text(l.restBetween(_clock(p.restSec)),
                style: GoogleFonts.inter(fontSize: 14, color: fg2)),
          ]),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  const _BulletCard(
      {required this.title, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(title),
          const SizedBox(height: 4),
          for (final t in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t,
                        style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: fg1)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Same-muscle swaps ("machine busy?"), filtered to the user's equipment.
class _AlternativesCard extends StatelessWidget {
  final Exercise exercise;
  const _AlternativesCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final equipment =
        equipmentFor(context.watch<ProfileProvider>().profile.equipment);
    final alts = context.read<ExerciseCatalog>().alternativesFor(exercise, available: equipment);
    if (alts.isEmpty) return const SizedBox.shrink();
    return AppCard(
      padding: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
            child: OverlineLabel(l.alternativesTitle),
          ),
          for (final a in alts)
            ListTile(
              title: Text(a.nameIn(l.localeName)),
              subtitle: Text('${l.exerciseEquipment(a.equipment)} · ${l.difficulty(a.difficulty)}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.exercise(a.id)),
            ),
        ],
      ),
    );
  }
}

/// The clip or animated guide in a rounded 16:10 frame.
class _ExerciseVideo extends StatelessWidget {
  final Exercise exercise;
  final Sex demonstrator;

  const _ExerciseVideo({required this.exercise, required this.demonstrator});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          color: isDark ? AppColors.darkBgSunken : AppColors.bgSunken,
          child: ExerciseMedia(exercise: exercise, demonstrator: demonstrator),
        ),
      ),
    );
  }
}
