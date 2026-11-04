import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/cycle/domain/cycle.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';

extension CycleLabels on AppLocalizations {
  String phase(CyclePhase p) => switch (p) {
        CyclePhase.menstrual => phaseMenstrual,
        CyclePhase.follicular => phaseFollicular,
        CyclePhase.ovulation => phaseOvulation,
        CyclePhase.luteal => phaseLuteal,
      };

  String phaseTip(CyclePhase p) => switch (p) {
        CyclePhase.menstrual => tipMenstrual,
        CyclePhase.follicular => tipFollicular,
        CyclePhase.ovulation => tipOvulation,
        CyclePhase.luteal => tipLuteal,
      };

  String symptom(Symptom s) => switch (s) {
        Symptom.cramps => symptomCramps,
        Symptom.headache => symptomHeadache,
        Symptom.bloating => symptomBloating,
        Symptom.fatigue => symptomFatigue,
        Symptom.lowMood => symptomLowMood,
        Symptom.acne => symptomAcne,
        Symptom.cravings => symptomCravings,
        Symptom.tenderBreasts => symptomTenderBreasts,
      };

  /// "Next period in about 9 days" / "about today".
  String nextPeriod(CycleStatus s, DateTime today) {
    final days = s.daysUntilNext(today);
    return days <= 0 ? nextPeriodToday : nextPeriodIn(days);
  }
}

/// Shows [child] only when cycle data is unlocked.
class CycleLockGate extends StatelessWidget {
  final Widget child;
  const CycleLockGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CycleProvider>();
    if (c.unlocked) return child;
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 40),
            const SizedBox(height: 10),
            Text(l.cycleLocked),
            const SizedBox(height: 12),
            AppButton(
              label: l.cycleUnlock,
              icon: Icons.fingerprint_rounded,
              onPressed: () => c.unlock(l.cycleUnlockReason),
            ),
          ],
        ),
      ),
    );
  }
}

class CycleScreen extends StatelessWidget {
  final VoidCallback onBack;
  const CycleScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: onBack), title: Text(l.cycleTitle)),
      body: const CycleLockGate(child: _CycleBody()),
    );
  }
}

class _CycleBody extends StatelessWidget {
  const _CycleBody();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.watch<CycleProvider>();
    final s = c.status;
    final now = DateTime.now();
    final fmt = DateFormat.MMMd(l.localeName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final small = TextStyle(fontSize: 13, color: fg3, height: 1.4);

    Future<void> pickPast() async {
      final d = await showDatePicker(
        context: context,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now,
        initialDate: now.subtract(const Duration(days: 28)),
      );
      if (d != null) await c.startPeriod(d);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        AppCard(
          padding: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s == null)
                Text(l.cycleNoData, style: GoogleFonts.inter(fontSize: 15))
              else ...[
                Text('${l.cycleDay(s.day)} · ${l.phase(s.phase)}',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l.nextPeriod(s, now),
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(l.nextPeriodWindow(fmt.format(s.nextEarliest), fmt.format(s.nextLatest)),
                    style: small),
                if (s.irregular) Text(l.cycleIrregular, style: small),
                if (s.late) ...[
                  const SizedBox(height: 6),
                  Text(l.periodLate,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.bmiOver)),
                ],
              ],
              const SizedBox(height: 14),
              AppButton(
                label: c.ongoing == null ? l.periodStartedToday : l.periodEndedToday,
                icon: Icons.water_drop_outlined,
                fullWidth: true,
                onPressed: () =>
                    c.ongoing == null ? c.startPeriod(now) : c.endPeriod(now),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: l.periodStartedOn,
                icon: Icons.calendar_month_rounded,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: pickPast,
              ),
            ],
          ),
        ),
        if (s != null) ...[
          const SizedBox(height: 12),
          AppCard(
            padding: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.phase(s.phase)),
                const SizedBox(height: 6),
                Text(l.phaseTip(s.phase), style: GoogleFonts.inter(fontSize: 15, height: 1.45)),
                const SizedBox(height: 6),
                Text(l.cycleTipNote, style: small),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          padding: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverlineLabel(l.symptomsToday),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final sym in Symptom.values)
                    FilterChip(
                      label: Text(l.symptom(sym)),
                      selected: c.symptomsOn(now).contains(sym),
                      onSelected: (_) => c.toggleSymptom(now, sym),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (c.periods.isNotEmpty) ...[
          const SizedBox(height: 12),
          OverlineLabel(l.pastPeriods),
          for (final p in c.periods.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.water_drop_rounded, color: AppColors.bmiObese),
              title: Text(p.end == null
                  ? l.periodOngoing(fmt.format(p.start))
                  : l.periodRange(fmt.format(p.start), fmt.format(p.end!))),
              trailing: IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => c.deletePeriod(p.id!),
              ),
            ),
        ],
      ],
    );
  }
}
