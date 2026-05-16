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

class HistoryScreen extends StatelessWidget {
  final VoidCallback onAddEntry;

  const HistoryScreen({super.key, required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final normalTint = isDark
        ? AppColors.bmiNormalTintDark
        : AppColors.bmiNormalTint;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final entries = provider.entries;

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: entries.isEmpty
                ? _EmptyState(onAddEntry: onAddEntry)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ScreenHeader(
                          title: 'History',
                          large: true,
                          trailing: Icon(Icons.filter_list_rounded,
                              color: brand, size: 22),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Trend chart card
                            _TrendCard(entries: entries,
                                brand: brand, normalTint: normalTint,
                                fg1: fg1, fg3: fg3, isDark: isDark),
                            const SizedBox(height: 14),

                            // Entry list card
                            AppCard(
                              padding: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 12, 18, 12),
                                    child: Row(
                                      children: [
                                        OverlineLabel(
                                            'Entries  ·  ${entries.length}'),
                                      ],
                                    ),
                                  ),
                                  ...entries.asMap().entries.map((e) {
                                    final i = e.key;
                                    final entry = e.value;
                                    return _EntryRow(
                                      entry: entry,
                                      prev: i < entries.length - 1
                                          ? entries[i + 1]
                                          : null,
                                      isDark: isDark,
                                      onDelete: () => provider.deleteEntry(
                                          entry.id!),
                                    );
                                  }),
                                ],
                              ),
                            ),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddEntry;
  const _EmptyState({required this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

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
                    decoration: BoxDecoration(
                      color: bgTint, shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.show_chart_rounded,
                        size: 36, color: brand),
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
    final pts = entries.reversed.toList();
    final bmis = pts.map((e) => e.bmi).toList();
    final minY = (bmis.reduce((a, b) => a < b ? a : b) - 0.5).floorToDouble();
    final maxY = (bmis.reduce((a, b) => a > b ? a : b) + 0.5).ceilToDouble();
    final lastBmi = pts.last.bmi;
    final firstBmi = pts.first.bmi;
    final delta = lastBmi - firstBmi;

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
                    'Last ${pts.length} entries',
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500, color: fg3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 10),
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
                    spots: pts.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), e.value.bmi)).toList(),
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
                          brand.withOpacity(0.22),
                          brand.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? AppColors.darkBgSurface
                        : AppColors.fg1.withOpacity(0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((s) =>
                        LineTooltipItem(
                          s.y.toStringAsFixed(1),
                          GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: pts.map((e) {
              return Text(
                '${e.date.day}',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: fg3,
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

class _EntryRow extends StatelessWidget {
  final BmiEntry entry;
  final BmiEntry? prev;
  final bool isDark;
  final VoidCallback onDelete;

  const _EntryRow({
    required this.entry,
    required this.prev,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = BmiCalculator.category(entry.bmi);
    final catTint = isDark ? cat.tintDark : cat.tint;
    final catInk  = isDark ? cat.inkDark  : cat.ink;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final border = isDark ? AppColors.darkBorderFaint : AppColors.borderFaint;
    final delta = prev != null ? entry.weight - prev!.weight : 0.0;

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
            Text(
              cat.label,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: catInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
