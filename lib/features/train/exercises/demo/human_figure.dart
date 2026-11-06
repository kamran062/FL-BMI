import 'dart:math' as math;
import 'dart:ui';

import 'package:bmi_health/features/train/exercises/demo/demo_pose.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';

/// Draws a realistic illustrated person over a [Skeleton]: tapered limbs
/// with muscle shape, a shaped torso, clothes, skin shading and hair.
/// All sizes are in body units (a standing person is ~0.9 tall).
class HumanFigure {
  final Skeleton sk;
  final DemoView view;
  final bool female;
  final Muscle working;
  final void Function(Canvas) behindBody;
  final void Function(Canvas) inFront;

  HumanFigure({
    required this.sk,
    required this.view,
    required this.female,
    required this.working,
    required this.behindBody,
    required this.inFront,
  });

  static const _headScale = 0.8;
  static const headH = 0.078 * _headScale;

  // Palette (fixed, reads on light and dark backgrounds)
  static const _skin = Color(0xFFC98B62);
  static const _skinShade = Color(0xFFA36A47);
  static const _hair = Color(0xFF241A15);
  static const _shirt = Color(0xFF2F6FDB);
  static const _shirtShade = Color(0xFF2257B4);
  static const _tank = Color(0xFF12A594);
  static const _tankShade = Color(0xFF0C7F72);
  static const _shorts = Color(0xFF353A42);
  static const _shortsShade = Color(0xFF24282E);
  static const _leggings = Color(0xFF3B3F4A);
  static const _leggingsShade = Color(0xFF2A2D35);
  static const _shoeColor = Color(0xFFF1F3F5);
  static const _sole = Color(0xFF9AA3AD);
  static const _glow = Color(0xFFFF4D3D);

  bool get _side => view == DemoView.side;
  Color get _top => female ? _tank : _shirt;
  Color get _topShade => female ? _tankShade : _shirtShade;

  /// Unit vector toward where the chest faces (side view), or across the
  /// body toward the near side (front view).
  Offset get _front => Offset(-sk.spine.dy, sk.spine.dx);

  Offset _along(double t) => sk.pelvis + sk.spine * (Body.torso * t);

  void paint(Canvas c) {
    if (_side) {
      _arm(c, 1);
      _leg(c, 1);
      behindBody(c);
      _torso(c);
      _leg(c, 0);
      _head(c);
      _arm(c, 0);
      inFront(c);
    } else {
      _leg(c, 1);
      _leg(c, 0);
      behindBody(c);
      _torso(c);
      _arm(c, 1);
      _arm(c, 0);
      _head(c);
      inFront(c);
    }
  }

  // ── Body parts ─────────────────────────────────────────────────────────

  /// Far limbs (side view) are a little darker, as if in shadow.
  Color _tone(Color c, int s) => _side && s == 1 ? Color.lerp(c, const Color(0xFF000000), 0.22)! : c;

  void _leg(Canvas c, int s) {
    final hip = sk.hip[s], knee = sk.knee[s], ankle = sk.ankle[s], toe = sk.toe[s];
    final thigh = _side
        ? capsule(hip, knee, 0.06, 0.04, front: 0.012, back: 0.008)
        : capsule(hip, knee, 0.05, 0.036, front: 0.006, back: 0.006);
    final shin = capsule(knee, ankle, 0.045, 0.026, back: 0.02, at: 0.3);
    final legColor = female ? _leggings : _skin;
    final legShade = female ? _leggingsShade : _skinShade;
    _shaded(c, shin, _tone(legColor, s), _tone(legShade, s));
    _shaded(c, thigh, _tone(legColor, s), _tone(legShade, s));
    if (working == Muscle.calves) _glowOn(c, shin, capsule(knee, ankle, 0.04, 0.02, at: 0.3), s);
    if (working == Muscle.quads) _glowOn(c, thigh, _shift(capsule(hip, knee, 0.05, 0.03), -0.02, hip, knee), s);
    if (working == Muscle.hamstrings) _glowOn(c, thigh, _shift(capsule(hip, knee, 0.05, 0.03), 0.02, hip, knee), s);
    // Front view: glutes show as the outer hip and upper thigh
    if (working == Muscle.glutes && !_side) {
      _glowOn(c, thigh, capsule(hip, Offset.lerp(hip, knee, 0.5)!, 0.05, 0.04), s);
    }
    if (!female) {
      // Shorts over the upper thigh
      final mid = Offset.lerp(hip, knee, 0.45)!;
      _shaded(c, _side ? capsule(hip, mid, 0.068, 0.054, front: 0.006) : capsule(hip, mid, 0.056, 0.048),
          _tone(_shorts, s), _tone(_shortsShade, s));
    }
    _shoe(c, ankle, toe, s);
  }

