import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/body/bmi/ui/widgets/status_pill.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/body/metrics/domain/body_metrics.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/units/units.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';

/// Body tab: weight trend, body-fat estimate, measurements, BMI history.
class BodyScreen extends StatelessWidget {
  final VoidCallback onOpenBmiHistory;
  final VoidCallback onCalculateBmi;

  const BodyScreen(
      {super.key, required this.onOpenBmiHistory, required this.onCalculateBmi});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final profile = context.watch<ProfileProvider>().profile;
    final body = context.watch<BodyProvider>();
    final lastBmi = context.watch<BmiProvider>().lastEntry;

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenHeader(title: l.bodyTitle, large: true),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                _WeightCard(profile: profile, logs: body.weights),
                const SizedBox(height: 14),
                _BodyFatCard(profile: profile, latest: body.latestMeasurement),
                const SizedBox(height: 14),
                _MeasurementsCard(
                    profile: profile, latest: body.latestMeasurement),
                const SizedBox(height: 14),
                _BmiCard(bmi: lastBmi?.bmi, onOpen: onOpenBmiHistory),
                const SizedBox(height: 10),
                AppButton(
                  label: l.calculateBmi,
                  icon: Icons.calculate_rounded,
                  fullWidth: true,
                  onPressed: onCalculateBmi,
                ),
                const SizedBox(height: 18),
                Text(
                  l.wellnessDisclaimer,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: fg3),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weight ───────────────────────────────────────────────────────────────────

class _WeightCard extends StatelessWidget {
  final UserProfile profile;
  final List<WeightLog> logs;

