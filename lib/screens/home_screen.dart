import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/overline_label.dart';
import '../widgets/screen_header.dart';
import '../widgets/segmented_control.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onCalculate;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.onCalculate,
    required this.onOpenSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().profile;
    _heightCtrl = TextEditingController(text: p.height.toStringAsFixed(1));
    _weightCtrl = TextEditingController(text: p.weight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _syncToProvider() {
    final provider = context.read<AppProvider>();
    final h = double.tryParse(_heightCtrl.text) ?? provider.profile.height;
    final w = double.tryParse(_weightCtrl.text) ?? provider.profile.weight;
    provider.updateProfile(provider.profile.copyWith(height: h, weight: w));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final bgTint = isDark ? AppColors.darkBgTint : AppColors.bgTint;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final last = provider.lastEntry;

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ScreenHeader(
                    title: 'BMI Calculator',
                    large: true,
                    trailing: IconButton(
                      icon: Icon(Icons.person_outline_rounded,
                          color: brand, size: 22),
                      onPressed: widget.onOpenSettings,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      'Enter your measurements to see your BMI and a tailored recommendation.',
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w400,
                        color: fg2, height: 1.5,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Height card
                      AppCard(
                        padding: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const OverlineLabel('Height'),
                                AppSegmentedControl<String>(
                                  small: true,
                                  options: const [
                                    SegmentedOption(value: 'cm', label: 'cm'),
                                    SegmentedOption(value: 'ft', label: 'ft / in'),
                                  ],
                                  value: profile.heightUnit,
                                  onChanged: (v) {
                                    provider.updateProfile(
                                        profile.copyWith(heightUnit: v));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _NumberField(
                              controller: _heightCtrl,
                              unit: profile.heightUnit == 'cm' ? 'cm' : 'ft',
                              hint: profile.heightUnit == 'cm' ? '172' : '5.10',
                              onChanged: (_) => _syncToProvider(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Weight card
                      AppCard(
                        padding: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const OverlineLabel('Weight'),
                                AppSegmentedControl<String>(
                                  small: true,
                                  options: const [
                                    SegmentedOption(value: 'kg', label: 'kg'),
                                    SegmentedOption(value: 'lbs', label: 'lbs'),
                                  ],
                                  value: profile.weightUnit,
                                  onChanged: (v) {
                                    provider.updateProfile(
                                        profile.copyWith(weightUnit: v));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _NumberField(
                              controller: _weightCtrl,
                              unit: profile.weightUnit,
                              hint: profile.weightUnit == 'kg' ? '70.0' : '154',
                              onChanged: (_) => _syncToProvider(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Age + Gender card
                      AppCard(
                        padding: 18,
                        child: Column(
                          children: [
                            // Age
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const OverlineLabel('Age'),
                                Row(
                                  children: [
                                    Text(
                                      '${profile.age}',
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: fg1,
                                        letterSpacing: -0.02 * 22,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'yrs',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: fg3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                min: 14, max: 90,
                                value: profile.age.toDouble(),
                                onChanged: (v) => provider.updateProfile(
                                    profile.copyWith(age: v.round())),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Gender
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const OverlineLabel('Gender'),
                                AppSegmentedControl<String>(
                                  small: true,
                                  options: const [
                                    SegmentedOption(value: 'f', label: 'Female'),
                                    SegmentedOption(value: 'm', label: 'Male'),
                                    SegmentedOption(value: 'o', label: 'Other'),
                                  ],
                                  value: profile.gender,
                                  onChanged: (v) => provider.updateProfile(
                                      profile.copyWith(gender: v)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Calculate button
                      AppButton(
                        label: 'Calculate BMI',
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.lg,
                        icon: Icons.calculate_outlined,
                        fullWidth: true,
                        onPressed: widget.onCalculate,
                      ),

                      // Last result chip
                      if (last != null) ...[
                        const SizedBox(height: 14),
                        AppCard(
                          tint: bgTint,
                          padding: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBgSurface
                                      : AppColors.bgSurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.history_rounded,
                                    size: 20, color: brand),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last result · ${_fmtDate(last.date)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13, fontWeight: FontWeight.w500,
                                        color: fg3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'BMI ${last.bmi.toStringAsFixed(1)} · ',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: fg1,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                        Text(
                                          BmiCalculator.category(last.bmi).label,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: BmiCalculator.category(last.bmi).color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: fg3),
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

  String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month]}';
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String unit;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _NumberField({
    required this.controller,
    required this.unit,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final surface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final borderSubtle = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;

    return Focus(
      child: Builder(builder: (ctx) {
        final focused = Focus.of(ctx).hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? brand : borderSubtle,
              width: focused ? 1.5 : 1,
            ),
            boxShadow: focused
                ? [BoxShadow(color: brand.withOpacity(0.18), blurRadius: 8)]
                : [
                    BoxShadow(
                      color: const Color(0xFF0E1411).withOpacity(0.04),
                      blurRadius: 3, offset: const Offset(0, 1),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: onChanged,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: fg1,
                    letterSpacing: -0.01 * 17,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: fg3,
                    ),
                  ),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: fg3,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
