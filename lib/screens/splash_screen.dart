import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Logo build sequence
  late Animation<double> _arcAnim;
  late Animation<double> _lineAnim;
  late Animation<double> _dotAnim;

  // Ambient glow that builds during drawing then settles
  late Animation<double> _glowAnim;

  // Subtle scale pop after logo is assembled
  late Animation<double> _popAnim;

  // Wordmark + tagline reveal
  late Animation<double> _wordmarkFade;
  late Animation<Offset> _wordmarkSlide;
  late Animation<double> _taglineFade;

  // Continuous heartbeat pulse after everything is in
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    // ── Main build controller — 2 400 ms ──────────────────────────────────────
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    Animation<double> interval(double begin, double end, Curve curve) =>
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _ctrl, curve: Interval(begin, end, curve: curve)),
        );

    _glowAnim     = interval(0.00, 0.42, Curves.easeOut);
    _arcAnim      = interval(0.05, 0.44, Curves.easeOut);
    _lineAnim     = interval(0.25, 0.50, Curves.easeOut);
    _dotAnim      = interval(0.44, 0.60, Curves.elasticOut);
    _popAnim      = interval(0.58, 0.72, Curves.easeOutBack);
    _wordmarkFade = interval(0.56, 0.74, Curves.easeOut);
    _taglineFade  = interval(0.68, 0.84, Curves.easeOut);

    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.56, 0.74, curve: Curves.easeOut),
    ));

    _ctrl.forward();

    // ── Heartbeat pulse — starts after logo is assembled ─────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.40, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Start continuous pulse once the logo is fully drawn (~1 450 ms in)
    Future.delayed(const Duration(milliseconds: 1450), () {
      if (mounted) _pulseCtrl.repeat(reverse: true);
    });

    // Hand off to the app
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFDDF3EA),
              Color(0xFFF2FAF5),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated logomark ────────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_ctrl, _pulseCtrl]),
                builder: (_, __) {
                  final popScale = 0.88 + 0.12 * _popAnim.value;

                  return SizedBox(
                    width: 240, height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [

                        // Pulsing glow ring (continuous after assembly)
                        if (_pulseCtrl.isAnimating || _pulseCtrl.value > 0)
                          Transform.scale(
                            scale: _pulseScale.value,
                            child: Opacity(
                              opacity: _pulseOpacity.value,
                              child: Container(
                                width: 220, height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.brand500.withValues(alpha: 0.35),
                                      AppColors.brand500.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Build-phase ambient glow
                        Opacity(
                          opacity: _glowAnim.value * (1 - _popAnim.value * 0.5),
                          child: Container(
                            width: 200, height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.brand500.withValues(alpha: 0.22),
                                  AppColors.brand500.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // White card with shadow — scales in with pop
                        Transform.scale(
                          scale: popScale,
                          child: Container(
                            width: 170, height: 170,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand500.withValues(alpha: 0.18 * _glowAnim.value),
                                  blurRadius: 40,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Animated logomark drawn by CustomPainter
                        Transform.scale(
                          scale: popScale,
                          child: CustomPaint(
                            size: const Size(170, 170),
                            painter: _LogomarkPainter(
                              arcProgress:  _arcAnim.value,
                              lineProgress: _lineAnim.value,
                              dotScale:     _dotAnim.value,
                              brandColor:   AppColors.brand500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // ── Logo wordmark + tagline ───────────────────────────────────
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => FadeTransition(
                  opacity: _wordmarkFade,
                  child: SlideTransition(
                    position: _wordmarkSlide,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'project/assets/logo.svg',
                          height: 34,
                        ),
                        const SizedBox(height: 10),
                        Opacity(
                          opacity: _taglineFade.value,
                          child: Text(
                            'Know Your Body. Improve Your Health.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.fg2,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Version
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Text(
                  'v 1.0',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                    color: AppColors.fg3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logomark painter ──────────────────────────────────────────────────────────
//
// Draws three elements sequentially as progress values go 0 → 1:
//   1. Arc   — large gauge arc (counterclockwise, matching the SVG path)
//   2. Line  — ECG / heartbeat polyline in the centre
//   3. Dot   — filled circle at the arc terminus
//
class _LogomarkPainter extends CustomPainter {
  final double arcProgress;
  final double lineProgress;
  final double dotScale;
  final Color brandColor;

  const _LogomarkPainter({
    required this.arcProgress,
    required this.lineProgress,
    required this.dotScale,
    required this.brandColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Scale all measurements from the 48×48 SVG viewBox
    final scale  = size.width / 48;
    final radius = 16 * scale;           // matches SVG radius
    final sw     = 4  * scale;           // arc stroke-width
    final lsw    = 2.5 * scale;          // heartbeat stroke-width

    // ── 1. Arc ────────────────────────────────────────────────────────────────
    // SVG: M 38 32 A 16 16 0 1 0 24 40
    //   start ≈ 30° from right, large arc, counterclockwise → end at 90° (bottom)
    const startAngle = 30.0 * (pi / 180);
    const sweepAngle = -300.0 * (pi / 180); // negative = counterclockwise

    if (arcProgress > 0) {
      final arcPaint = Paint()
        ..color      = brandColor
        ..style      = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap  = StrokeCap.round;

      final fullArc = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
        );

      final metrics = fullArc.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final partial = metrics.first
            .extractPath(0, metrics.first.length * arcProgress);
        canvas.drawPath(partial, arcPaint);
      }
    }

    // ── 2. Heartbeat / ECG line ───────────────────────────────────────────────
    // SVG: M 16 24 L 20 24 L 22 20 L 26 28 L 28 24 L 32 24
    if (lineProgress > 0) {
      final linePaint = Paint()
        ..color       = brandColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = lsw
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round;

      // All original SVG coords are in 48×48 space
      final pts = [
        Offset(16 * scale, 24 * scale),
        Offset(20 * scale, 24 * scale),
        Offset(22 * scale, 20 * scale),
        Offset(26 * scale, 28 * scale),
        Offset(28 * scale, 24 * scale),
        Offset(32 * scale, 24 * scale),
      ];

      final fullLine = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) { fullLine.lineTo(pts[i].dx, pts[i].dy); }

      final metrics = fullLine.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final partial = metrics.first
            .extractPath(0, metrics.first.length * lineProgress);
        canvas.drawPath(partial, linePaint);
      }
    }

    // ── 3. Dot at arc terminus ────────────────────────────────────────────────
    // SVG: <circle cx="24" cy="40" r="3.5" fill="#1FB573"/>
    // cx=24, cy=40 maps to Offset(24*scale, 40*scale)
    if (dotScale > 0) {
      final dotPaint = Paint()
        ..color = brandColor
        ..style = PaintingStyle.fill;

      final dotCenter = Offset(24 * scale, 40 * scale);
      final dotRadius = 3.5 * scale * dotScale;
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LogomarkPainter old) =>
      arcProgress  != old.arcProgress  ||
      lineProgress != old.lineProgress ||
      dotScale     != old.dotScale;
}