  void _shoe(Canvas c, Offset ankle, Offset toe, int s) {
    if (!_side) {
      final r = Rect.fromCenter(center: toe + const Offset(0, 0.005), width: 0.07, height: 0.045);
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(0.02)), Paint()..color = _tone(_shoeColor, s));
      c.drawLine(r.bottomLeft + const Offset(0.01, 0), r.bottomRight - const Offset(0.01, 0),
          _stroke(_sole, 0.008));
      return;
    }
    final d = toe - ankle;
    final u = d / math.max(d.distance, 1e-6);
    final shoe = capsule(ankle - u * 0.028, toe + u * 0.018, 0.032, 0.022);
    c.drawPath(shoe, Paint()..color = _tone(_shoeColor, s));
    c.drawPath(shoe, _stroke(_tone(_sole, s), 0.007));
  }

  void _arm(Canvas c, int s) {
    final sh = sk.shoulder[s], el = sk.elbow[s], hand = sk.hand[s];
    final upper = capsule(sh, el, 0.044, 0.031, front: 0.009, back: 0.008);
    final fore = capsule(el, hand, 0.032, 0.022, front: 0.006, at: 0.3);
    _shaded(c, fore, _tone(_skin, s), _tone(_skinShade, s));
    _shaded(c, upper, _tone(_skin, s), _tone(_skinShade, s));
    if (working == Muscle.biceps) _glowOn(c, upper, _shift(capsule(sh, el, 0.032, 0.024), -0.014, sh, el), s);
    if (working == Muscle.triceps) _glowOn(c, upper, _shift(capsule(sh, el, 0.032, 0.024), 0.014, sh, el), s);
    final d = hand - el;
    final u = d / math.max(d.distance, 1e-6);
    c.drawCircle(hand + u * 0.012, 0.027, Paint()..color = _tone(_skinShade, s));
    c.drawCircle(hand + u * 0.008, 0.024, Paint()..color = _tone(_skin, s));
    // Shoulder cap: the sleeve (or skin for the tank top)
    final cap = capsule(sh, Offset.lerp(sh, el, female ? 0.1 : 0.36)!, 0.047, female ? 0.044 : 0.038);
    if (female) {
      _shaded(c, cap, _tone(_skin, s), _tone(_skinShade, s));
    } else {
      _shaded(c, cap, _tone(_top, s), _tone(_topShade, s));
    }
    if (working == Muscle.shoulders) {
      _glowOn(c, cap, Path()..addOval(Rect.fromCircle(center: sh, radius: 0.045)), s);
    }
  }

  void _torso(Canvas c) {
    final body = _side ? _sideTorso() : _frontTorso();
    _shaded(c, body, _top, _topShade);
    // Shorts / leggings waistband and seat
    final lower = _side ? _sideTorso(to: 0.22) : _frontTorso(to: 0.22);
    _shaded(c, lower, female ? _leggings : _shorts, female ? _leggingsShade : _shortsShade);

    final f = _front;
    final glow = switch (working) {
      Muscle.chest => _side
          ? (Path()..addOval(Rect.fromCircle(center: _along(0.72) + f * 0.045, radius: 0.055)))
          : (Path()
            ..addOval(Rect.fromCircle(center: _along(0.74) + f * 0.045, radius: 0.045))
            ..addOval(Rect.fromCircle(center: _along(0.74) - f * 0.045, radius: 0.045))),
      Muscle.back => _side
          ? capsule(_along(0.4) - f * 0.05, _along(0.85) - f * 0.055, 0.045, 0.05)
          : capsule(_along(0.45), _along(0.85), 0.07, 0.09),
      Muscle.core => capsule(_along(0.18) + (_side ? f * 0.035 : Offset.zero),
          _along(0.55) + (_side ? f * 0.045 : Offset.zero), 0.045, 0.045),
      Muscle.glutes when _side =>
        Path()..addOval(Rect.fromCircle(center: _along(0.02) - f * 0.05, radius: 0.06)),
      _ => null,
    };
    if (glow != null) _glowOn(c, body..addPath(lower, Offset.zero), glow, 0);
  }

  Path _sideTorso({double to = 1.0}) {
    // Offsets from the spine line: front (chest/belly) and back (glutes/back)
    final fr = female
        ? const [(-0.14, 0.03), (0.0, 0.058), (0.3, 0.05), (0.6, 0.062), (0.74, 0.082), (0.9, 0.055), (1.0, 0.035)]
        : const [(-0.14, 0.03), (0.0, 0.06), (0.3, 0.056), (0.6, 0.066), (0.76, 0.084), (0.92, 0.06), (1.0, 0.036)];
    final bk = female
        ? const [(-0.14, 0.05), (0.02, 0.092), (0.25, 0.055), (0.55, 0.058), (0.8, 0.066), (0.95, 0.052), (1.0, 0.04)]
        : const [(-0.14, 0.05), (0.02, 0.084), (0.25, 0.058), (0.55, 0.064), (0.8, 0.076), (0.95, 0.058), (1.0, 0.04)];
    final f = _front;
    List<Offset> side(List<(double, double)> prof, double sign) => [
          for (final (t, w) in prof)
            if (t <= to + 1e-9) _along(t) + f * (w * sign),
          if (to < 1) _along(to) + f * (_interp(prof, to) * sign),
        ];
    final front = side(fr, 1);
    final back = side(bk, -1).reversed.toList();
    return smoothClosed([...front, ...back]);
  }

  Path _frontTorso({double to = 1.0}) {
    // Half-widths across the body
    final prof = female
        ? const [(-0.14, 0.045), (0.0, 0.08), (0.35, 0.062), (0.7, 0.082), (0.88, 0.094), (1.0, 0.045)]
        : const [(-0.14, 0.045), (0.0, 0.074), (0.35, 0.072), (0.7, 0.1), (0.9, 0.118), (1.0, 0.048)];
    final f = _front;
    final right = [
      for (final (t, w) in prof)
        if (t <= to + 1e-9) _along(t) + f * w,
      if (to < 1) _along(to) + f * _interp(prof, to),
    ];
    final left = [for (final p in right.reversed) _mirror(p)];
    return smoothClosed([...right, ...left]);
  }

  Offset _mirror(Offset p) {
    final rel = p - sk.pelvis;
    final along = sk.spine * (rel.dx * sk.spine.dx + rel.dy * sk.spine.dy);
    final across = rel - along;
    return sk.pelvis + along - across;
  }

  static double _interp(List<(double, double)> prof, double t) {
    for (var i = 0; i < prof.length - 1; i++) {
      final (t0, w0) = prof[i];
      final (t1, w1) = prof[i + 1];
      if (t >= t0 && t <= t1) return w0 + (w1 - w0) * (t - t0) / (t1 - t0);
    }
    return prof.last.$2;
  }

  void _head(Canvas c) {
    final up0 = sk.head - sk.neck;
    final up = up0 / math.max(up0.distance, 1e-6);
    final fwd = Offset(-up.dy, up.dx);
    // Neck
    _shaded(c, capsule(sk.neck - up * 0.01, sk.head - up * 0.03, 0.027, 0.025), _skin, _skinShade);
    // Head drawn at adult proportions (about 1/7.5 of standing height)
    c.save();
    c.translate(sk.head.dx, sk.head.dy);
    c.scale(_headScale);
    c.translate(-sk.head.dx, -sk.head.dy);
    final angle = math.atan2(up.dx, -up.dy);
    void oval(Offset center, double w, double h, Color color) {
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(angle);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 2, height: h * 2), Paint()..color = color);
      c.restore();
    }

    if (_side) {
      if (female) {
        _fill(c, capsule(sk.head - fwd * 0.055 + up * 0.035, sk.head - fwd * 0.1 - up * 0.045, 0.024, 0.013), _hair);
      }
      oval(sk.head + up * 0.007 - fwd * 0.012, 0.066, 0.076, _hair);
      oval(sk.head + fwd * 0.008 - up * 0.008, 0.06, 0.07, _skin);
      // Hairline over the top and back
      c.save();
      c.clipPath(Path()
        ..addOval(Rect.fromCircle(center: sk.head + fwd * 0.008 - up * 0.008, radius: 0.075)));
      oval(sk.head + up * 0.03 - fwd * 0.03, 0.06, 0.055, _hair);
      c.restore();
      c.drawCircle(sk.head - fwd * 0.006, 0.012, Paint()..color = _skinShade);
      c.drawCircle(sk.head + fwd * 0.064 - up * 0.004, 0.011, Paint()..color = _skin);
      c.drawCircle(sk.head + fwd * 0.03 + up * 0.012, 0.006, Paint()..color = _hair);
    } else {
      if (female) c.drawCircle(sk.head + up * 0.078, 0.03, Paint()..color = _hair);
      oval(sk.head + up * 0.01, 0.068, 0.078, _hair);
      final ear = Paint()..color = _skinShade;
      c.drawCircle(sk.head + fwd * 0.058, 0.013, ear);
      c.drawCircle(sk.head - fwd * 0.058, 0.013, ear);
      oval(sk.head - up * 0.008, 0.058, 0.068, _skin);
      c.save();
      c.clipPath(Path()..addOval(Rect.fromCircle(center: sk.head - up * 0.008, radius: 0.07)));
      oval(sk.head + up * 0.05, 0.07, 0.045, _hair);
      c.restore();
      final eye = Paint()..color = _hair;
      c.drawCircle(sk.head + fwd * 0.022 + up * 0.002, 0.006, eye);
      c.drawCircle(sk.head - fwd * 0.022 + up * 0.002, 0.006, eye);
    }
    c.restore();
  }

  // ── Drawing helpers ────────────────────────────────────────────────────

  /// Base colour lit from the upper left, with a shaded rim on the far side.
  void _shaded(Canvas c, Path p, Color base, Color shade) {
    c.drawPath(p, Paint()..color = shade);
    c.save();
    c.clipPath(p);
    c.drawPath(p.shift(const Offset(-0.008, -0.01)), Paint()..color = base);
    c.restore();
  }

  void _fill(Canvas c, Path p, Color color) => c.drawPath(p, Paint()..color = color);

  /// Soft red glow on the working muscle, kept inside the body part.
  void _glowOn(Canvas c, Path part, Path area, int s) {
    c.save();
    c.clipPath(part);
    c.drawPath(
        area,
        Paint()
          ..color = _glow.withAlpha(s == 0 ? 165 : 110)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.012));
    c.restore();
  }

  Path _shift(Path p, double amount, Offset a, Offset b) {
    final d = b - a;
    final u = d / math.max(d.distance, 1e-6);
    return p.shift(Offset(-u.dy, u.dx) * amount);
  }

  static Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;
}

