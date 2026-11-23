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
import 'package:bmi_health/features/body/photos/progress_photos_card.dart';
import 'package:bmi_health/features/progress/domain/achievements.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';

/// Body tab: weight trend, body-fat estimate, measurements, BMI history.
/// The "Me" tab: progress and badges, weight, BMI, body measurements and
/// photos. Settings open from the gear in the header.
class BodyScreen extends StatelessWidget {
  final VoidCallback onOpenBmiHistory;
  final VoidCallback onCalculateBmi;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenProgress;

  const BodyScreen({
    super.key,
    required this.onOpenBmiHistory,
    required this.onCalculateBmi,
    required this.onOpenSettings,
    required this.onOpenProgress,
  });

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
              child: ScreenHeader(
                title: l.navMe,
                large: true,
                trailing: IconButton(
                  tooltip: l.navSettings,
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: onOpenSettings,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                _ProgressCard(onOpen: onOpenProgress),
                const SizedBox(height: 14),
                _WeightCard(profile: profile, logs: body.weights),
                const SizedBox(height: 14),
                _BmiCard(bmi: lastBmi?.bmi, onOpen: onOpenBmiHistory),
                const SizedBox(height: 10),
                AppButton(
                  label: l.calculateBmi,
                  icon: Icons.calculate_rounded,
                  fullWidth: true,
                  onPressed: onCalculateBmi,
                ),
                const SizedBox(height: 14),
                _BodyFatCard(profile: profile, latest: body.latestMeasurement),
                const SizedBox(height: 14),
                _MeasurementsCard(
                    profile: profile, latest: body.latestMeasurement),
                const SizedBox(height: 14),
                const ProgressPhotosCard(),
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

// ── Progress ─────────────────────────────────────────────────────────────────

/// Week streak and badges; opens the progress screen.
class _ProgressCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _ProgressCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final history = context.watch<WorkoutProvider>().history;
    final goal = context.watch<ProfileProvider>().profile.daysPerWeek;
    final streak = Streaks.weeks([for (final h in history) h.workout.startedAt], goal, DateTime.now());
    return AppCard(
      padding: 4,
      onTap: onOpen,
      child: ListTile(
        leading: const Icon(Icons.emoji_events_rounded, color: AppColors.bmiOver),
        title: Text(l.meProgressTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: Text(streak > 0 ? l.weekStreak(streak) : l.meProgressBody),
        trailing: const Icon(Icons.chevron_right_rounded),
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
          if (logs.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => _showWeightHistory(context),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(l.bodyWeighIns),
              ),
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

Future<void> _showLogWeight(BuildContext context, UserProfile profile,
        {WeightLog? existing}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _LogWeightDialog(profile: profile, existing: existing),
    );

/// The latest weigh-in is the user's current weight everywhere, including
/// the BMI calculator; re-synced after any add, edit or delete.
Future<void> _syncProfileWeight(
    BodyProvider body, ProfileProvider profiles) async {
  final latest = body.latestWeight;
  if (latest == null) return;
  final p = profiles.profile;
  final value = double.parse(
      Units.kgTo(p.weightUnit, latest.weightKg).toStringAsFixed(1));
  if (value != p.weight) await profiles.update(p.copyWith(weight: value));
}

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
        TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: Text(l.delete,
                style: const TextStyle(color: AppColors.bmiObese))),
      ],
    ),
  );
  return ok == true;
}

/// A date no later than today.
Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial.isAfter(now) ? now : initial,
    firstDate: DateTime(2000),
    lastDate: now,
  );
}

/// [day] with the time of day of [old].
DateTime _onDay(DateTime day, DateTime old) =>
    DateTime(day.year, day.month, day.day, old.hour, old.minute, old.second);

/// Opens a list sheet above the tab bar and banner.
Future<void> _showSheet(BuildContext context, Widget sheet) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => sheet,
    );

Future<void> _showWeightHistory(BuildContext context) =>
    _showSheet(context, const _WeightHistorySheet());

/// Every weigh-in, newest first; tap to edit, bin to delete.
class _WeightHistorySheet extends StatelessWidget {
  const _WeightHistorySheet();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final body = context.watch<BodyProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final fmt = DateFormat.yMMMd(l.localeName);

    return _HistoryList(
      title: l.bodyWeighIns,
      empty: l.weightEmpty,
      children: [
        for (final w in body.weights.reversed)
          ListTile(
            key: ValueKey('weight-${w.id}'),
            title: Text(Units.weight(w.weightKg, profile.weightUnit),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(fmt.format(w.date)),
            onTap: () => _showLogWeight(context, profile, existing: w),
            trailing: IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final profiles = context.read<ProfileProvider>();
                if (!await _confirmDelete(context, l.bodyDeleteWeighIn)) return;
                await body.deleteWeight(w.id!);
                await _syncProfileWeight(body, profiles);
              },
            ),
          ),
      ],
    );
  }
}

