import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';
import 'package:bmi_health/shared/theme/text_tracking.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool large;

  const ScreenHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 6, 20, large ? 8 : 12),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              title,
              textAlign: (leading != null || trailing != null) && !large
                  ? TextAlign.center
                  : TextAlign.start, // right-aligned in Urdu
              style: GoogleFonts.inter(
                fontSize: large ? 28 : 17,
                fontWeight: large ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: tracking(context, -0.015 * (large ? 28 : 17)),
                color: fg1,
                height: large ? 1.2 : 1.2,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