  const _WeightCard({required this.profile, required this.logs});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final unit = profile.weightUnit;
    final latest = logs.isEmpty ? null : logs.last;
    final averages = movingAverage(logs);

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.fieldWeight),
          const SizedBox(height: 8),
          if (latest == null)
            Text(l.weightEmpty,
                style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5))
          else ...[
            Text(
              Units.weight(latest.weightKg, unit),
              style: GoogleFonts.inter(
                  fontSize: 30, fontWeight: FontWeight.w700, color: fg1),
            ),
            const SizedBox(height: 2),
            Text(
              '${l.lastLogged(DateFormat('d MMM', l.localeName).format(latest.date))}'
              '  ·  ${l.weightAverage(Units.weight(averages.last, unit))}',
              style: GoogleFonts.inter(fontSize: 13, color: fg3),
            ),
            if (logs.length >= 2) ...[
              const SizedBox(height: 14),
              _WeightChart(logs: logs, averages: averages, unit: unit),
            ],
          ],
          const SizedBox(height: 14),
          AppButton(
            label: l.logWeight,
            icon: Icons.add_rounded,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => _showLogWeight(context, profile),
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightLog> logs;
  final List<double> averages;
  final String unit;

  const _WeightChart(
      {required this.logs, required this.averages, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final dotColor = (isDark ? AppColors.darkFg3 : AppColors.fg3).withAlpha(140);
    // Last 90 days keeps the chart readable.
    final start = logs.length > 90 ? logs.length - 90 : 0;
    final values = [
      for (var i = start; i < logs.length; i++) Units.kgTo(unit, logs[i].weightKg)
    ];
    final avg = [
      for (var i = start; i < logs.length; i++) Units.kgTo(unit, averages[i])
    ];
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final pad = ((hi - lo) * 0.2).clamp(0.5, 10.0);

    // Time runs left→right in every language.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 120,
        child: LineChart(
          LineChartData(
            minY: lo - pad,
            maxY: hi + pad,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              // Raw weigh-ins as dots only
              LineChartBarData(
                spots: [
                  for (var i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i])
                ],
                barWidth: 0,
                color: Colors.transparent,
                dotData: FlDotData(
                  getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 2.5, color: dotColor),
                ),
              ),
              // 7-day trend line
              LineChartBarData(
                spots: [
                  for (var i = 0; i < avg.length; i++)
                    FlSpot(i.toDouble(), avg[i])
                ],
                isCurved: true,
                curveSmoothness: 0.25,
                color: brand,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showLogWeight(BuildContext context, UserProfile profile) =>
    showDialog<void>(
      context: context,
      builder: (_) => _LogWeightDialog(profile: profile),
    );

/// Owns its text controller so it is disposed only after the dialog's exit
/// animation has finished.
class _LogWeightDialog extends StatefulWidget {
  final UserProfile profile;
  const _LogWeightDialog({required this.profile});

  @override
  State<_LogWeightDialog> createState() => _LogWeightDialogState();
}

class _LogWeightDialogState extends State<_LogWeightDialog> {
  late final TextEditingController _controller = TextEditingController(
      text: Units.kgTo(widget.profile.weightUnit, widget.profile.weightInKg)
          .toStringAsFixed(1));
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final unit = widget.profile.weightUnit;
    final value = double.tryParse(_controller.text.trim());
    final kg = value == null ? null : Units.toKg(unit, value);
    if (kg == null ||
        kg < BmiCalculator.minWeightKg ||
        kg > BmiCalculator.maxWeightKg) {
      setState(() => _error = l.errorWeightRange);
      return;
    }
    final body = context.read<BodyProvider>();
    final profiles = context.read<ProfileProvider>();
    Navigator.pop(context);
    await body.logWeight(kg);
    // The latest weigh-in is the user's current weight everywhere,
    // including the BMI calculator.
    await profiles.update(profiles.profile.copyWith(weight: value));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.logWeight),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(
            suffixText: widget.profile.weightUnit, errorText: _error),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}

// ── Body fat ─────────────────────────────────────────────────────────────────

class _BodyFatCard extends StatelessWidget {
  final UserProfile profile;
  final Measurement? latest;

  const _BodyFatCard({required this.profile, required this.latest});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final pct = BodyFat.forProfile(profile, latest);

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.bodyFatTitle),
          const SizedBox(height: 8),
          if (pct == null)
            Text(
              profile.formulaSex == Sex.female
                  ? l.bodyFatNeedsFemale
                  : l.bodyFatNeedsMale,
              style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5),
            )
          else
            Text('${pct.toStringAsFixed(1)} %',
                style: GoogleFonts.inter(
                    fontSize: 30, fontWeight: FontWeight.w700, color: fg1)),
          const SizedBox(height: 6),
          Text(l.bodyFatMethod,
              style: GoogleFonts.inter(fontSize: 12, color: fg3, height: 1.4)),
        ],
      ),
    );
  }
}

// ── Measurements ─────────────────────────────────────────────────────────────

String _fieldLabel(AppLocalizations l, MeasureField f, Sex sex) => switch (f) {
      MeasureField.neck => l.measureNeck,
      MeasureField.chest => sex == Sex.female ? l.measureBust : l.measureChest,
      MeasureField.waist => l.measureWaist,
      MeasureField.hips => l.measureHips,
      MeasureField.arm => l.measureArm,
      MeasureField.thigh => l.measureThigh,
    };

double? _valueOf(Measurement m, MeasureField f) => switch (f) {
      MeasureField.neck => m.neck,
      MeasureField.chest => m.chest,
      MeasureField.waist => m.waist,
      MeasureField.hips => m.hips,
      MeasureField.arm => m.arm,
      MeasureField.thigh => m.thigh,
    };

class _MeasurementsCard extends StatelessWidget {
  final UserProfile profile;
  final Measurement? latest;

