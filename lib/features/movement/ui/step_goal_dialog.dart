import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Lets the user pick a daily step goal from common values.
Future<void> showStepGoalDialog(BuildContext context) async {
  final steps = context.read<StepsProvider>();
  final l = context.l10n;
  final fmt = NumberFormat.decimalPattern(l.localeName);
  final picked = await showDialog<int>(
    context: context,
    builder: (d) {
      final isDark = Theme.of(d).brightness == Brightness.dark;
      final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
      return AlertDialog(
        title: Text(l.stepsGoal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.stepsGoalHint, style: GoogleFonts.inter(fontSize: 14, color: fg3)),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final g in StepsProvider.goalChoices)
                ChoiceChip(
                  label: Text(fmt.format(g)),
                  selected: steps.goal == g,
                  onSelected: (_) => Navigator.pop(d, g),
                ),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d),
              child: Text(MaterialLocalizations.of(d).cancelButtonLabel)),
        ],
      );
    },
  );
  if (picked != null) await steps.setGoal(picked);
}
