import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double radius;
  final Color? tint;
  final int elevation;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = 20,
    this.radius = 20,
    this.tint,
    this.elevation = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkBgSurface : AppColors.bgSurface;
    final bg = tint ?? surface;

    final shadows = {
      0: <BoxShadow>[],
      1: [
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.40 : 0.04),
          blurRadius: 3, offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.30 : 0.06),
          blurRadius: 2, offset: const Offset(0, 1),
        ),
      ],
      2: [
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.40 : 0.05),
          blurRadius: 12, offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.30 : 0.04),
          blurRadius: 4, offset: const Offset(0, 2),
        ),
      ],
      3: [
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.50 : 0.08),
          blurRadius: 32, offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF0E1411).withOpacity(isDark ? 0.35 : 0.05),
          blurRadius: 12, offset: const Offset(0, 4),
        ),
      ],
    };

    final container = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows[elevation.clamp(0, 3)] ?? [],
      ),
      padding: padding > 0 ? EdgeInsets.all(padding) : EdgeInsets.zero,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}
