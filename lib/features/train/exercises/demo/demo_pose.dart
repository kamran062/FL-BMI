import 'dart:math' as math;
import 'dart:ui';

/// Animated exercise demos drawn in code: a stick figure posed by joint
/// angles, looping between a few key poses. Used until filmed videos exist.

enum DemoView {
  /// Seen from the side, facing right (+x).
  side,

  /// Seen from the front; "near" limbs are on the right of the screen.
  front,
}

/// One arm or leg.
///
/// Side view: [angle] is the direction of the upper segment in degrees —
/// 0 straight down, 90 toward where the figure faces, 180 straight up,
/// -90 behind. Front view: 0 down, 90 out to that side, 180 up.
///
/// Arms: the forearm points at `angle + bend`. Legs: the shin points at
/// `angle - bend` (knees bend backward). [scale] shortens the limb when it
/// points toward the viewer; [foot] tilts the foot (negative = on the toes).
class Limb {
  final double angle;
  final double bend;
  final double scale;
  final double foot;
  const Limb(this.angle, [this.bend = 0, this.scale = 1, this.foot = 0]);

  static Limb lerp(Limb a, Limb b, double t) => Limb(
        _lerp(a.angle, b.angle, t),
        _lerp(a.bend, b.bend, t),
        _lerp(a.scale, b.scale, t),
        _lerp(a.foot, b.foot, t),
      );
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

class DemoPose {
  /// Spine lean: 0 upright, 90 horizontal head-forward (push-up),
  /// -90 horizontal head-behind (lying on the back), 180 upside down.
  final double torso;

  /// Extra head tilt (positive = chin down/forward).
  final double head;
  final Limb nearArm, farArm, nearLeg, farLeg;

  /// Extra movement of the whole body, e.g. the lift of a jump.
  final Offset shift;

  const DemoPose({
    this.torso = 0,
    this.head = 0,
    this.nearArm = const Limb(0),
    this.farArm = const Limb(0),
    this.nearLeg = const Limb(0),
    this.farLeg = const Limb(0),
    this.shift = Offset.zero,
  });

  static DemoPose lerp(DemoPose a, DemoPose b, double t) => DemoPose(
        torso: _lerp(a.torso, b.torso, t),
        head: _lerp(a.head, b.head, t),
        nearArm: Limb.lerp(a.nearArm, b.nearArm, t),
        farArm: Limb.lerp(a.farArm, b.farArm, t),
        nearLeg: Limb.lerp(a.nearLeg, b.nearLeg, t),
        farLeg: Limb.lerp(a.farLeg, b.farLeg, t),
        shift: Offset.lerp(a.shift, b.shift, t)!,
      );
}

/// Which body point stays still while the rest moves (feet on the floor,
/// hands on a bar…). Props are placed relative to it.
enum DemoAnchor { nearAnkle, nearToe, nearKnee, farKnee, nearHand, pelvis }

/// Where the equipment is drawn.
enum GearAt { hands, nearHand, shoulders, chest, pelvis, none }

/// Fixed scenery, in body units relative to the anchor point
/// (a standing body is about 0.9 tall).
class DemoProp {
  final Offset a, b;
  final double width;
  const DemoProp.line(this.a, this.b, {this.width = 0.02});

  /// A pad (bench, box, seat) given by its top-left and bottom-right.
  const DemoProp.pad(this.a, this.b) : width = -1;

  bool get isPad => width < 0;
}

class DemoMotion {
  final DemoView view;
  final DemoAnchor anchor;
  final List<DemoPose> frames;
  final Duration cycle;
  final List<DemoProp> props;
  final bool floor;
  final GearAt gearAt;

  /// Cable or band attachment; a line is drawn from the hands to it.
  final Offset? cable;

  const DemoMotion(
    this.frames, {
    this.view = DemoView.side,
    this.anchor = DemoAnchor.nearAnkle,
    this.cycle = const Duration(milliseconds: 2600),
    this.props = const [],
    this.floor = true,
    this.gearAt = GearAt.hands,
    this.cable,
  });

