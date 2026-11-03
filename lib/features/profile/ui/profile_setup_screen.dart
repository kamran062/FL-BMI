import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';
import 'package:bmi_health/shared/widgets/app_button.dart';
import 'package:bmi_health/shared/widgets/segmented_control.dart';

enum ProfileSetupMode {
  /// After onboarding (new users) or once after upgrading (existing users).
  firstRun,

  /// From Settings → Personal details, prefilled with the current answers.
  edit,
}

/// Step-by-step profile questions (ROADMAP Phase 1.1).
class ProfileSetupScreen extends StatefulWidget {
  final ProfileSetupMode mode;

  /// Called after the profile has been saved.
  final VoidCallback onDone;

  /// "Later" in first-run mode; "close" in edit mode.
  final VoidCallback onDismiss;

  const ProfileSetupScreen({
    super.key,
    required this.mode,
    required this.onDone,
    required this.onDismiss,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _stepCount = 7;
  static const _bodyStepIndex = 2;

  late UserProfile _draft;
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  int _step = 0;
  bool _saving = false;

  bool get _editing => widget.mode == ProfileSetupMode.edit;
  bool get _isLast => _step == _stepCount - 1;

  @override
  void initState() {
    super.initState();
    _draft = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: _draft.name);
    _height = TextEditingController(text: _fmt(_draft.height));
    _weight = TextEditingController(text: _fmt(_draft.weight));
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// Whether the current step has an answer. Goal, experience and equipment
  /// drive the training plans, so they are required.
  bool get _canContinue => switch (_step) {
        3 => _draft.goal != null,
        4 => _draft.experience != null,
        5 => _draft.equipment != null,
        _ => true,
      };

  void _update(UserProfile next) => setState(() => _draft = next);

  /// Applies the body fields; returns false (and shows why) if invalid.
  bool _commitBody() {
    final l = context.l10n;
    final h = double.tryParse(_height.text.trim());
    final w = double.tryParse(_weight.text.trim());
    if (h == null || w == null) {
      _showError(l.errorEnterHeightWeight);
      return false;
    }
    final next = _draft.copyWith(height: h, weight: w);
    final error = BmiCalculator.validate(
        heightCm: next.heightInCm, weightKg: next.weightInKg);
    if (error != null) {
      _showError(l.bmiInputError(error));
      return false;
    }
    _draft = next;
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.inter(fontSize: 14)),
      backgroundColor: AppColors.fg1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (_step == 0) _draft = _draft.copyWith(name: _name.text.trim());
    if (_step == _bodyStepIndex && !_commitBody()) return;
    if (!_isLast) {
      setState(() => _step++);
      return;
    }
    setState(() => _saving = true);
    await context
        .read<ProfileProvider>()
        .update(_draft.copyWith(completed: true));
    if (mounted) widget.onDone();
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCanvas = isDark ? AppColors.darkBgCanvas : AppColors.bgCanvas;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;

    return PopScope(
      // System back walks back through the steps before leaving.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: bgCanvas,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header: progress + Later/close ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: Row(
                  children: [
                    Text(
                      _editing
                          ? l.personalDetails
                          : l.stepOf(_step + 1, _stepCount),
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600, color: fg3,
                      ),
                    ),
                    const Spacer(),
                    if (_editing)
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: widget.onDismiss,
                      )
                    else
                      TextButton(
                        onPressed: widget.onDismiss,
                        child: Text(l.later,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, color: brand)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _stepCount,
                    minHeight: 4,
                    color: brand,
                    backgroundColor: sunken,
                  ),
                ),
              ),

