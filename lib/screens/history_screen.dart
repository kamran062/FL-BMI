import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/bmi_entry.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/overline_label.dart';
import '../widgets/screen_header.dart';

// ── Filter state enums ────────────────────────────────────────────────────────

enum _Period { all, d7, d30, m3, y1 }
enum _Category { all, under, normal, over, obese }

extension _PeriodExt on _Period {
  String get label => switch (this) {
        _Period.all => 'All time',
        _Period.d7  => 'Last 7 days',
        _Period.d30 => 'Last 30 days',
        _Period.m3  => 'Last 3 months',
        _Period.y1  => 'Last year',
      };

  DateTime? get cutoff {
    final now = DateTime.now();
    return switch (this) {
      _Period.all => null,
      _Period.d7  => now.subtract(const Duration(days: 7)),
      _Period.d30 => now.subtract(const Duration(days: 30)),
      _Period.m3  => DateTime(now.year, now.month - 3, now.day),
      _Period.y1  => DateTime(now.year - 1, now.month, now.day),
    };
  }
}

extension _CategoryExt on _Category {
  String get label => switch (this) {
        _Category.all    => 'All',
        _Category.under  => 'Underweight',
        _Category.normal => 'Normal',
        _Category.over   => 'Overweight',
        _Category.obese  => 'Obese',
      };

  String? get key => switch (this) {
        _Category.all    => null,
        _Category.under  => 'under',
        _Category.normal => 'normal',
        _Category.over   => 'over',
        _Category.obese  => 'obese',
      };
}

