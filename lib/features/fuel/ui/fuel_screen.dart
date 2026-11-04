import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:bmi_health/features/fuel/domain/nutrition.dart';
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
                CaloriesCard(eaten: fuel.kcal, target: t.calories),
                const SizedBox(height: 14),
                AppCard(
                  padding: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MacroRow(
                          label: l.macroProtein,
                          eaten: fuel.proteinG.round(),
                          target: t.proteinG,
                          color: brand),
                      _MacroRow(label: l.macroCarbs, target: t.carbsG,
                          color: AppColors.bmiOver),
                      _MacroRow(label: l.macroFat, target: t.fatG,
                          color: AppColors.bmiUnder),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                WaterCard(drunk: fuel.waterMl, goal: t.waterMl),
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
                if (fuel.food.isEmpty)
                  Text(l.foodEmpty,
                      style: GoogleFonts.inter(fontSize: 14, color: fg3, height: 1.5))
                else
                  AppCard(
                    padding: 4,
                    child: Column(children: [
                      for (final f in fuel.food.reversed)
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
                            title: Text(f.name.isEmpty ? l.foodUnnamed : f.name),
                            subtitle: Text(
                                DateFormat.jm(l.localeName).format(f.date)),
                            trailing: Text('${f.kcal} kcal',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ]),
                  ),
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

  const WaterCard({super.key, required this.drunk, required this.goal});

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
                  onPressed: drunk > 0 ? () => fuel.addWater(-250) : null,
                  child: Text(l.removeGlass),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: water),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    fuel.addWater(250);
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
  final int? eaten; // only protein is tracked per entry
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

class _LogFoodDialog extends StatefulWidget {
  const _LogFoodDialog();

  @override
  State<_LogFoodDialog> createState() => _LogFoodDialogState();
}

class _LogFoodDialogState extends State<_LogFoodDialog> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final kcal = int.tryParse(_kcal.text.trim());
    if (kcal == null || kcal < 1 || kcal > 5000) {
      setState(() => _error = context.l10n.foodKcalError);
      return;
    }
    final fuel = context.read<FuelProvider>();
    Navigator.pop(context);
    await fuel.addFood(
      kcal: kcal,
      name: _name.text,
      proteinG: double.tryParse(_protein.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.logFood),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.foodName, counterText: ''),
          ),
          TextField(
            controller: _kcal,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.foodKcal, errorText: _error),
          ),
          TextField(
            controller: _protein,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: InputDecoration(labelText: l.foodProtein),
            onSubmitted: (_) => _save(),
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
