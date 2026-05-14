import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SegmentedOption<T> {
  final T value;
  final String label;
  const SegmentedOption({required this.value, required this.label});
}

class AppSegmentedControl<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool small;

  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;
    final surface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final fg1 = isDark ? AppColors.darkFg1 : AppColors.fg1;
    final fg2 = isDark ? AppColors.darkFg2 : AppColors.fg2;
    final pad = small ? 3.0 : 4.0;
    final fontSize = small ? 12.0 : 13.0;
    final segPadV = small ? 6.0 : 8.0;
    final segPadH = small ? 12.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: sunken,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final on = opt.value == value;
          return GestureDetector(
            onTap: () => onChanged(opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(vertical: segPadV, horizontal: segPadH),
              decoration: BoxDecoration(
                color: on ? surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0E1411).withOpacity(0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                        BoxShadow(
                          color: const Color(0xFF0E1411).withOpacity(0.06),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                opt.label,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: on ? fg1 : fg2,
                  height: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
