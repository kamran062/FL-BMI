import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../utils/bmi_calculator.dart';

class BmiGauge extends StatefulWidget {
  final double value;
  final double size;

  const BmiGauge({super.key, required this.value, this.size = 240});

  @override
  State<BmiGauge> createState() => _BmiGaugeState();
}

class _BmiGaugeState extends State<BmiGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(BmiGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = BmiCalculator.category(widget.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sunken = isDark ? AppColors.darkBgSunken : AppColors.bgSunken;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _GaugePainter(
              bmi: widget.value,
              progress: _anim.value,
              trackColor: sunken,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.08 * 11,
                      color: cat.color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.03 * widget.size * 0.28,
                      color: isDark ? AppColors.darkFg1 : AppColors.fg1,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'kg/m²',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkFg3 : AppColors.fg3,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double bmi;
  final double progress;
  final Color trackColor;

  static const double _min = 14;
  static const double _max = 40;
  static const double _strokeW = 18;
  static const double _gap = 6;

  static const _buckets = [
    (14.0, 18.5, AppColors.bmiUnder),
    (18.5, 25.0, AppColors.bmiNormal),
    (25.0, 30.0, AppColors.bmiOver),
    (30.0, 40.0, AppColors.bmiObese),
  ];

  const _GaugePainter({
    required this.bmi,
    required this.progress,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - 36) / 2;
    final circumference = 2 * math.pi * r;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Track
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeW
        ..strokeCap = StrokeCap.round,
    );

    // Colored arcs
    for (final (from, to, color) in _buckets) {
      final startPct = (from - _min) / (_max - _min);
      final endPct = (to - _min) / (_max - _min);
      final len = (endPct - startPct) * circumference - _gap;
      if (len <= 0) continue;

      final startAngle = -math.pi / 2 + startPct * 2 * math.pi;
      final sweepAngle = (endPct - startPct) * 2 * math.pi * progress
          - (_gap / circumference) * 2 * math.pi;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle.clamp(0, 2 * math.pi),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    // Indicator dot
    final pct = ((bmi - _min) / (_max - _min)).clamp(0.0, 1.0);
    final angle = -math.pi / 2 + pct * 2 * math.pi;
    final ix = cx + r * math.cos(angle);
    final iy = cy + r * math.sin(angle);

    final cat = BmiCalculator.category(bmi);

    canvas.drawCircle(
      Offset(ix, iy), 9,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(ix, iy), 9,
      Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.bmi != bmi || old.progress != progress;
}
