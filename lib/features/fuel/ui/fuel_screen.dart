import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:bmi_health/features/fuel/foods/food_catalog.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/shared/widgets/screen_header.dart';
import 'package:bmi_health/features/fuel/barcode/scan_food_screen.dart';

/// Fuel tab: calorie & macro targets, quick food log, water.
class FuelScreen extends StatelessWidget {
  final VoidCallback onOpenProfile;
  const FuelScreen({super.key, required this.onOpenProfile});

  static void _manual(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const _LogFoodDialog());

  /// Full-screen scanner above the tab bar and banner.
  static void _scan(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.push(MaterialPageRoute<void>(
      builder: (_) => ScanFoodScreen(
        onClose: nav.pop,
        onManual: () => _manual(context),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final profile = context.watch<ProfileProvider>().profile;
    final fuel = context.watch<FuelProvider>();
    final t = Nutrition.targetsFor(profile);

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: ScreenHeader(title: l.fuelTitle, large: true)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.list(children: [
                const _DaySwitcher(),
                const SizedBox(height: 8),
                CaloriesCard(eaten: fuel.dayKcal, target: t.calories),
                const SizedBox(height: 14),
                AppCard(
                  padding: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MacroRow(
                          label: l.macroProtein,
                          eaten: fuel.dayProteinG.round(),
                          target: t.proteinG,
                          color: brand),
                      _MacroRow(
                          label: l.macroCarbs,
                          eaten: fuel.dayHasCarbs ? fuel.dayCarbsG.round() : null,
                          target: t.carbsG,
                          color: AppColors.bmiOver),
                      _MacroRow(
                          label: l.macroFat,
                          eaten: fuel.dayHasFat ? fuel.dayFatG.round() : null,
                          target: t.fatG,
                          color: AppColors.bmiUnder),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                WaterCard(
                    drunk: fuel.dayWaterMl, goal: t.waterMl, viewedDay: true),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: AppButton(
                      label: l.logFood,
                      icon: Icons.add_rounded,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => _manual(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: l.scanBarcode,
                      icon: Icons.qr_code_scanner_rounded,
                      size: AppButtonSize.lg,
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () => _scan(context),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                if (fuel.dayFood.isEmpty)
                  Text(l.foodEmpty,
                      style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5))
                else
                  AppCard(
                    padding: 4,
                    child: Column(children: [
                      for (final f in fuel.dayFood.reversed)
                        Dismissible(
                          key: ValueKey('food-${f.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: AppColors.bmiObese,
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsetsDirectional.only(end: 16),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                          onDismissed: (_) => fuel.deleteFood(f.id!),
                          child: ListTile(
                            onTap: () => showDialog<void>(
                                context: context,
                                builder: (_) => _LogFoodDialog(existing: f)),
                            title: Text(f.name.isEmpty ? l.foodUnnamed : f.name),
                            subtitle: Text([
                              DateFormat.jm(l.localeName).format(f.date),
                              if (_macroLine(l, f) case final m?) m,
                            ].join(' · ')),
                            trailing: Text('${f.kcal} kcal',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ]),
                  ),
                const SizedBox(height: 14),
                _WeekCard(week: fuel.week, target: t.calories),
                const SizedBox(height: 18),
                if (profile.goal == null)
                  TextButton(
                    onPressed: onOpenProfile,
                    child: Text(l.completeProfileForTargets, textAlign: TextAlign.center),
                  ),
                Text(l.targetsExplain,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12, color: fg3, height: 1.4)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calories eaten vs target. Shared with the Today dashboard.
class CaloriesCard extends StatelessWidget {
  final int eaten;
  final int target;
  final VoidCallback? onTap;

  const CaloriesCard(
      {super.key, required this.eaten, required this.target, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final over = eaten > target;

    return AppCard(
      padding: 18,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(l.caloriesTitle),
          const SizedBox(height: 8),
          Text(over ? l.kcalOver(eaten - target) : l.kcalLeft(target - eaten),
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: over ? AppColors.bmiObese : fg1)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: target == 0 ? 0 : (eaten / target).clamp(0.0, 1.0),
              minHeight: 10,
              color: over ? AppColors.bmiObese : brand,
              backgroundColor: sunken,
            ),
          ),
          const SizedBox(height: 6),
          Text(l.kcalOf(eaten, target),
              style: GoogleFonts.inter(fontSize: 13, color: fg3)),
        ],
      ),
    );
  }
}

/// Water drunk vs goal with ±1 glass buttons. Shared with Today.
class WaterCard extends StatelessWidget {
  final int drunk;
  final int goal;

  /// Adds to the day shown in the Fuel tab instead of today.
  final bool viewedDay;

  const WaterCard(
      {super.key, required this.drunk, required this.goal, this.viewedDay = false});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final fuel = context.read<FuelProvider>();
    const water = AppColors.bmiUnder;

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: water, size: 20),
              const SizedBox(width: 6),
              OverlineLabel(l.waterTitle),
              const Spacer(),
              Text(l.waterOf(drunk, goal),
                  style: GoogleFonts.inter(fontSize: 13, color: fg3)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal == 0 ? 0 : (drunk / goal).clamp(0.0, 1.0),
              minHeight: 10,
              color: water,
              backgroundColor: sunken,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: drunk > 0
                      ? () => fuel.addWater(-250, viewedDay: viewedDay)
                      : null,
                  child: Text(l.removeGlass),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: water),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    fuel.addWater(250, viewedDay: viewedDay);
                  },
                  child: Text(l.addGlass),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int? eaten; // null when no entry of the day has this macro
  final int target;
  final Color color;

  const _MacroRow(
      {required this.label, this.eaten, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: fg2)),
          const Spacer(),
          Text(
            eaten == null ? l.gramsTarget(target) : l.gramsOf(eaten!, target),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// "P 25 g · C 60 g · F 12 g" for the macros an entry has, else null.
String? _macroLine(AppLocalizations l, FoodLog f) {
  String g(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
  final parts = [
    if (f.proteinG case final p?) l.fuelMacroP(g(p)),
    if (f.carbsG case final c?) l.fuelMacroC(g(c)),
    if (f.fatG case final x?) l.fuelMacroF(g(x)),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// ‹ Today › — steps back through past days; tap the label to pick a date.
class _DaySwitcher extends StatelessWidget {
  const _DaySwitcher();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fuel = context.watch<FuelProvider>();
    final day = fuel.viewDay;
    final today = fuel.today;
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final label = fuel.viewingToday
        ? l.fuelToday
        : day == yesterday
            ? l.fuelYesterday
            : DateFormat.MMMEd(l.localeName).format(day);

    return Row(
      children: [
        IconButton(
          tooltip: l.fuelPreviousDay,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: fuel.previousDay,
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: day,
                firstDate: DateTime(2020),
                lastDate: today,
                helpText: l.fuelPickDay,
              );
              if (picked != null) await fuel.showDay(picked);
            },
            icon: const Icon(Icons.event_rounded, size: 18),
            label: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        IconButton(
          tooltip: l.fuelNextDay,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: fuel.viewingToday ? null : fuel.nextDay,
        ),
      ],
    );
  }
}

/// Calories per day for the week ending on the viewed day, against the
/// target line. Tap a bar to open that day.
class _WeekCard extends StatelessWidget {
  final List<DayKcal> week;
  final int target;
  const _WeekCard({required this.week, required this.target});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    if (week.isEmpty) return const SizedBox.shrink();
    final fuel = context.read<FuelProvider>();
    final logged = week.where((d) => d.kcal > 0).toList();
    final avg = logged.isEmpty
        ? 0
        : (logged.fold(0, (s, d) => s + d.kcal) / logged.length).round();
    final top = [target, ...week.map((d) => d.kcal)]
            .reduce((a, b) => a > b ? a : b) *
        1.15;
    final dayFmt = DateFormat.E(l.localeName);

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            OverlineLabel(l.fuelWeekTitle),
            const Spacer(),
            if (logged.isNotEmpty)
              Text(l.fuelWeekAverage(avg),
                  style: GoogleFonts.inter(fontSize: 12, color: fg3)),
          ]),
          const SizedBox(height: 12),
          // Time runs left→right in every language.
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 130,
              child: BarChart(
                BarChartData(
                  maxY: top.toDouble(),
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                        y: target.toDouble(),
                        color: fg3.withAlpha(150),
                        strokeWidth: 1,
                        dashArray: [4, 4]),
                  ]),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (v, _) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(dayFmt.format(week[v.toInt()].day),
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: fg3)),
                        ),
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (g, _, r, __) => BarTooltipItem(
                          '${r.toY.round()} kcal',
                          const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    touchCallback: (event, response) {
                      final i = response?.spot?.touchedBarGroupIndex;
                      if (event is FlTapUpEvent && i != null) {
                        fuel.showDay(week[i].day);
                      }
                    },
                  ),
                  barGroups: [
                    for (var i = 0; i < week.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: week[i].kcal.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(5),
                          color: week[i].kcal > target
                              ? AppColors.bmiObese
                              : (i == week.length - 1
                                  ? brand
                                  : brand.withAlpha(150)),
                          backDrawRodData: BackgroundBarChartRodData(
                              show: true, toY: top.toDouble(), color: sunken),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(l.fuelWeekTarget(target),
              style: GoogleFonts.inter(fontSize: 12, color: fg3)),
        ],
      ),
    );
  }
}

/// Logs a food on the viewed day, or with [existing] edits that entry.
class _LogFoodDialog extends StatefulWidget {
  final FoodLog? existing;
  const _LogFoodDialog({this.existing});

  @override
  State<_LogFoodDialog> createState() => _LogFoodDialogState();
}

class _LogFoodDialogState extends State<_LogFoodDialog> {
  static String _g(double? v) =>
      v == null ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _kcal =
      TextEditingController(text: widget.existing?.kcal.toString() ?? '');
  late final _protein = TextEditingController(text: _g(widget.existing?.proteinG));
  late final _carbs = TextEditingController(text: _g(widget.existing?.carbsG));
  late final _fat = TextEditingController(text: _g(widget.existing?.fatG));
  final _search = TextEditingController();
  final _customGrams = TextEditingController();
  String? _error;
  String? _macroError;

  // Offline food list: pick a food and a portion to fill the fields.
  FoodCatalog? _catalog;
  Map<String, int> _usage = const {};
  FoodItem? _picked;
  static const _portions = [0.5, 1.0, 1.5, 2.0];
  double? _multiplier = 1; // null = custom grams

  @override
  void initState() {
    super.initState();
    FoodCatalog.load().then((c) async {
      final usage = await FoodUsage.load();
      if (!mounted) return;
      setState(() {
        _catalog = c;
        _usage = usage;
      });
    });
  }

  void _pick(FoodItem f) {
    setState(() {
      _picked = f;
      _multiplier = 1;
      _customGrams.text = '${f.grams}';
    });
    _fill();
  }

  /// Fills name, kcal and macros from the picked food and portion.
  void _fill() {
    final f = _picked;
    if (f == null) return;
    final m = _multiplier ?? (double.tryParse(_customGrams.text.trim()) ?? 0) / f.grams;
    _name.text = f.name(context.l10n.localeName);
    _kcal.text = (f.kcal * m).round().toString();
    _protein.text = _g(_round1(f.protein * m));
    _carbs.text = _g(_round1(f.carbs * m));
    _fat.text = _g(_round1(f.fat * m));
  }

  static double _round1(double v) => (v * 10).round() / 10;

  static String _portionLabel(double m) => switch (m) {
        0.5 => '½',
        1.5 => '1½',
        _ => m.toStringAsFixed(0),
      };

  @override
  void dispose() {
    _search.dispose();
    _customGrams.dispose();
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  /// Empty → null; otherwise 0–1000 g.
  static (bool ok, double? value) _grams(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return (true, null);
    final v = double.tryParse(t);
    return (v != null && v >= 0 && v <= 1000, v);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final kcal = int.tryParse(_kcal.text.trim());
    final kcalOk = kcal != null && kcal >= 1 && kcal <= 5000;
    final (pOk, protein) = _grams(_protein);
    final (cOk, carbs) = _grams(_carbs);
    final (fOk, fat) = _grams(_fat);
    final macrosOk = pOk && cOk && fOk;
    if (!kcalOk || !macrosOk) {
      setState(() {
        _error = kcalOk ? null : l.foodKcalError;
        _macroError = macrosOk ? null : l.fuelMacroError;
      });
      return;
    }
    final fuel = context.read<FuelProvider>();
    final picked = _picked;
    Navigator.pop(context);
    if (picked != null) await FoodUsage.record(picked.id);
    final e = widget.existing;
    if (e == null) {
      await fuel.addFood(
          kcal: kcal, name: _name.text, proteinG: protein, carbsG: carbs, fatG: fat);
    } else {
      await fuel.updateFood(FoodLog(
          id: e.id,
          date: e.date,
          name: _name.text.trim(),
          kcal: kcal,
          proteinG: protein,
          carbsG: carbs,
          fatG: fat));
    }
  }

  Widget _gramsField(TextEditingController c, String label, {bool last = false}) =>
      TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(labelText: label),
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        onSubmitted: last ? (_) => _save() : null,
      );

  List<Widget> _foodSearch(BuildContext context) {
    final l = context.l10n;
    final locale = l.localeName;
    final catalog = _catalog;
    final fg3 = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkFg3
        : AppColors.fg3;
    final picked = _picked;
    if (picked != null) {
      return [
        Row(children: [
          Expanded(
            child: Text(
                l.foodsPortionKcal(picked.portion(locale), picked.kcal),
                style: GoogleFonts.inter(fontSize: 13, color: fg3)),
          ),
          IconButton(
            tooltip: l.foodsClear,
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => setState(() => _picked = null),
          ),
        ]),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final m in _portions)
            ChoiceChip(
              label: Text('${_portionLabel(m)}×'),
              selected: _multiplier == m,
              onSelected: (_) {
                setState(() => _multiplier = m);
                _fill();
              },
            ),
          ChoiceChip(
            label: Text(l.foodsCustom),
            selected: _multiplier == null,
            onSelected: (_) {
              setState(() => _multiplier = null);
              _fill();
            },
          ),
        ]),
        if (_multiplier == null)
          TextField(
            controller: _customGrams,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.foodsGrams),
            onChanged: (_) => _fill(),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Text(l.foodsApprox,
              style: GoogleFonts.inter(fontSize: 12, color: fg3)),
        ),
      ];
    }
    if (catalog == null) return const [];
    final q = _search.text;
    final results = catalog.search(q, usage: _usage, limit: 6);
    return [
      TextField(
        controller: _search,
        autofocus: widget.existing == null,
        decoration: InputDecoration(
          labelText: l.foodsSearch,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
        onChanged: (_) => setState(() {}),
      ),
      if (q.trim().isEmpty && results.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l.foodsRecent,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: fg3)),
          ),
        ),
      for (final f in results)
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(f.name(locale)),
          subtitle: Text(l.foodsPortionKcal(f.portion(locale), f.kcal)),
          onTap: () => _pick(f),
        ),
      if (q.trim().isNotEmpty && results.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l.foodsNoMatch,
              style: GoogleFonts.inter(fontSize: 12, color: fg3)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l.logFood : l.fuelEditFood),
      content: SingleChildScrollView(
        // Room for the floating labels of outlined fields
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            ..._foodSearch(context),
            TextField(
              controller: _name,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.foodName, counterText: ''),
            ),
            TextField(
              controller: _kcal,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l.foodKcal, errorText: _error),
            ),
            _gramsField(_protein, l.foodProtein),
            _gramsField(_carbs, l.fuelCarbsField),
            _gramsField(_fat, l.fuelFatField, last: true),
            if (_macroError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_macroError!,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.bmiObese)),
              ),
          ],
        ),
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