  const _MeasurementsCard({required this.profile, required this.latest});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sex = profile.formulaSex;
    final unit = Units.lengthUnit(profile.heightUnit);
    final m = latest;

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OverlineLabel(l.measurementsTitle),
              const Spacer(),
              if (m != null)
                Text(DateFormat('d MMM', l.localeName).format(m.date),
                    style: GoogleFonts.inter(fontSize: 12, color: fg3)),
            ],
          ),
          const SizedBox(height: 8),
          if (m == null)
            Text(l.measurementsEmpty,
                style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5))
          else
            for (final f in measureFieldsFor(sex))
              if (_valueOf(m, f) != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(_fieldLabel(l, f, sex),
                          style: GoogleFonts.inter(fontSize: 14, color: fg2)),
                      const Spacer(),
                      Text(Units.length(_valueOf(m, f)!, unit),
                          textDirection: TextDirection.ltr,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: fg1)),
                    ],
                  ),
                ),
          const SizedBox(height: 14),
          AppButton(
            label: l.addMeasurements,
            icon: Icons.straighten_rounded,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => _showAddMeasurements(context, profile),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddMeasurements(BuildContext context, UserProfile profile) {
  return showModalBottomSheet<void>(
    context: context,
    // Above the tab bar and banner, which sit over each tab's navigator
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MeasurementsSheet(profile: profile),
  );
}

class _MeasurementsSheet extends StatefulWidget {
  final UserProfile profile;
  const _MeasurementsSheet({required this.profile});

  @override
  State<_MeasurementsSheet> createState() => _MeasurementsSheetState();
}

class _MeasurementsSheetState extends State<_MeasurementsSheet> {
  late final Map<MeasureField, TextEditingController> _fields = {
    for (final f in MeasureField.values) f: TextEditingController(),
  };
  String? _error;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final unit = Units.lengthUnit(widget.profile.heightUnit);
    final cm = <MeasureField, double>{};
    for (final e in _fields.entries) {
      final text = e.value.text.trim();
      if (text.isEmpty) continue;
      final v = double.tryParse(text);
      final asCm = v == null ? null : Units.toCm(unit, v);
      if (asCm == null || asCm < 5 || asCm > 300) {
        setState(() => _error = l.measureRangeError);
        return;
      }
      cm[e.key] = asCm;
    }
    final body = context.read<BodyProvider>();
    Navigator.pop(context);
    await body.addMeasurement(Measurement(
      date: DateTime.now(),
      neck: cm[MeasureField.neck],
      chest: cm[MeasureField.chest],
      waist: cm[MeasureField.waist],
      hips: cm[MeasureField.hips],
      arm: cm[MeasureField.arm],
      thigh: cm[MeasureField.thigh],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final sex = widget.profile.formulaSex;
    final unit = Units.lengthUnit(widget.profile.heightUnit);

    return Padding(
      // Keep the fields above the keyboard
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.measurementsTitle,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l.measureHint,
                style: GoogleFonts.inter(fontSize: 13, color: fg2, height: 1.4)),
            const SizedBox(height: 12),
            for (final f in measureFieldsFor(sex))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _fields[f],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  decoration: InputDecoration(
                    labelText: _fieldLabel(l, f, sex),
                    suffixText: unit,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.bmiObese)),
              ),
            AppButton(
              label: l.save,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ── BMI ──────────────────────────────────────────────────────────────────────

class _BmiCard extends StatelessWidget {
  final double? bmi;
  final VoidCallback onOpen;

  const _BmiCard({required this.bmi, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final value = bmi;

    return AppCard(
      padding: 18,
      onTap: onOpen,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverlineLabel(l.bmiHistory),
                const SizedBox(height: 8),
                if (value == null)
                  Text(l.noBmiYet,
                      style: GoogleFonts.inter(fontSize: 14, color: fg3))
                else
                  Row(
                    children: [
                      Text(value.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: fg1)),
                      const SizedBox(width: 10),
                      StatusPill(category: BmiCalculator.category(value)),
                    ],
                  ),
              ],
            ),
          ),
          Text(l.viewAll,
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: brand)),
          Icon(Icons.chevron_right_rounded, color: brand),
        ],
      ),
    );
  }
}
