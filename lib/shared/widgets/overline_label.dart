import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';

class OverlineLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const OverlineLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg3 = isDark ? AppColors.darkFg3 : AppColors.fg3;
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: tracking(context, 0.08 * 11),
        color: color ?? fg3,
        height: 1,
      ),
    );
  }
}