              // ── Current step ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(l),
                    ),
                  ),
                ),
              ),

              // ── Back / Continue ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        child: AppButton(
                          label: l.back,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.lg,
                          fullWidth: true,
                          onPressed: _back,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: _isLast
                            ? (_editing ? l.save : l.finish)
                            : l.continueLabel,
                        size: AppButtonSize.lg,
                        fullWidth: true,
                        disabled: !_canContinue || _saving,
                        onPressed: _canContinue && !_saving ? _next : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l) => switch (_step) {
        0 => _nameStep(l),
        1 => _genderStep(l),
        2 => _bodyStep(l),
        3 => _choiceStep<FitnessGoal>(
            title: l.setupGoalTitle,
            values: FitnessGoal.values,
            selected: _draft.goal,
            label: l.fitnessGoal,
            body: l.fitnessGoalBody,
            icon: (g) => switch (g) {
              FitnessGoal.loseFat => Icons.local_fire_department_outlined,
              FitnessGoal.buildMuscle => Icons.fitness_center_rounded,
              FitnessGoal.getStronger => Icons.trending_up_rounded,
              FitnessGoal.stayFit => Icons.favorite_border_rounded,
            },
            onSelect: (g) => _update(_draft.copyWith(goal: g)),
          ),
        4 => _choiceStep<Experience>(
            title: l.setupExperienceTitle,
            values: Experience.values,
            selected: _draft.experience,
            label: l.experience,
            body: l.experienceBody,
            icon: (e) => switch (e) {
              Experience.beginner => Icons.spa_outlined,
              Experience.intermediate => Icons.directions_run_rounded,
              Experience.advanced => Icons.emoji_events_outlined,
            },
            onSelect: (e) => _update(_draft.copyWith(experience: e)),
          ),
        5 => _choiceStep<Equipment>(
            title: l.setupEquipmentTitle,
            values: Equipment.values,
            selected: _draft.equipment,
            label: l.equipment,
            body: l.equipmentBody,
            icon: (e) => switch (e) {
              Equipment.gym => Icons.fitness_center_rounded,
              Equipment.home => Icons.home_outlined,
              Equipment.none => Icons.accessibility_new_rounded,
            },
            onSelect: (e) => _update(_draft.copyWith(equipment: e)),
          ),
        _ => _daysStep(l),
      };

  // ── Steps ───────────────────────────────────────────────────────────────

  Widget _nameStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(l.setupNameTitle),
          if (!_editing) _StepBody(l.setupIntro),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: 40,
            onSubmitted: (_) => _next(),
            decoration: InputDecoration(
              hintText: l.setupNameHint,
              counterText: '',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );

  Widget _genderStep(AppLocalizations l) {
    final other = _draft.gender == 'o';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l.setupGenderTitle),
        _StepBody(l.setupGenderBody),
        const SizedBox(height: 20),
        for (final code in const ['f', 'm', 'o'])
          _OptionCard(
            title: l.gender(code),
            selected: _draft.gender == code,
            onTap: () => _update(_draft.copyWith(gender: code)),
          ),
        if (other) ...[
          const SizedBox(height: 20),
          _SectionTitle(l.setupFormulaTitle),
          _StepBody(l.setupFormulaBody),
          const SizedBox(height: 10),
          for (final sex in Sex.values)
            _OptionCard(
              title: l.formulaBody(sex),
              selected: _draft.formulaBasis == sex,
              onTap: () => _update(_draft.copyWith(formulaBasis: sex)),
            ),
        ],
        // Everyone can choose in the editor; during first run only "Other"
        // is asked, since the profile already decides for male/female.
        if (other || _editing) ...[
          const SizedBox(height: 20),
          _SectionTitle(l.setupDemonstratorTitle),
          const SizedBox(height: 10),
          for (final pref in DemonstratorPref.values)
            _OptionCard(
              title: l.demonstrator(pref),
              selected: _draft.demonstratorPref == pref,
              onTap: () => _update(_draft.copyWith(demonstratorPref: pref)),
            ),
        ],
      ],
    );
  }

  Widget _bodyStep(AppLocalizations l) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l.setupBodyTitle),
        const SizedBox(height: 20),
        Row(
          children: [
            _SectionTitle(l.fieldAge),
            const Spacer(),
            Text('${_draft.age} ${l.yearsShort}',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700, color: fg1)),
          ],
        ),
        Slider(
          min: 14, max: 90,
          value: _draft.age.toDouble().clamp(14, 90),
          activeColor: brand,
          onChanged: (v) => _update(_draft.copyWith(age: v.round())),
        ),
        const SizedBox(height: 12),
        _MeasureField(
          label: l.fieldHeight,
          controller: _height,
          unitLabel: _draft.heightUnit == 'cm' ? 'cm' : 'in',
          units: const [
            SegmentedOption(value: 'cm', label: 'cm'),
            SegmentedOption(value: 'ft', label: 'in'),
          ],
          unit: _draft.heightUnit,
          onUnitChanged: (u) {
            if (u == _draft.heightUnit) return;
            final h = double.tryParse(_height.text) ?? _draft.height;
            final cm = _draft.copyWith(height: h).heightInCm;
            final next = u == 'ft' ? (cm / 2.54).roundToDouble() : cm.roundToDouble();
            _height.text = _fmt(next);
            _update(_draft.copyWith(heightUnit: u, height: next));
          },
        ),
        const SizedBox(height: 16),
        _MeasureField(
          label: l.fieldWeight,
          controller: _weight,
          unitLabel: _draft.weightUnit,
          units: const [
            SegmentedOption(value: 'kg', label: 'kg'),
            SegmentedOption(value: 'lbs', label: 'lbs'),
          ],
          unit: _draft.weightUnit,
          onUnitChanged: (u) {
            if (u == _draft.weightUnit) return;
            final w = double.tryParse(_weight.text) ?? _draft.weight;
            final next = u == 'lbs' ? w * 2.20462 : w * 0.453592;
            final rounded = double.parse(next.toStringAsFixed(1));
            _weight.text = _fmt(rounded);
            _update(_draft.copyWith(weightUnit: u, weight: rounded));
          },
        ),
      ],
    );
  }

  Widget _choiceStep<T>({
    required String title,
    required List<T> values,
    required T? selected,
    required String Function(T) label,
    required String Function(T) body,
    required IconData Function(T) icon,
    required ValueChanged<T> onSelect,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(title),
          const SizedBox(height: 20),
          for (final v in values)
            _OptionCard(
              icon: icon(v),
              title: label(v),
              subtitle: body(v),
              selected: selected == v,
              onTap: () => onSelect(v),
            ),
        ],
      );

  Widget _daysStep(AppLocalizations l) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepTitle(l.setupDaysTitle),
        const SizedBox(height: 20),
        AppSegmentedControl<int>(
          options: [
            for (var d = UserProfile.minDaysPerWeek;
                d <= UserProfile.maxDaysPerWeek;
                d++)
              SegmentedOption(value: d, label: '$d'),
          ],
          value: _draft.daysPerWeek,
          onChanged: (d) => _update(_draft.copyWith(daysPerWeek: d)),
        ),
        const SizedBox(height: 16),
        Text(
          l.daysPerWeek(_draft.daysPerWeek),
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w700, color: brand),
        ),
        const SizedBox(height: 6),
        _StepBody(l.setupDaysTip),
      ],
    );
  }
}