/// A limb-like shape from [a] to [b] with end radii [ra], [rb] and muscle
/// bulges. [back] bulges toward the back of the body in side view (the
/// triceps / hamstring / calf side), [front] toward the front.
Path capsule(Offset a, Offset b, double ra, double rb, {double front = 0, double back = 0, double at = 0.42}) {
  final d = b - a;
  final len = d.distance;
  if (len < 1e-6) return Path()..addOval(Rect.fromCircle(center: a, radius: math.max(ra, rb)));
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final rm = ra + (rb - ra) * at;
  final m = a + d * at;
  Offset ctrl(Offset s, Offset e, Offset through) => through * 2 - (s + e) / 2;
  final b1 = a + n * ra, b2 = b + n * rb, f1 = a - n * ra, f2 = b - n * rb;
  return Path()
    ..moveTo(b1.dx, b1.dy)
    ..quadraticBezierTo(ctrl(b1, b2, m + n * (rm + back)).dx, ctrl(b1, b2, m + n * (rm + back)).dy, b2.dx, b2.dy)
    ..arcToPoint(f2, radius: Radius.circular(rb), clockwise: false)
    ..quadraticBezierTo(ctrl(f2, f1, m - n * (rm + front)).dx, ctrl(f2, f1, m - n * (rm + front)).dy, f1.dx, f1.dy)
    ..arcToPoint(b1, radius: Radius.circular(ra), clockwise: false)
    ..close();
}