  /// Pose at [t] in 0..1 of the cycle: frame 0 → 1 → … → 0, eased.
  DemoPose poseAt(double t) {
    if (frames.length == 1) return frames.first;
    final n = frames.length;
    final x = (t % 1) * n;
    final i = x.floor() % n;
    final f = x - x.floor();
    final eased = 0.5 - math.cos(f * math.pi) / 2;
    return DemoPose.lerp(frames[i], frames[(i + 1) % n], eased);
  }
}

/// Segment lengths in body units.
abstract final class Body {
  static const torso = 0.30;
  static const neck = 0.10;
  static const headR = 0.065;
  static const upperArm = 0.16;
  static const forearm = 0.15;
  static const thigh = 0.22;
  static const shin = 0.21;
  static const foot = 0.07;
  static const shoulderHalf = 0.08;
  static const hipHalf = 0.05;
}

/// Joint positions. Lists hold [near, far].
class Skeleton {
  final Offset head, neck, pelvis;
  final List<Offset> shoulder, elbow, hand, hip, knee, ankle, toe;
  const Skeleton({
    required this.head,
    required this.neck,
    required this.pelvis,
    required this.shoulder,
    required this.elbow,
    required this.hand,
    required this.hip,
    required this.knee,
    required this.ankle,
    required this.toe,
  });

  Iterable<Offset> get points =>
      [head, neck, pelvis, ...shoulder, ...elbow, ...hand, ...hip, ...knee, ...ankle, ...toe];

  Skeleton translate(Offset d) => Skeleton(
        head: head + d,
        neck: neck + d,
        pelvis: pelvis + d,
        shoulder: [for (final p in shoulder) p + d],
        elbow: [for (final p in elbow) p + d],
        hand: [for (final p in hand) p + d],
        hip: [for (final p in hip) p + d],
        knee: [for (final p in knee) p + d],
        ankle: [for (final p in ankle) p + d],
        toe: [for (final p in toe) p + d],
      );

  /// Spine direction, pelvis → neck, unit length.
  Offset get spine {
    final d = neck - pelvis;
    return d / d.distance;
  }
}

Offset _dir(double deg) {
  final r = deg * math.pi / 180;
  return Offset(math.sin(r), math.cos(r));
}

/// Forward kinematics, then moved so the [anchor] joint sits at the origin.
Skeleton buildSkeleton(DemoPose p, DemoView view, DemoAnchor anchor) {
  const pelvis = Offset.zero;
  final spine = _dir(180 - p.torso);
  final neck = pelvis + spine * Body.torso;
  final head = neck + _dir(180 - p.torso - p.head) * Body.neck;

  // Sideways unit vector across the body (front view only).
  final across = Offset(-spine.dy, spine.dx);
  final front = view == DemoView.front;
  final shoulder = front
      ? [neck + across * Body.shoulderHalf, neck - across * Body.shoulderHalf]
      : [neck, neck];
  final hip = front
      ? [pelvis + across * Body.hipHalf, pelvis - across * Body.hipHalf]
      : [pelvis, pelvis];

  Offset d(double deg, int side) {
    final v = _dir(deg);
    return front && side == 1 ? Offset(-v.dx, v.dy) : v;
  }

  final arms = [p.nearArm, p.farArm];
  final legs = [p.nearLeg, p.farLeg];
  final elbow = <Offset>[], hand = <Offset>[];
  final knee = <Offset>[], ankle = <Offset>[], toe = <Offset>[];
  for (var s = 0; s < 2; s++) {
    final a = arms[s];
    final e = shoulder[s] + d(a.angle, s) * (Body.upperArm * a.scale);
    elbow.add(e);
    hand.add(e + d(a.angle + a.bend, s) * (Body.forearm * a.scale));

    final l = legs[s];
    final k = hip[s] + d(l.angle, s) * (Body.thigh * l.scale);
    knee.add(k);
    final shinAngle = l.angle - l.bend;
    final an = k + d(shinAngle, s) * (Body.shin * l.scale);
    ankle.add(an);
    toe.add(front
        ? an + Offset(s == 0 ? 0.035 : -0.035, 0.01)
        : an + _dir(shinAngle + 90 + l.foot) * Body.foot);
  }

  final sk = Skeleton(
    head: head,
    neck: neck,
    pelvis: pelvis,
    shoulder: shoulder,
    elbow: elbow,
    hand: hand,
    hip: hip,
    knee: knee,
    ankle: ankle,
    toe: toe,
  );
  final fixed = switch (anchor) {
    DemoAnchor.nearAnkle => ankle[0],
    DemoAnchor.nearToe => toe[0],
    DemoAnchor.nearKnee => knee[0],
    DemoAnchor.farKnee => knee[1],
    DemoAnchor.nearHand => hand[0],
    DemoAnchor.pelvis => pelvis,
  };
  return sk.translate(p.shift - fixed);
}
