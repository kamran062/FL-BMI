import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/app_card.dart';
import 'package:bmi_health/features/body/bmi/ui/widgets/bmi_gauge.dart';
import 'package:bmi_health/shared/widgets/overline_label.dart';
import 'package:bmi_health/features/body/bmi/ui/widgets/status_pill.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';

class ResultScreen extends StatelessWidget {
  final double bmi;
  final bool readOnly;
  final VoidCallback onClose;
  final VoidCallback? onSave;
  final VoidCallback onSetGoal;
  final VoidCallback onShare;

  const ResultScreen({
    super.key,
    required this.bmi,
    this.readOnly = false,
    required this.onClose,
    this.onSave,
    required this.onSetGoal,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final bgTint   = isDark ? AppColors.darkBgTint   : AppColors.bgTint;
    final bgSurface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final normal = isDark ? AppColors.darkBrand500 : AppColors.bmiNormal;
    final cat = BmiCalculator.category(bmi);
    final catTint = isDark ? cat.tintDark : cat.tint;
    final catInk  = isDark ? cat.inkDark  : cat.ink;
    final l = context.l10n;
    final advice = l.bmiAdvice(cat.key);

    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBgSurface : AppColors.bgSunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.chevron_left_rounded,
                            size: 22, color: fg1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.resultTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w600,
                          color: fg1, letterSpacing: tracking(context, -0.015 * 17),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onShare,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBgSurface : AppColors.bgSunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.share_outlined, size: 20, color: fg1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Gauge
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: BmiGauge(value: bmi, size: 240),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Recommendation card
                  AppCard(
                    padding: 20,
                    elevation: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            OverlineLabel(l.recommendation),
                            const Spacer(),
                            StatusPill(category: cat, solid: true),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          advice.headline,
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.015 * 19,
                            color: fg1,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          advice.copy,
                          style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w400,
                            color: fg2, height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...(advice.steps.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22, height: 22,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: catTint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11, fontWeight: FontWeight.w700,
                                        color: catInk, height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.w400,
                                      color: fg1, height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBgSunken
                                  : AppColors.bgSunken,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 15, color: fg3),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    advice.note,
                                    style: GoogleFonts.inter(
                                      fontSize: 12, fontWeight: FontWeight.w400,
                                      color: fg3, height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Healthy range card
                  AppCard(
                    padding: 18,
                    tint: bgTint,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OverlineLabel(l.healthyRange),
                            Text(
                              '18.5 – 24.9',
                              // Matches the LTR bar below it in every language
                              textDirection: TextDirection.ltr,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: normal,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // A number scale reads left→right in every language,
                        // so the bar and its tick labels stay LTR under Urdu.
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(children: [
                        _RangeBar(bmi: bmi, catColor: cat.color,
                            normalColor: normal, trackColor: bgSurface),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['14', '18.5', '25', '30', '40'].map((v) =>
                            Text(v, style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: fg3,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            )),
                          ).toList(),
                        ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action row
                  Row(
                    children: [
                      if (!readOnly) ...[
                        Expanded(
                          child: AppButton(
                            label: l.saveResult,
                            variant: AppButtonVariant.secondary,
                            icon: Icons.bookmark_border_rounded,
                            onPressed: onSave,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: AppButton(
                          label: l.setGoal,
                          variant: AppButtonVariant.secondary,
                          icon: Icons.track_changes_rounded,
                          onPressed: onSetGoal,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: l.shareResult,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.lg,
                    icon: Icons.share_outlined,
                    fullWidth: true,
                    onPressed: onShare,
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  final double bmi;
  final Color catColor;
  final Color normalColor;
  final Color trackColor;

  const _RangeBar({
    required this.bmi,
    required this.catColor,
    required this.normalColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    const min = 14.0, max = 40.0;
    final pct = ((bmi - min) / (max - min)).clamp(0.0, 1.0);

    return LayoutBuilder(builder: (_, box) {
      final w = box.maxWidth;
      final normalStart = (18.5 - min) / (max - min);
      final normalEnd = (25.0 - min) / (max - min);
      final indX = (pct * w).clamp(0.0, w);

      return SizedBox(
        height: 16,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Track
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Normal band
            Positioned(
              left: normalStart * w,
              width: (normalEnd - normalStart) * w,
              top: 0, bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: normalColor.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Indicator
            Positioned(
              left: indX - 2,
              top: -3,
              child: Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
