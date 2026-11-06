import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bmi_health/features/train/exercises/demo/demo_library.dart';
import 'package:bmi_health/features/train/exercises/demo/demo_pose.dart';
import 'package:bmi_health/features/train/exercises/demo/human_figure.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Looping animated person showing how to do [exercise]. Shows a still pose
/// when the system asks for reduced motion.
class ExerciseDemo extends StatefulWidget {
  final Exercise exercise;
  final bool female;
  const ExerciseDemo({super.key, required this.exercise, this.female = false});

  static bool has(Exercise e) => DemoLibrary.motionFor(e.id) != null;

  /// Tests turn this off so `pumpAndSettle` isn't kept busy by the loop.
  static bool loop = true;

  @override
  State<ExerciseDemo> createState() => _ExerciseDemoState();
}

class _ExerciseDemoState extends State<ExerciseDemo> with SingleTickerProviderStateMixin {
  late DemoMotion? _motion;
  late DemoFrame _frame;
  late final AnimationController _c = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  @override
  void didUpdateWidget(ExerciseDemo old) {
    super.didUpdateWidget(old);
    if (old.exercise.id != widget.exercise.id) _setUp();
  }

  void _setUp() {
    _motion = DemoLibrary.motionFor(widget.exercise.id);
    final m = _motion;
    if (m == null) return;
    _frame = DemoFrame.of(m);
    _c.duration = m.cycle;
    if (ExerciseDemo.loop) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _motion;
    if (m == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final colors = DemoColors(
      dark: isDark,
      accent: isDark ? AppColors.darkBrand500 : AppColors.brand500,
      prop: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
    );
    final e = widget.exercise;
    return Semantics(
      image: true,
      label: e.name['en'],
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: DemoPainter(
              motion: m,
              frame: _frame,
              // Still: the working position (second key pose)
              t: still ? (m.frames.length > 1 ? 1 / m.frames.length : 0) : _c.value,
              equipment: e.equipment,
              primary: e.primary,
              female: widget.female,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}

class DemoColors {
  final bool dark;
  final Color accent, prop;
  const DemoColors({required this.dark, required this.accent, required this.prop});
}

/// Fixed framing for a motion: bounds over the whole cycle (so the figure
/// doesn't jump around) and the floor line.
class DemoFrame {
  final Rect bounds;
  final double? floorY;
  final double shadowX;
  const DemoFrame(this.bounds, this.floorY, this.shadowX);

  factory DemoFrame.of(DemoMotion m) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    var lowest = -double.infinity;
    var sumX = 0.0;
    var n = 0;
    void add(Offset p, [double r = 0]) {
      minX = math.min(minX, p.dx - r);
      maxX = math.max(maxX, p.dx + r);
      minY = math.min(minY, p.dy - r);
      maxY = math.max(maxY, p.dy + r);
    }

    for (var i = 0; i < 48; i++) {
      final s = buildSkeleton(m.poseAt(i / 48), m.view, m.anchor);
      // How far the body surface reaches below each joint
      final reach = <(Offset, double)>[
        (s.head, HumanFigure.headH),
        (s.neck, 0.06),
        (s.pelvis, 0.075),
        for (final p in s.shoulder) (p, 0.05),
        for (final p in s.elbow) (p, 0.035),
        for (final p in s.hand) (p, 0.03),
        for (final p in s.hip) (p, 0.075),
        for (final p in s.knee) (p, 0.045),
        for (final p in s.ankle) (p, 0.035),
        for (final p in s.toe) (p, 0.03),
      ];
      for (final (p, r) in reach) {
        add(p, r + 0.02);
        if (p.dy + r > lowest) lowest = p.dy + r;
      }
      for (final p in [...s.ankle, ...s.toe]) {
        sumX += p.dx;
        n++;
      }
    }
    for (final p in m.props) {
      add(p.a, 0.03);
      add(p.b, 0.03);
      // Furniture stands on the floor too
      lowest = math.max(lowest, math.max(p.a.dy, p.b.dy));
    }
    final cable = m.cable;
    if (cable != null) add(cable, 0.05);
    final floorY = m.floor ? lowest + 0.004 : null;
    if (floorY != null) add(Offset(minX, floorY + 0.02));
    // Never frame tighter than a standing figure, so small moves stay small.
    final w = math.max(maxX - minX, 0.55), h = math.max(maxY - minY, 0.55);
    final c = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    return DemoFrame(Rect.fromCenter(center: c, width: w * 1.1, height: h * 1.08), floorY, sumX / n);
  }
}

class DemoPainter extends CustomPainter {
  final DemoMotion motion;
  final DemoFrame frame;
  final double t;
  final ExerciseEquipment equipment;
  final Muscle primary;
  final bool female;
  final DemoColors colors;

  DemoPainter({
    required this.motion,
    required this.frame,
    required this.t,
    required this.equipment,
    required this.primary,
    required this.female,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final b = frame.bounds;
    final scale = math.min(size.width / b.width, size.height / b.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-b.center.dx, -b.center.dy);

    final sk = buildSkeleton(motion.poseAt(t), motion.view, motion.anchor);
    final props = Scenery(colors.dark, colors.prop);

    for (final p in motion.props) {
      props.prop(canvas, p);
    }
    final floorY = frame.floorY;
    if (floorY != null) {
      props.floor(canvas, b, floorY);
      props.shadow(canvas, Offset(frame.shadowX, floorY), sk);
    }
    final cable = motion.cable;
    if (cable != null) {
      props.cable(canvas, sk.hand, cable, band: equipment == ExerciseEquipment.band, bandColor: colors.accent);
    }

    final gear = Gear(equipment, motion.gearAt, motion.view, colors.dark);
    HumanFigure(
      sk: sk,
      view: motion.view,
      female: female,
      working: primary,
      // Equipment held in the far hand goes behind the body
      behindBody: (canvas) => gear.paint(canvas, sk, far: true),
      inFront: (canvas) => gear.paint(canvas, sk, far: false),
    ).paint(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DemoPainter old) =>
      old.t != t || old.motion != motion || old.colors.dark != colors.dark || old.female != female;
}
