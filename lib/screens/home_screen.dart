import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_card.dart';
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
    final fg1   = isDark ? AppColors.darkFg1   : AppColors.fg1;
    final fg2   = isDark ? AppColors.darkFg2   : AppColors.fg2;
    final fg3   = isDark ? AppColors.darkFg3   : AppColors.fg3;
    final bgCanvas  = isDark ? AppColors.darkBgCanvas  : AppColors.bgCanvas;
    final bgSurface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final brand     = isDark ? AppColors.darkBrand500  : AppColors.brand500;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final last    = provider.lastEntry;

        return Scaffold(
          backgroundColor: bgCanvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [

                // ── Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI Calculator',
                                style: GoogleFonts.inter(
                                  fontSize: 28, fontWeight: FontWeight.w700,
                                  letterSpacing: -0.03 * 28, color: fg1, height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Know your body. Track your health.',
                                style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w400,
                                  color: fg3, height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onOpenSettings,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: bgSurface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 8, offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.person_outline_rounded,
                                size: 20, color: brand),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Height + Weight (2-col) ──────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.height_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            iconTint: const Color(0xFFEAF1FE),
                            label: 'Height',
                            controller: _heightCtrl,
                            unit: profile.heightUnit == 'cm' ? 'cm' : 'in',
                            hint: profile.heightUnit == 'cm' ? '172' : '70',
                            onChanged: (_) => _syncToProvider(),
                            unitOptions: const [
                              SegmentedOption(value: 'cm', label: 'cm'),
                              SegmentedOption(value: 'ft', label: 'in'),
                            ],
                            unitValue: profile.heightUnit,
                            onUnitChanged: (v) {
                              if (v == profile.heightUnit) return;
                              final newH = v == 'ft'
                                  ? (profile.heightInCm / 2.54).roundToDouble()
                                  : profile.heightInCm.roundToDouble();
                              _heightCtrl.text = newH.toStringAsFixed(0);
                              provider.updateProfile(profile.copyWith(
                                  heightUnit: v, height: newH));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.monitor_weight_outlined,
                            iconColor: brand,
                            iconTint: isDark
                                ? AppColors.darkBrand500.withAlpha(35)
                                : AppColors.brand100,
                            label: 'Weight',
                            controller: _weightCtrl,
                            unit: profile.weightUnit,
                            hint: profile.weightUnit == 'kg' ? '70' : '154',
                            onChanged: (_) => _syncToProvider(),
                            unitOptions: const [
                              SegmentedOption(value: 'kg', label: 'kg'),
                              SegmentedOption(value: 'lbs', label: 'lbs'),
                            ],
                            unitValue: profile.weightUnit,
                            onUnitChanged: (v) {
                              if (v == profile.weightUnit) return;
                              final newW = v == 'lbs'
                                  ? (profile.weight * 2.20462).roundToDouble()
                                  : (profile.weight * 0.453592).roundToDouble();
                              _weightCtrl.text = newW.toStringAsFixed(0);
                              provider.updateProfile(profile.copyWith(
                                  weightUnit: v, weight: newW));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Age + Gender ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: AppCard(
                      padding: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Age row
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF4E2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.cake_outlined,
                                    size: 18, color: Color(0xFFF59E0B)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Age',
                                style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: fg2,
                                ),
                              ),
                              const Spacer(),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${profile.age}',
                                      style: GoogleFonts.inter(
                                        fontSize: 24, fontWeight: FontWeight.w700,
                                        color: fg1,
                                        letterSpacing: -0.02 * 24,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' yrs',
                                      style: GoogleFonts.inter(
                                        fontSize: 13, fontWeight: FontWeight.w500,
                                        color: fg3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Styled slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                  elevation: 3),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 18),
                              activeTrackColor: brand,
                              inactiveTrackColor: isDark
                                  ? AppColors.darkBgSunken
                                  : AppColors.bgSunken,
                              thumbColor: brand,
                              overlayColor: brand.withAlpha(30),
                            ),
                            child: Slider(
                              min: 14, max: 90,
                              value: profile.age.toDouble(),
                              onChanged: (v) => provider.updateProfile(
                                  profile.copyWith(age: v.round())),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('14', style: GoogleFonts.inter(
                                  fontSize: 11, color: fg3, fontWeight: FontWeight.w500)),
                              Text('90', style: GoogleFonts.inter(
                                  fontSize: 11, color: fg3, fontWeight: FontWeight.w500)),
                            ],
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1,
                                color: isDark
                                    ? AppColors.darkBorderFaint
                                    : AppColors.borderFaint),
                          ),

                          // Gender row
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EBFE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.people_outline_rounded,
                                    size: 18, color: Color(0xFF8B5CF6)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gender',
                                style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: fg2,
                                ),
                              ),
                              const Spacer(),
                              _GenderPills(
                                value: profile.gender,
                                onChanged: (v) => provider.updateProfile(
                                    profile.copyWith(gender: v)),
                                brand: brand,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Calculate button ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _GradientButton(
                      label: 'Calculate BMI',
                      icon: Icons.calculate_rounded,
                      onTap: widget.onCalculate,
                    ),
                  ),
                ),

                // ── Last result ──────────────────────────────────────
                if (last != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _LastResultCard(entry: last, isDark: isDark),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Two-column metric tile ─────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconTint;
  final String label;
  final TextEditingController controller;
  final String unit;
  final String hint;
  final ValueChanged<String>? onChanged;
  final List<SegmentedOption<String>> unitOptions;
  final String unitValue;
  final ValueChanged<String> onUnitChanged;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.iconTint,
    required this.label,
    required this.controller,
    required this.unit,
    required this.hint,
    required this.unitOptions,
    required this.unitValue,
    required this.onUnitChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;

    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + label
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: iconTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: fg2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Number field
          _NumberField(
            controller: controller,
            unit: unit,
            hint: hint,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // Unit segmented
          AppSegmentedControl<String>(
            options: unitOptions,
            value: unitValue,
            onChanged: onUnitChanged,
            small: true,
          ),
        ],
      ),
    );
  }
}