/// Smooth closed outline through [pts] (Catmull-Rom as cubic Béziers).
Path smoothClosed(List<Offset> pts) {
  final n = pts.length;
  final p = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n], p1 = pts[i], p2 = pts[(i + 1) % n], p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6, c2 = p2 - (p3 - p1) / 6;
    p.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return p..close();
}

/// Benches, floor, shadow and cables.
class Scenery {
  final bool dark;
  final Color line;
  Scenery(this.dark, this.line);

  Color get _pad => dark ? const Color(0xFF3A4048) : const Color(0xFF2E333A);
  Color get _padTop => dark ? const Color(0xFF4A515B) : const Color(0xFF454B54);
  Color get _metal => dark ? const Color(0xFF7D8690) : const Color(0xFF9AA3AD);

  void prop(Canvas c, DemoProp p) {
    if (p.isPad || p.width >= 0.04) {
      final Path shape;
      if (p.isPad) {
        shape = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromPoints(p.a, p.b), const Radius.circular(0.02)));
      } else {
        shape = capsule(p.a, p.b, p.width / 2, p.width / 2);
      }
      c.drawPath(shape, Paint()..color = _pad);
      c.save();
      c.clipPath(shape);
      c.drawPath(shape, Paint()
        ..color = _padTop
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.012);
      c.restore();
    } else {
      c.drawLine(p.a, p.b, HumanFigure._stroke(_metal, p.width));
    }
  }

  void floor(Canvas c, Rect bounds, double y) {
    c.drawLine(Offset(bounds.left + 0.02, y), Offset(bounds.right - 0.02, y), HumanFigure._stroke(line, 0.012));
  }

  void shadow(Canvas c, Offset base, Skeleton sk) {
    final x = (sk.ankle[0].dx + sk.ankle[1].dx + sk.pelvis.dx) / 3;
    c.drawOval(
      Rect.fromCenter(center: Offset(x, base.dy), width: 0.42, height: 0.04),
      Paint()
        ..color = const Color(0xFF000000).withAlpha(dark ? 110 : 45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.01),
    );
  }

  void cable(Canvas c, List<Offset> hands, Offset anchor, {required bool band, required Color bandColor}) {
    final paint = band
        ? HumanFigure._stroke(bandColor.withAlpha(200), 0.018)
        : HumanFigure._stroke(dark ? const Color(0xFF8A939D) : const Color(0xFF59616A), 0.007);
    for (final h in hands) {
      c.drawLine(h, anchor, paint);
    }
    if (!band) {
      c.drawCircle(anchor, 0.03, Paint()..color = _pad);
      c.drawCircle(anchor, 0.012, Paint()..color = _metal);
    }
  }
}