/// A titled, scrollable list for a bottom sheet.
class _HistoryList extends StatelessWidget {
  final String title;
  final String empty;
  final List<Widget> children;
  const _HistoryList(
      {required this.title, required this.empty, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(empty,
                  style: GoogleFonts.inter(fontSize: 14, color: fg3)),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

/// Owns its text controller so it is disposed only after the dialog's exit
/// animation has finished. With [existing], edits that weigh-in.
class _LogWeightDialog extends StatefulWidget {
  final UserProfile profile;
  final WeightLog? existing;
  const _LogWeightDialog({required this.profile, this.existing});

  @override
  State<_LogWeightDialog> createState() => _LogWeightDialogState();
}

class _LogWeightDialogState extends State<_LogWeightDialog> {
  late final TextEditingController _controller = TextEditingController(
      text: Units.kgTo(widget.profile.weightUnit,
              widget.existing?.weightKg ?? widget.profile.weightInKg)
          .toStringAsFixed(1));
  late DateTime _date = widget.existing?.date ?? DateTime.now();
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
    final existing = widget.existing;
    if (existing == null) {
      await body.logWeight(kg, at: _date);
    } else {
      await body.updateWeight(
          WeightLog(id: existing.id, date: _date, weightKg: kg));
    }
    await _syncProfileWeight(body, profiles);
  }

  Future<void> _changeDate() async {
    final picked = await _pickDate(context, _date);
    if (picked != null) setState(() => _date = _onDay(picked, _date));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.logWeight : l.bodyEditWeighIn),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            decoration: InputDecoration(
                suffixText: widget.profile.weightUnit, errorText: _error),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _changeDate,
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(DateFormat.yMMMd(l.localeName).format(_date)),
          ),
        ],
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
          if (m != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () =>
                    _showSheet(context, const _MeasurementHistorySheet()),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(l.bodyMeasurementHistory),
              ),
            ),
        ],
      ),
    );
  }
}

// Above the tab bar and banner, which sit over each tab's navigator
Future<void> _showAddMeasurements(BuildContext context, UserProfile profile,
        {Measurement? existing}) =>
    _showSheet(context, _MeasurementsSheet(profile: profile, existing: existing));

/// Every measurement session, newest first; tap to edit, bin to delete.
class _MeasurementHistorySheet extends StatelessWidget {
  const _MeasurementHistorySheet();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final body = context.watch<BodyProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final sex = profile.formulaSex;
    final unit = Units.lengthUnit(profile.heightUnit);
    final fmt = DateFormat.yMMMd(l.localeName);

    return _HistoryList(
      title: l.bodyMeasurementHistory,
      empty: l.measurementsEmpty,
      children: [
        for (final m in body.measurements)
          ListTile(
            key: ValueKey('measurement-${m.id}'),
            title: Text(fmt.format(m.date),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text([
              for (final f in measureFieldsFor(sex))
                if (_valueOf(m, f) case final v?)
                  '${_fieldLabel(l, f, sex)} ${Units.length(v, unit)}'
            ].join(' · ')),
            onTap: () => _showAddMeasurements(context, profile, existing: m),
            trailing: IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                if (!await _confirmDelete(context, l.bodyDeleteMeasurement)) {
                  return;
                }
                await body.deleteMeasurement(m.id!);
              },
            ),
          ),
      ],
    );
  }
}

/// Adds a measurement session, or with [existing] edits it.
class _MeasurementsSheet extends StatefulWidget {
  final UserProfile profile;
  final Measurement? existing;
  const _MeasurementsSheet({required this.profile, this.existing});

  @override
  State<_MeasurementsSheet> createState() => _MeasurementsSheetState();
}

class _MeasurementsSheetState extends State<_MeasurementsSheet> {
  late final Map<MeasureField, TextEditingController> _fields = {
    for (final f in MeasureField.values)
      f: TextEditingController(text: _initial(f)),
  };
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  String? _error;

  String _initial(MeasureField f) {
    final m = widget.existing;
    final v = m == null ? null : _valueOf(m, f);
    if (v == null) return '';
    return Units.cmTo(Units.lengthUnit(widget.profile.heightUnit), v)
        .toStringAsFixed(1);
  }

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
    final m = Measurement(
      id: widget.existing?.id,
      date: _date,
      neck: cm[MeasureField.neck],
      chest: cm[MeasureField.chest],
      waist: cm[MeasureField.waist],
      hips: cm[MeasureField.hips],
      arm: cm[MeasureField.arm],
      thigh: cm[MeasureField.thigh],
    );
    if (widget.existing == null) {
      await body.addMeasurement(m);
    } else {
      await body.updateMeasurement(m);
    }
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
            TextButton.icon(
              onPressed: () async {
                final picked = await _pickDate(context, _date);
                if (picked != null) {
                  setState(() => _date = _onDay(picked, _date));
                }
              },
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text(DateFormat.yMMMd(l.localeName).format(_date)),
            ),
            const SizedBox(height: 4),
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
