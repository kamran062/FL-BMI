import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bmi_health/features/train/exercises/demo/demo_library.dart';
import 'package:bmi_health/features/train/exercises/demo/demo_pose.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/shared/theme/app_colors.dart';

/// Looping animated figure showing how to do [exercise]. Shows a still pose
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
      body: isDark ? AppColors.darkFg1 : AppColors.fg1,
      far: isDark ? AppColors.darkFg3 : AppColors.fg3,
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
  final Color body, far, accent, prop;
  const DemoColors({required this.body, required this.far, required this.accent, required this.prop});
}

/// Fixed framing for a motion: bounds over the whole cycle (so the figure
/// doesn't jump around) and the floor line.
class DemoFrame {
  final Rect bounds;
  final double? floorY;
  const DemoFrame(this.bounds, this.floorY);

  factory DemoFrame.of(DemoMotion m) {
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    var lowest = -double.infinity;
    void add(Offset p, [double r = 0]) {
      minX = math.min(minX, p.dx - r);
      maxX = math.max(maxX, p.dx + r);
      minY = math.min(minY, p.dy - r);
      maxY = math.max(maxY, p.dy + r);
    }

    for (var i = 0; i < 48; i++) {
      final s = buildSkeleton(m.poseAt(i / 48), m.view, m.anchor);
      for (final p in s.points) {
        add(p, 0.03);
        lowest = math.max(lowest, p.dy);
      }
      add(s.head, Body.headR + 0.02);
      lowest = math.max(lowest, s.head.dy + Body.headR * 0.4);
    }
    for (final p in m.props) {
      add(p.a, 0.02);
      add(p.b, 0.02);
    }
    final cable = m.cable;
    if (cable != null) add(cable, 0.04);
    final floorY = m.floor ? lowest + 0.03 : null;
    if (floorY != null) add(Offset(minX, floorY));
    // Never frame tighter than a standing figure, so small moves stay small.
    final w = math.max(maxX - minX, 0.5), h = math.max(maxY - minY, 0.5);
    final c = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    return DemoFrame(Rect.fromCenter(center: c, width: w * 1.15, height: h * 1.12), floorY);
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
    const w = 0.045;
    Paint stroke(Color c, [double width = w]) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scenery
    final propFill = Paint()..color = colors.prop;
    for (final p in motion.props) {
      if (p.isPad) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromPoints(p.a, p.b), const Radius.circular(0.015)),
            propFill);
      } else {
        canvas.drawLine(p.a, p.b, stroke(colors.prop, p.width));
      }
    }
    final floorY = frame.floorY;
    if (floorY != null) {
      canvas.drawLine(Offset(b.left + 0.02, floorY), Offset(b.right - 0.02, floorY),
          stroke(colors.prop, 0.018));
    }
    final cable = motion.cable;
    if (cable != null) {
      final band = equipment == ExerciseEquipment.band;
      final line = stroke(band ? colors.accent.withAlpha(150) : colors.far, band ? 0.02 : 0.008);
      for (final h in sk.hand) {
        canvas.drawLine(h, cable, line);
      }
      if (!band) canvas.drawCircle(cable, 0.025, Paint()..color = colors.prop);
    }

    // Which segments the exercise works
    final torsoHot = primary == Muscle.chest || primary == Muscle.back || primary == Muscle.core;
    final upperArmHot =
        primary == Muscle.shoulders || primary == Muscle.biceps || primary == Muscle.triceps;
    final forearmHot = primary == Muscle.biceps || primary == Muscle.triceps;
    final thighHot = primary == Muscle.quads || primary == Muscle.hamstrings || primary == Muscle.glutes;
    final shinHot = primary == Muscle.calves;

    void limbs(int s, Color base, Color hot) {
      final seg = [
        (sk.hip[s], sk.knee[s], thighHot),
        (sk.knee[s], sk.ankle[s], shinHot),
        (sk.ankle[s], sk.toe[s], false),
        (sk.shoulder[s], sk.elbow[s], upperArmHot),
        (sk.elbow[s], sk.hand[s], forearmHot),
      ];
      for (final (a, c, isHot) in seg) {
        canvas.drawLine(a, c, stroke(isHot ? hot : base));
      }
    }

    limbs(1, colors.far, Color.lerp(colors.far, colors.accent, 0.55)!);
    _gear(canvas, sk, far: true);

    // Torso, shoulders and hips (front view), head
    final torso = stroke(torsoHot ? colors.accent : colors.body, w * 1.5);
    canvas.drawLine(sk.pelvis, sk.neck, torso);
    if (motion.view == DemoView.front) {
      canvas.drawLine(sk.shoulder[0], sk.shoulder[1], stroke(colors.body));
      canvas.drawLine(sk.hip[0], sk.hip[1], stroke(colors.body));
    }
    canvas.drawLine(sk.neck, sk.head, stroke(colors.body, w * 0.8));
    final headPaint = Paint()..color = colors.body;
    canvas.drawCircle(sk.head, Body.headR, headPaint);
    if (female) {
      final s = sk.spine;
      if (motion.view == DemoView.side) {
        // Ponytail at the back of the head
        final back = Offset(-s.dy, s.dx) * -1;
        final tail = sk.head + back * (Body.headR * 1.05) - s * 0.01;
        canvas.drawLine(tail, tail + back * 0.03 - s * 0.06, stroke(colors.body, 0.03));
      } else {
        canvas.drawCircle(sk.head + s * (Body.headR * 0.9), 0.03, headPaint);
      }
    }

    limbs(0, colors.body, colors.accent);
    _gear(canvas, sk, far: false);
    canvas.restore();
  }

  void _gear(Canvas canvas, Skeleton sk, {required bool far}) {
    final s = far ? 1 : 0;
    final front = motion.view == DemoView.front;
    // Equipment in grey so it never reads as part of the body
    final color = far ? colors.far.withAlpha(150) : colors.far;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.025
      ..strokeCap = StrokeCap.round;
    final at = motion.gearAt;
    if (at == GearAt.none || (at == GearAt.nearHand && far)) return;

    Offset point() => switch (at) {
          GearAt.shoulders => sk.neck - sk.spine * 0.06 + Offset(sk.spine.dy, -sk.spine.dx) * 0.05,
          GearAt.chest => sk.neck - sk.spine * 0.08,
          GearAt.pelvis => sk.pelvis - Offset(-sk.spine.dy, sk.spine.dx) * 0.05,
          _ => sk.hand[s],
        };

    switch (equipment) {
      case ExerciseEquipment.barbell:
        if (front) {
          if (far) return;
          final l = at == GearAt.hands ? sk.hand[1] : point() - const Offset(0.1, 0);
          final r = at == GearAt.hands ? sk.hand[0] : point() + const Offset(0.1, 0);
          final dir = (r - l) / math.max((r - l).distance, 1e-6);
          final a = l - dir * 0.16, c = r + dir * 0.16;
          canvas.drawLine(a, c, line);
          for (final e in [a + dir * 0.03, c - dir * 0.03]) {
            canvas.drawRRect(
                RRect.fromRectAndRadius(Rect.fromCenter(center: e, width: 0.04, height: 0.16),
                    const Radius.circular(0.01)),
                fill);
          }
        } else if (!far || at != GearAt.hands) {
          // Side view: the plate, seen face on
          if (far) return;
          final p = point();
          canvas.drawCircle(p, 0.08, fill);
          canvas.drawCircle(p, 0.02, Paint()..color = colors.body);
        }
      case ExerciseEquipment.dumbbell:
        final p = point();
        if (front) {
          canvas.drawLine(p - const Offset(0, 0.04), p + const Offset(0, 0.04), line);
          for (final e in [p - const Offset(0, 0.045), p + const Offset(0, 0.045)]) {
            canvas.drawRRect(
                RRect.fromRectAndRadius(Rect.fromCenter(center: e, width: 0.06, height: 0.025),
                    const Radius.circular(0.008)),
                fill);
          }
        } else {
          canvas.drawCircle(p, 0.04, fill);
        }
      case ExerciseEquipment.kettlebell:
        if (far) return;
        final p = point();
        canvas.drawCircle(p + const Offset(0, 0.06), 0.05, fill);
        canvas.drawCircle(p + const Offset(0, 0.02), 0.025, line);
      case ExerciseEquipment.machine:
      case ExerciseEquipment.cable:
        if (at == GearAt.hands || at == GearAt.nearHand) {
          canvas.drawCircle(sk.hand[s], 0.022, fill);
        }
      case ExerciseEquipment.band:
      case ExerciseEquipment.bodyweight:
        break;
    }
  }

  @override
  bool shouldRepaint(DemoPainter old) =>
      old.t != t || old.motion != motion || old.colors.body != colors.body || old.female != female;
}