/// Barbells, dumbbells, kettlebells and handles.
class Gear {
  final ExerciseEquipment kind;
  final GearAt at;
  final DemoView view;
  final bool dark;
  Gear(this.kind, this.at, this.view, this.dark);

  static const _iron = Color(0xFF2B3036);
  static const _ironLight = Color(0xFF454C55);
  static const _steel = Color(0xFFB9C1C9);

  void paint(Canvas c, Skeleton sk, {required bool far}) {
    if (at == GearAt.none || (at == GearAt.nearHand && far)) return;
    final s = far ? 1 : 0;
    final side = view == DemoView.side;
    Offset point() => switch (at) {
          GearAt.shoulders => sk.neck - sk.spine * 0.06 + Offset(sk.spine.dy, -sk.spine.dx) * 0.06,
          GearAt.chest => sk.neck - sk.spine * 0.08 + Offset(-sk.spine.dy, sk.spine.dx) * 0.05,
          GearAt.pelvis => sk.pelvis + Offset(-sk.spine.dy, sk.spine.dx) * 0.08,
          _ => sk.hand[s],
        };

    switch (kind) {
      case ExerciseEquipment.barbell:
        if (side) {
          if (far) return;
          final p = point();
          c.drawCircle(p, 0.105, Paint()..color = _iron);
          c.drawCircle(p, 0.09, Paint()..color = _ironLight);
          c.drawCircle(p, 0.075, Paint()..color = _iron);
          c.drawCircle(p, 0.026, Paint()..color = _steel);
          c.drawCircle(p, 0.012, Paint()..color = _iron);
        } else if (!far) {
          final l = at == GearAt.hands ? sk.hand[1] : point() - const Offset(0.12, 0);
          final r = at == GearAt.hands ? sk.hand[0] : point() + const Offset(0.12, 0);
          final dir = (r - l) / math.max((r - l).distance, 1e-6);
          final a = l - dir * 0.2, e = r + dir * 0.2;
          c.drawLine(a, e, HumanFigure._stroke(_steel, 0.018));
          for (final end in [a + dir * 0.04, e - dir * 0.04]) {
            c.drawRRect(
                RRect.fromRectAndRadius(Rect.fromCenter(center: end, width: 0.045, height: 0.21),
                    const Radius.circular(0.012)),
                Paint()..color = _iron);
          }
        }
      case ExerciseEquipment.dumbbell:
        final p = point();
        final color = far ? Color.lerp(_iron, const Color(0xFF000000), 0.3)! : _iron;
        if (side) {
          _hex(c, p, 0.048, color);
          _hex(c, p, 0.03, far ? _iron : _ironLight);
        } else {
          c.drawLine(p - const Offset(0, 0.05), p + const Offset(0, 0.05), HumanFigure._stroke(_steel, 0.014));
          for (final e in [p - const Offset(0, 0.055), p + const Offset(0, 0.055)]) {
            c.drawRRect(
                RRect.fromRectAndRadius(Rect.fromCenter(center: e, width: 0.07, height: 0.032),
                    const Radius.circular(0.008)),
                Paint()..color = color);
          }
        }
      case ExerciseEquipment.kettlebell:
        if (far) return;
        final p = point();
        c.drawCircle(p + const Offset(0, 0.03), 0.032, HumanFigure._stroke(_iron, 0.016)..style = PaintingStyle.stroke);
        c.drawCircle(p + const Offset(0, 0.085), 0.058, Paint()..color = _iron);
        c.drawCircle(p + const Offset(-0.018, 0.07), 0.018, Paint()..color = _ironLight);
      case ExerciseEquipment.machine:
      case ExerciseEquipment.cable:
        if (at == GearAt.hands || at == GearAt.nearHand) {
          c.drawRRect(
              RRect.fromRectAndRadius(Rect.fromCenter(center: sk.hand[s], width: 0.03, height: 0.06),
                  const Radius.circular(0.01)),
              Paint()..color = _iron);
        }
      case ExerciseEquipment.band:
      case ExerciseEquipment.bodyweight:
        break;
    }
  }

  void _hex(Canvas c, Offset center, double r, Color color) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = math.pi / 6 + i * math.pi / 3;
      final v = center + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    c.drawPath(p..close(), Paint()..color = color);
  }
}
