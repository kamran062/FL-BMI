import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/bmi_calculator.dart';

enum PillSize { sm, md, lg }

class StatusPill extends StatelessWidget {
  final BmiCategory category;
  final bool solid;
  final PillSize size;

  const StatusPill({
    super.key,
    required this.category,
    this.solid = false,
    this.size = PillSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = solid
        ? category.color
        : (isDark ? category.tintDark : category.tint);
    final fg = solid
        ? Colors.white
        : (isDark ? category.inkDark : category.ink);
    final dotColor = solid ? Colors.white : category.color;

    final (padV, padH, fontSize) = switch (size) {
      PillSize.sm => (4.0, 10.0, 10.0),
      PillSize.md => (6.0, 12.0, 12.0),
      PillSize.lg => (8.0, 16.0, 13.0),
    };

    return Container(
      padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.3,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