// ── Main screen ───────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  final VoidCallback onAddEntry;
  final void Function(BmiEntry entry)? onViewEntry;
  const HistoryScreen({super.key, required this.onAddEntry, this.onViewEntry});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Period   _period   = _Period.all;
  _Category _category = _Category.all;

  bool get _hasFilter => _period != _Period.all || _category != _Category.all;

  List<BmiEntry> _applyFilter(List<BmiEntry> all) {
    var result = all;
    final cutoff = _period.cutoff;
    if (cutoff != null) {
      result = result.where((e) => e.date.isAfter(cutoff)).toList();
    }
    final key = _category.key;
    if (key != null) {
      result = result
          .where((e) => BmiCalculator.category(e.bmi).key == key)
          .toList();
    }
    return result;
  }

  void _openFilter(BuildContext context, Color brand, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        period: _period,
        category: _category,
        brand: brand,
        isDark: isDark,
        onApply: (p, c) {
          setState(() { _period = p; _category = c; });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() { _period = _Period.all; _category = _Category.all; });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas  = isDark ? AppColors.darkBgCanvas  : AppColors.bgCanvas;
    final fg1       = isDark ? AppColors.darkFg1        : AppColors.fg1;
    final fg3       = isDark ? AppColors.darkFg3        : AppColors.fg3;
    final brand     = isDark ? AppColors.darkBrand500   : AppColors.brand500;
    final normalTint = isDark
        ? AppColors.bmiNormalTintDark
        : AppColors.bmiNormalTint;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final allEntries      = provider.entries;
        final filtered        = _applyFilter(allEntries);
        final noEntries       = allEntries.isEmpty;
        final noFilterResults = !noEntries && filtered.isEmpty;

        if (noEntries) {
          return _EmptyState(onAddEntry: widget.onAddEntry);
        }

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ScreenHeader(
                    title: 'History',
                    large: true,
                    trailing: GestureDetector(
                      onTap: () => _openFilter(context, brand, isDark),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.filter_list_rounded,
                              color: brand, size: 24),
                          if (_hasFilter)
                            Positioned(
                              top: -2, right: -2,
                              child: Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: brand,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Active filter chips
                if (_hasFilter)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_period != _Period.all)
                            _FilterChip(
                              label: _period.label,
                              brand: brand,
                              isDark: isDark,
                              onRemove: () =>
                                  setState(() => _period = _Period.all),
                            ),
                          if (_category != _Category.all)
                            _FilterChip(
                              label: _category.label,
                              brand: brand,
                              isDark: isDark,
                              onRemove: () =>
                                  setState(() => _category = _Category.all),
                            ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _period   = _Period.all;
                              _category = _Category.all;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Clear all',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: brand,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // No results after filtering
                      if (noFilterResults)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 40, color: fg3),
                              const SizedBox(height: 12),
                              Text(
                                'No entries match your filter',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: fg3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _period   = _Period.all;
                                  _category = _Category.all;
                                }),
                                child: Text(
                                  'Clear filters',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: brand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Trend chart (only when ≥ 2 entries)
                        if (filtered.length >= 2) ...[
                          _TrendCard(
                            entries: filtered,
                            brand: brand,
                            normalTint: normalTint,
                            fg1: fg1,
                            fg3: fg3,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Entry list card
                        AppCard(
                          padding: 0,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                                child: Row(
                                  children: [
                                    OverlineLabel(
                                      'Entries  ·  ${filtered.length}'
                                      '${_hasFilter ? ' of ${allEntries.length}' : ''}',
                                    ),
                                  ],
                                ),
                              ),
                              ...filtered.asMap().entries.map((e) {
                                final i     = e.key;
                                final entry = e.value;
                                // 'prev' for delta is the next older entry in filtered list
                                return _EntryRow(
                                  entry: entry,
                                  prev: i < filtered.length - 1
                                      ? filtered[i + 1]
                                      : null,
                                  isDark: isDark,
                                  onDelete: () =>
                                      provider.deleteEntry(entry.id!),
                                  onTap: () =>
                                      widget.onViewEntry?.call(entry),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final Color brand;
  final bool isDark;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.brand,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tint = isDark
        ? AppColors.darkBgTint
        : brand.withAlpha(20);
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: brand.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: brand,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.close_rounded, size: 13, color: brand),
          ],
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final _Period period;
  final _Category category;
  final Color brand;
  final bool isDark;
  final void Function(_Period, _Category) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.period,
    required this.category,
    required this.brand,
    required this.isDark,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _Period   _period;
  late _Category _category;

  @override
  void initState() {
    super.initState();
    _period   = widget.period;
    _category = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = widget.isDark;
    final brand   = widget.brand;
    final bg      = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final fg1     = isDark ? AppColors.darkFg1       : AppColors.fg1;
    final fg3     = isDark ? AppColors.darkFg3       : AppColors.fg3;
    final border  = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title row
          Row(
            children: [
              Text(
                'Filter entries',
                style: GoogleFonts.inter(
                  fontSize: 17, fontWeight: FontWeight.w700, color: fg1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onClear,
                child: Text(
                  'Clear all',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600, color: brand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Period section
          Text(
            'TIME PERIOD',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.8, color: fg3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _Period.values.map((p) => _OptionChip(
              label: p.label,
              selected: _period == p,
              brand: brand,
              isDark: isDark,
              onTap: () => setState(() => _period = p),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Category section
          Text(
            'BMI CATEGORY',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.8, color: fg3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _Category.values.map((c) => _OptionChip(
              label: c.label,
              selected: _category == c,
              brand: brand,
              isDark: isDark,
              onTap: () => setState(() => _category = c),
            )).toList(),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Apply filter',
              variant: AppButtonVariant.primary,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () => widget.onApply(_period, _category),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color brand;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.brand,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg     = selected ? brand : (isDark ? AppColors.darkBgTint : AppColors.bgTint);
    final fgCol  = selected ? Colors.white : (isDark ? AppColors.darkFg2 : AppColors.fg2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? brand : (isDark ? AppColors.darkBorderFaint : AppColors.borderFaint),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: fgCol,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddEntry;
  const _EmptyState({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1    = isDark ? AppColors.darkFg1    : AppColors.fg1;
    final fg2    = isDark ? AppColors.darkFg2    : AppColors.fg2;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand  = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'History', large: true),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(color: bgTint, shape: BoxShape.circle),
                    child: Icon(Icons.show_chart_rounded, size: 36, color: brand),
                  ),
                  const SizedBox(height: 18),
                  Text('No history yet',
                    style: GoogleFonts.inter(
                      fontSize: 19, fontWeight: FontWeight.w600,
                      color: fg1, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start tracking today — every entry shapes your trend.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w400,
                      color: fg2, height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Add first entry',
                    variant: AppButtonVariant.primary,
                    icon: Icons.add_rounded,
                    onPressed: onAddEntry,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trend chart card ──────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final List<BmiEntry> entries;
  final Color brand;
  final Color normalTint;
  final Color fg1;
  final Color fg3;
  final bool isDark;

  const _TrendCard({
    required this.entries,
    required this.brand,
    required this.normalTint,
    required this.fg1,
    required this.fg3,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pts     = entries.reversed.toList();
    final bmis    = pts.map((e) => e.bmi).toList();
    final minY    = (bmis.reduce((a, b) => a < b ? a : b) - 0.5).floorToDouble();
    final maxY    = (bmis.reduce((a, b) => a > b ? a : b) + 0.5).ceilToDouble();
    final lastBmi  = pts.last.bmi;
    final firstBmi = pts.first.bmi;
    final delta    = lastBmi - firstBmi;

    return AppCard(
      padding: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OverlineLabel('BMI Trend'),
                  const SizedBox(height: 6),
                  Text(
                    lastBmi.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 28, fontWeight: FontWeight.w700,
                      letterSpacing: -0.02 * 28, color: fg1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${pts.length} ${pts.length == 1 ? 'entry' : 'entries'}',
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: fg3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: delta <= 0
                      ? (isDark ? AppColors.bmiNormalTintDark : AppColors.bmiNormalTint)
                      : (isDark ? AppColors.bmiOverTintDark   : AppColors.bmiOverTint),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      delta <= 0
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      size: 12,
                      color: delta <= 0
                          ? (isDark ? AppColors.bmiNormalInkDark : AppColors.bmiNormalInk)
                          : (isDark ? AppColors.bmiOverInkDark   : AppColors.bmiOverInk),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} BMI',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: delta <= 0
                            ? (isDark ? AppColors.bmiNormalInkDark : AppColors.bmiNormalInk)
                            : (isDark ? AppColors.bmiOverInkDark   : AppColors.bmiOverInk),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minY: minY, maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 18.5, color: normalTint, strokeWidth: 1),
                    HorizontalLine(y: 24.9, color: normalTint, strokeWidth: 1),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: pts.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.bmi))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: brand,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: idx == pts.length - 1 ? 5 : 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: brand,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          brand.withAlpha(56),
                          brand.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? AppColors.darkBgSurface
                        : AppColors.fg1.withAlpha(230),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              s.y.toStringAsFixed(1),
                              GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: pts.map((e) {
              return Text(
                '${e.date.day}',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500, color: fg3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Entry row ─────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  final BmiEntry entry;
  final BmiEntry? prev;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _EntryRow({
    required this.entry,
    required this.prev,
    required this.isDark,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat    = BmiCalculator.category(entry.bmi);
    final catTint = isDark ? cat.tintDark : cat.tint;
    final catInk  = isDark ? cat.inkDark  : cat.ink;
    final fg1    = isDark ? AppColors.darkFg1       : AppColors.fg1;
    final fg3    = isDark ? AppColors.darkFg3       : AppColors.fg3;
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    final delta  = prev != null ? entry.weight - prev!.weight : 0.0;

    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${entry.date.day} ${months[entry.date.month]}';

    return Dismissible(
      key: Key('entry_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.bmiObese,
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        splashColor: catTint.withAlpha(60),
        highlightColor: catTint.withAlpha(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: catTint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  delta < 0
                      ? Icons.trending_down_rounded
                      : delta > 0
                          ? Icons.trending_up_rounded
                          : Icons.remove_rounded,
                  size: 18, color: catInk,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.weight.toStringAsFixed(1)} kg',
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: fg1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '$dateStr · BMI ${entry.bmi.toStringAsFixed(1)}',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: fg3,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cat.label,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: catInk,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: fg3),
            ],
          ),
        ),
      ),
    );
  }
}
