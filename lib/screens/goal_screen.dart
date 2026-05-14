import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/overline_label.dart';
import '../widgets/segmented_control.dart';

class GoalScreen extends StatefulWidget {
  final double currentWeight;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const GoalScreen({
    super.key,
    required this.currentWeight,
    required this.onStart,
    required this.onClose,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  double _target = 70;
  int _weeks = 8;

  @override
  void initState() {
    super.initState();
    _target = widget.currentWeight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    final diff = widget.currentWeight - _target;
    final direction = diff.abs() < 0.05
        ? 'maintain'
        : diff > 0
            ? 'lose'
            : 'gain';
    final perWeek = _weeks > 0 ? diff.abs() / _weeks : 0.0;
    final safe = perWeek <= 1.0;
    final targetDate = DateTime.now().add(Duration(days: _weeks * 7));
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final targetDateStr =
        '${targetDate.day} ${months[targetDate.month]} ${targetDate.year}';

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
                      onTap: widget.onClose,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSurface
                              : AppColors.bgSunken,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.chevron_left_rounded,
                            size: 22, color: fg1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Set a goal',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w600,
                          color: fg1, letterSpacing: -0.015 * 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current vs target hero
                  AppCard(
                    padding: 20,
                    tint: bgTint,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const OverlineLabel('Current'),
                              const SizedBox(height: 4),
                              Text(
                                widget.currentWeight.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  fontSize: 28, fontWeight: FontWeight.w700,
                                  letterSpacing: -0.025 * 28, color: fg1,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              Text('kg', style: GoogleFonts.inter(
                                  fontSize: 12, color: fg3)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded,
                            size: 20, color: brand),
                        Expanded(
                          child: Column(
                            children: [
                              OverlineLabel('Target', color: brand),
                              const SizedBox(height: 4),
                              Text(
                                _target.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  fontSize: 28, fontWeight: FontWeight.w700,
                                  letterSpacing: -0.025 * 28, color: fg1,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              Text('kg', style: GoogleFonts.inter(
                                  fontSize: 12, color: fg3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Target slider
                  AppCard(
                    padding: 18,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const OverlineLabel('Target weight'),
                            Text(
                              '${_target.toStringAsFixed(1)} kg',
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500,
                                color: fg3,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            min: 40, max: 150, divisions: 220,
                            value: _target,
                            onChanged: (v) => setState(() => _target = v),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('40 kg',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: fg3)),
                            Text('150 kg',
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: fg3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Timeline
                  AppCard(
                    padding: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OverlineLabel('Timeline'),
                        const SizedBox(height: 12),
                        AppSegmentedControl<int>(
                          options: const [
                            SegmentedOption(value: 4, label: '4 weeks'),
                            SegmentedOption(value: 8, label: '8 weeks'),
                            SegmentedOption(value: 12, label: '12 weeks'),
                            SegmentedOption(value: 24, label: '24 weeks'),
                          ],
                          value: _weeks,
                          onChanged: (v) => setState(() => _weeks = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Plan preview
                  AppCard(
                    padding: 20,
                    elevation: 2,
                    tint: safe
                        ? (isDark ? AppColors.darkBgSurface : AppColors.bgSurface)
                        : (isDark ? AppColors.bmiOverTintDark : AppColors.bmiOverTint),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OverlineLabel('Your plan'),
                        const SizedBox(height: 6),
                        if (direction == 'maintain')
                          Text(
                            'Maintain your current weight',
                            style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.w600,
                              letterSpacing: -0.015 * 20,
                              color: fg1, height: 1.3,
                            ),
                          )
                        else
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.w600,
                                letterSpacing: -0.015 * 20,
                                color: fg1, height: 1.3,
                              ),
                              children: [
                                TextSpan(
                                    text: direction == 'lose' ? 'Lose ' : 'Gain '),
                                TextSpan(
                                  text:
                                      '${diff.abs().toStringAsFixed(1)} kg',
                                  style: TextStyle(color: brand),
                                ),
                                TextSpan(text: ' in $_weeks weeks'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w400,
                              color: fg2, height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: "That's "),
                              TextSpan(
                                text: '${perWeek.toStringAsFixed(2)} kg / week',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, color: fg1,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              TextSpan(
                                text: safe
                                    ? ' — a safe, sustainable pace.'
                                    : ' — faster than recommended. Try a longer timeline.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('REACH BY',
                                      style: GoogleFonts.inter(
                                        fontSize: 11, color: fg3,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.06 * 11,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(
                                    targetDateStr,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: fg1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DAILY CALORIES',
                                      style: GoogleFonts.inter(
                                        fontSize: 11, color: fg3,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.06 * 11,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${direction == 'lose' ? '−' : direction == 'gain' ? '+' : '±'}${(perWeek * 1100).round()} kcal',
                                    style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w600,
                                      color: fg1,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    label: 'Start tracking goal',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.lg,
                    icon: Icons.track_changes_rounded,
                    fullWidth: true,
                    onPressed: () async {
                      final goal = Goal(
                        currentWeight: widget.currentWeight,
                        targetWeight: _target,
                        weeks: _weeks,
                        startDate: DateTime.now(),
                      );
                      await context.read<AppProvider>().saveGoal(goal);
                      widget.onStart();
                    },
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