// ── Building blocks ─────────────────────────────────────────────────────────

class _StepTitle extends StatelessWidget {
  final String text;
  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: tracking(context, -0.02 * 24),
        color: isDark ? AppColors.darkFg1 : AppColors.fg1,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkFg1 : AppColors.fg1,
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  final String text;
  const _StepBody(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: isDark ? AppColors.darkFg2 : AppColors.fg2,
        ),
      ),
    );
  }
}

/// A selectable answer: card with optional icon and description.
class _OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkBrand500 : AppColors.brand500;
    final surface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final border = isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? brand.withAlpha(22) : surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? brand : border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: selected ? brand : fg2, size: 24),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: fg1)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: GoogleFonts.inter(
                                fontSize: 13, height: 1.4, color: fg2)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? brand : border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Number field with a unit switch (height or weight).
class _MeasureField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unitLabel;
  final List<SegmentedOption<String>> units;
  final String unit;
  final ValueChanged<String> onUnitChanged;

  const _MeasureField({
    required this.label,
    required this.controller,
    required this.unitLabel,
    required this.units,
    required this.unit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle(label),
            const Spacer(),
            AppSegmentedControl<String>(
              small: true,
              options: units,
              value: unit,
              onChanged: onUnitChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: InputDecoration(
            suffixText: unitLabel,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