// ── Number field ───────────────────────────────────────────────────────────

class _NumberField extends StatefulWidget {
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
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand   = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1     = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg3     = isDark ? AppColors.darkFg3 : AppColors.fg3;
    final bgIdle  = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final bgFocus = isDark
        ? AppColors.darkBrand500.withAlpha(22)
        : AppColors.brand100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _focused ? bgFocus : bgIdle,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              onChanged: widget.onChanged,
              cursorColor: brand,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(2),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: fg1,
                letterSpacing: -0.025 * 22,
                fontFeatures: const [FontFeature.tabularFigures()],
                height: 1.15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg3.withAlpha(100),
                  letterSpacing: -0.025 * 22,
                  height: 1.15,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
            decoration: BoxDecoration(
              color: _focused ? brand.withAlpha(22) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.unit,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _focused ? brand : fg3,
                letterSpacing: 0.04,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gender pills ───────────────────────────────────────────────────────────

class _GenderPills extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Color brand;
  final bool isDark;

  const _GenderPills({
    required this.value,
    required this.onChanged,
    required this.brand,
    required this.isDark,
  });

  static const _options = [
    ('f', 'Female'),
    ('m', 'Male'),
    ('o', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    final bgSunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    return Row(
      children: _options.map((opt) {
        final selected = opt.$1 == value;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? brand : bgSunken,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              opt.$2,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : fg3,
                height: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Gradient calculate button ──────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c1 = isDark ? const Color(0xFF2BC480) : const Color(0xFF18A065);
    final c2 = isDark ? const Color(0xFF1FB573) : const Color(0xFF1FB573);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c1, c2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand500.withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.brand500.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.01 * 17,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Last result card ───────────────────────────────────────────────────────

class _LastResultCard extends StatelessWidget {
  final dynamic entry;
  final bool isDark;

  const _LastResultCard({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cat     = BmiCalculator.category(entry.bmi as double);
    final catTint = isDark ? cat.tintDark : cat.tint;
    final catInk  = isDark ? cat.inkDark  : cat.ink;
    final fg1   = isDark ? AppColors.darkFg1   : AppColors.fg1;
    final fg3   = isDark ? AppColors.darkFg3   : AppColors.fg3;
    final surface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;

    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = entry.date as DateTime;
    final dateStr = '${d.day} ${months[d.month]}';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 8),
            blurRadius: 12, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top accent bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cat.color.withAlpha(180), cat.color],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: catTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.history_rounded, size: 20, color: catInk),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last result · $dateStr',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: fg3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'BMI ${(entry.bmi as double).toStringAsFixed(1)}',
                              style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: fg1,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                letterSpacing: -0.01 * 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: catTint,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                cat.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                  color: catInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: fg3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
