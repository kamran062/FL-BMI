import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/movement/ui/timeline_screen.dart' show formatDuration;
import 'package:bmi_health/features/recovery/domain/recovery.dart';
import 'package:bmi_health/features/recovery/recovery_provider.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

/// Today's recovery score, soreness check-in and sleep summary.
class RecoveryCard extends StatefulWidget {
  /// Today screen: sleep details stay folded until asked for.
  final bool compact;
  const RecoveryCard({super.key, this.compact = false});

  @override
  State<RecoveryCard> createState() => _RecoveryCardState();
}

class _RecoveryCardState extends State<RecoveryCard> {
  bool _showSleep = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = context.watch<RecoveryProvider>();
    final workouts = context.watch<WorkoutProvider>();
    final score = r.score(workouts.setsSince);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;

    final color = switch (score?.advice) {
      TrainingAdvice.trainHard => AppColors.bmiNormal,
      TrainingAdvice.trainLight => AppColors.bmiOver,
      TrainingAdvice.rest => AppColors.bmiObese,
      null => fg3,
    };
    final text = TextStyle(fontSize: 13, color: fg3, height: 1.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.battery_charging_full_rounded, color: color, size: 20),
              const SizedBox(width: 6),
              OverlineLabel(l.recoveryTitle),
            ]),
            const SizedBox(height: 8),
            if (score == null)
              Text(l.recoveryEmpty, style: text)
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.recoveryScore(score.score),
                      style: GoogleFonts.inter(
                          fontSize: 26, fontWeight: FontWeight.w700, color: fg1)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                    value: score.score / 100,
                    minHeight: 8,
                    color: color,
                    backgroundColor: sunken),
              ),
              const SizedBox(height: 8),
              Text(
                switch (score.advice) {
                  TrainingAdvice.trainHard => l.adviceTrainHard,
                  TrainingAdvice.trainLight => l.adviceTrainLight,
                  TrainingAdvice.rest => l.adviceRest,
                },
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: fg1),
              ),
              if (score.limiter case final f?)
                Text(
                  switch (f) {
                    RecoveryFactor.sleep => l.limiterSleep,
                    RecoveryFactor.restingHr => l.limiterRestingHr,
                    RecoveryFactor.hrv => l.limiterHrv,
                    RecoveryFactor.load => l.limiterLoad,
                    RecoveryFactor.soreness => l.limiterSoreness,
                  },
                  style: text,
                ),
            ],
            const SizedBox(height: 12),
            Text(l.sorenessQuestion,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(l.sorenessScale, style: text),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var v = 1; v <= 5; v++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Center(child: Text('$v')),
                        selected: r.soreness == v,
                        showCheckmark: false,
                        onSelected: (_) => r.setSoreness(v),
                      ),
                    ),
                  ),
              ],
            ),
            if (r.available && !r.connected) ...[
              const SizedBox(height: 12),
              Text(l.connectSleepHeartBody, style: text),
              const SizedBox(height: 8),
              AppButton(
                label: l.connectSleepHeart,
                icon: Icons.favorite_border_rounded,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: r.connect,
              ),
            ],
            if (r.connected && (!widget.compact || _showSleep)) ..._sleep(context, r, text),
            if (r.connected && widget.compact)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => setState(() => _showSleep = !_showSleep),
                  icon: Icon(_showSleep ? Icons.expand_less_rounded : Icons.bedtime_outlined, size: 18),
                  label: Text(_showSleep ? l.recoveryHideSleep : l.recoveryShowSleep),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sleep(BuildContext context, RecoveryProvider r, TextStyle text) {
    final l = context.l10n;
    final last = r.lastNight;
    final week = r.week;
    if (last == null && week == null) return const [];
    return [
      const SizedBox(height: 14),
      OverlineLabel(l.sleepTitle),
      const SizedBox(height: 4),
      if (last != null)
        Text(l.sleepLastNight(formatDuration(l, last.duration)),
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
      if (week != null) ...[
        Text(l.sleepAverage(formatDuration(l, week.average)), style: text),
        if (week.debt > Duration.zero)
          Text(l.sleepDebt(formatDuration(l, week.debt)), style: text),
        if (week.nights >= 3)
          Text(week.regular ? l.sleepRegular : l.sleepIrregular, style: text),
      ],
      const SizedBox(height: 12),
      SleepTrendChart(nights: r.fortnight),
    ];
  }
}

/// One bar per night for the last 14 nights; under 7 h is amber.
class SleepTrendChart extends StatelessWidget {
  final List<({DateTime day, Duration? sleep})> nights;
  const SleepTrendChart({super.key, required this.nights});

  static const _maxHours = 10.0;
  static const _height = 72.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final recorded = nights.where((n) => n.sleep != null).length;
    final small = GoogleFonts.inter(fontSize: 11, color: fg3);

    return Semantics(
      label: l.sleepTrendSemantics(recorded),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sleepTrend,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: _height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final n in nights)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: n.sleep == null
                            ? 4
                            : (_height *
                                    (n.sleep!.inMinutes / 60 / _maxHours).clamp(0.05, 1.0))
                                .toDouble(),
                        decoration: BoxDecoration(
                          color: n.sleep == null
                              ? sunken
                              : n.sleep! >= const Duration(hours: 7)
                                  ? AppColors.bmiNormal
                                  : AppColors.bmiOver,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(children: [
            Text(DateFormat.MMMd(l.localeName).format(nights.first.day), style: small),
            const Spacer(),
            Text(DateFormat.MMMd(l.localeName).format(nights.last.day), style: small),
          ]),
          const SizedBox(height: 2),
          Text(l.sleepTrendHint, style: small),
        ],
      ),
    );
  }
}
