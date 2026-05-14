import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, dark, destructive, light }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  final String label;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool disabled;

  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.onPressed,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bg, fg, shadow) = switch (widget.variant) {
      AppButtonVariant.primary => (
          isDark ? AppColors.darkBrand500 : AppColors.brand500,
          Colors.white,
          [
            BoxShadow(
              color: AppColors.brand500.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.brand500.withOpacity(0.18),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      AppButtonVariant.secondary => (
          isDark ? AppColors.darkBgSunken : AppColors.bgSunken,
          isDark ? AppColors.darkFg1 : AppColors.fg1,
          <BoxShadow>[],
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          isDark ? AppColors.darkBrand500 : AppColors.brand500,
          <BoxShadow>[],
        ),
      AppButtonVariant.dark => (
          AppColors.fg1,
          Colors.white,
          <BoxShadow>[],
        ),
      AppButtonVariant.destructive => (
          AppColors.bmiObeseTint,
          AppColors.bmiObeseInk,
          <BoxShadow>[],
        ),
      AppButtonVariant.light => (
          Colors.white.withOpacity(0.18),
          Colors.white,
          <BoxShadow>[],
        ),
    };

    final (vPad, hPad, fontSize, radius) = switch (widget.size) {
      AppButtonSize.sm  => (9.0, 14.0, 13.0, 10.0),
      AppButtonSize.md  => (14.0, 22.0, 15.0, 14.0),
      AppButtonSize.lg  => (17.0, 28.0, 17.0, 16.0),
    };

    final iconSize = widget.size == AppButtonSize.lg ? 20.0 : 18.0;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.disabled ? null : (_) => _controller.forward(),
        onTapUp: widget.disabled ? null : (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.disabled ? null : widget.onPressed,
        child: Opacity(
          opacity: widget.disabled ? 0.4 : 1,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: iconSize, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    letterSpacing: -0.005 * fontSize,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
