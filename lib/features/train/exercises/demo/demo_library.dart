import 'dart:ui';

import 'package:bmi_health/features/train/exercises/demo/demo_pose.dart';

/// Key poses for every catalog exercise. Angles follow [Limb]; props are in
/// body units relative to the motion's anchor (a standing body is ~0.9 tall).
abstract final class DemoLibrary {
  static DemoMotion? motionFor(String id) => _all[id];
  static Iterable<String> get ids => _all.keys;
}

DemoPose _p({
  double t = 0,
  double head = 0,
  Limb arm = const Limb(0),
  Limb? farArm,
  Limb leg = const Limb(0),
  Limb? farLeg,
  Offset shift = Offset.zero,
}) =>
    DemoPose(
      torso: t,
      head: head,
      nearArm: arm,
      farArm: farArm ?? arm,
      nearLeg: leg,
      farLeg: farLeg ?? leg,
      shift: shift,
    );

/// A leg whose foot stays flat on the floor.
Limb _flat(double thigh, double knee) => Limb(thigh, knee, 1, knee - thigh);

const _hold = Duration(milliseconds: 3600);
const _quick = Duration(milliseconds: 1400);

// ── Scenery ──────────────────────────────────────────────────────────────

/// Seat under the pelvis (anchor: pelvis, thighs level, shins down).
const _seat = [
  DemoProp.pad(Offset(-0.13, 0.03), Offset(0.15, 0.075)),
  DemoProp.line(Offset(0.01, 0.075), Offset(0.01, 0.235), width: 0.03),
];
const _seatBack = DemoProp.pad(Offset(-0.12, -0.36), Offset(-0.07, 0.03));
const _seatLeg = Limb(90, 90);

/// Flat bench under a body lying on its back, head left (anchor: pelvis).
const _bench = [
  DemoProp.pad(Offset(-0.44, 0.03), Offset(0.12, 0.075)),
  DemoProp.line(Offset(-0.38, 0.075), Offset(-0.38, 0.27), width: 0.03),
  DemoProp.line(Offset(0.06, 0.075), Offset(0.06, 0.27), width: 0.03),
];
const _benchLeg = Limb(100, 90);

/// Bench beside a standing body, hands rest on it (anchor: near ankle).
const _sideBench = [
  DemoProp.pad(Offset(0.2, -0.42), Offset(0.62, -0.37)),
  DemoProp.line(Offset(0.26, -0.37), Offset(0.26, 0), width: 0.03),
  DemoProp.line(Offset(0.56, -0.37), Offset(0.56, 0), width: 0.03),
];

DemoMotion _supine(List<DemoPose> f, {List<DemoProp> props = _bench, Duration? cycle}) =>
    DemoMotion(f, anchor: DemoAnchor.pelvis, props: props, cycle: cycle ?? const Duration(milliseconds: 2600));

DemoMotion _seated(List<DemoPose> f, {bool back = true, Offset? cable, GearAt gearAt = GearAt.hands}) =>
    DemoMotion(f,
        anchor: DemoAnchor.pelvis,
        props: [..._seat, if (back) _seatBack],
        cable: cable,
        gearAt: gearAt);

// ── Movement families ────────────────────────────────────────────────────

DemoMotion _squat({Limb arm = const Limb(90), Limb? armDown, GearAt gearAt = GearAt.hands, double lean = 40}) =>
    DemoMotion([
      _p(t: 5, arm: armDown ?? arm),
      _p(t: lean, arm: arm, leg: _flat(80, 105)),
    ], gearAt: gearAt);

const _barOnBack = Limb(-35, 160);
const _frontRack = Limb(80, 160);
const _gobletHold = Limb(15, 145);

DemoMotion _hinge({double t = 75, Limb leg = const Limb(20, 25, 1, 5), Limb arm = const Limb(0), GearAt gearAt = GearAt.hands}) =>
    DemoMotion([
      _p(t: 3, arm: arm),
      _p(t: t, arm: arm, leg: leg),
    ], gearAt: gearAt);

DemoMotion _benchPress({double t = -90, double top = 178, List<DemoProp> props = _bench, Limb leg = _benchLeg}) =>
    _supine([
      _p(t: t, arm: Limb(top - 88, 90), leg: leg),
      _p(t: t, arm: Limb(top, 2), leg: leg),
    ], props: props);

const _inclineBench = [
  DemoProp.line(Offset(0.0, 0.05), Offset(-0.25, -0.24), width: 0.05),
  DemoProp.line(Offset(-0.05, 0.07), Offset(-0.05, 0.27), width: 0.03),
];
const _declineBench = [
  DemoProp.line(Offset(0.12, 0.0), Offset(-0.3, 0.17), width: 0.05),
  DemoProp.line(Offset(-0.05, 0.1), Offset(-0.05, 0.3), width: 0.03),
];

/// Push-up from the feet; [rise] is the body angle above the floor at the top.
DemoMotion _pushUp({double top = 64, double bottom = 84, Limb low = const Limb(-120, 162)}) => DemoMotion([
      _p(t: top, arm: const Limb(0), leg: Limb(top - 180, 0, 1, 70)),
      _p(t: bottom, arm: low, leg: Limb(bottom - 180, 0, 1, 70)),
    ], anchor: DemoAnchor.nearToe);

DemoMotion _curl({Limb top = const Limb(0, 140), Limb bottom = const Limb(0, 5), double t = 0, Offset? cable}) =>
    DemoMotion([_p(t: t, arm: bottom), _p(t: t, arm: top)], cable: cable);

DemoMotion _row(Limb from, Limb to, {Offset? cable, bool seatedFloor = false}) => seatedFloor
    ? DemoMotion([
        _p(t: 5, arm: from, leg: const Limb(90, 15)),
        _p(t: -8, arm: to, leg: const Limb(90, 15)),
      ], anchor: DemoAnchor.pelvis, cable: cable)
    : _seated([_p(arm: from, leg: _seatLeg), _p(t: -5, arm: to, leg: _seatLeg)], back: false, cable: cable);

DemoMotion _bentRow({Limb? farArm}) => DemoMotion([
      _p(t: 70, arm: const Limb(0), farArm: farArm, leg: const Limb(30, 40, 1, 10)),
      _p(t: 70, arm: const Limb(-110, 110), farArm: farArm, leg: const Limb(30, 40, 1, 10)),
    ], props: farArm == null ? const [] : _sideBench);

DemoMotion _press({bool seated = false}) {
  final a = _p(arm: const Limb(25, 150), leg: seated ? _seatLeg : const Limb(0));
  final b = _p(arm: const Limb(178, 2), leg: seated ? _seatLeg : const Limb(0));
  return seated ? _seated([a, b]) : DemoMotion([a, b]);
}

DemoMotion _calfRaise({bool seated = false, bool single = false}) => seated
    ? _seated([
        _p(arm: const Limb(30, 40), leg: const Limb(90, 90)),
        _p(arm: const Limb(30, 40), leg: const Limb(90, 90, 1, -35), shift: const Offset(0, -0.05)),
      ], back: false)
    : DemoMotion([
        _p(farLeg: single ? const Limb(-10, 80) : null),
        _p(leg: const Limb(0, 0, 1, -40), farLeg: single ? const Limb(-10, 80) : const Limb(0, 0, 1, -40)),
      ], anchor: DemoAnchor.nearToe, cycle: _quick * 1.4);

DemoMotion _bridge({Limb? farLeg, List<DemoProp> props = const [], double low = -90, double high = -112}) =>
    DemoMotion([
      _p(t: low, arm: const Limb(80), leg: const Limb(135, 125), farLeg: farLeg),
      _p(t: high, arm: const Limb(80), leg: const Limb(100, 100), farLeg: farLeg),
    ], anchor: DemoAnchor.nearAnkle, props: props, gearAt: GearAt.pelvis);

DemoMotion _stretch(DemoPose a, DemoPose b,
        {DemoAnchor anchor = DemoAnchor.nearAnkle, DemoView view = DemoView.side, List<DemoProp> props = const []}) =>
    DemoMotion([a, b], anchor: anchor, view: view, props: props, cycle: _hold);

// ── Every exercise ───────────────────────────────────────────────────────

final Map<String, DemoMotion> _all = {
  // Chest
  'barbell_bench_press': _benchPress(),
  'incline_barbell_bench_press': _benchPress(t: -50, top: 150, props: _inclineBench, leg: const Limb(95, 85)),
  'decline_bench_press': _benchPress(t: -118, top: 190, props: _declineBench, leg: const Limb(80, 70)),
  'dumbbell_bench_press': _benchPress(),
  'incline_dumbbell_press': _benchPress(t: -50, top: 150, props: _inclineBench, leg: const Limb(95, 85)),
  'dumbbell_fly': _supine([
    _p(t: -90, arm: const Limb(40, 15, 0.45), leg: _benchLeg),
    _p(t: -90, arm: const Limb(178, 0), leg: _benchLeg),
  ]),
  'chest_press_machine': _seated([
    _p(arm: const Limb(-40, 130), leg: _seatLeg),
    _p(arm: const Limb(90, 0), leg: _seatLeg),
  ]),
  'pec_deck': DemoMotion([
    _p(arm: const Limb(90, 70)),
    _p(arm: const Limb(90, 70, 0.3)),
  ], view: DemoView.front),
  'cable_fly': DemoMotion([
    _p(t: 0, arm: const Limb(95, 15)),
    _p(t: 0, arm: const Limb(70, 15, 0.3)),
  ], view: DemoView.front),
  'low_to_high_cable_fly': DemoMotion([
    _p(arm: const Limb(30, 10)),
    _p(arm: const Limb(120, 10, 0.35)),
  ], view: DemoView.front),
  'push_up': _pushUp(),
  'incline_push_up': DemoMotion([
    _p(t: 42, leg: const Limb(-138, 0, 1, 60)),
    _p(t: 62, arm: const Limb(-110, 140), leg: const Limb(-118, 0, 1, 60)),
  ], anchor: DemoAnchor.nearHand, props: const [
    DemoProp.pad(Offset(-0.15, 0.02), Offset(0.15, 0.07)),
    DemoProp.line(Offset(-0.1, 0.07), Offset(-0.1, 0.2), width: 0.03),
    DemoProp.line(Offset(0.1, 0.07), Offset(0.1, 0.2), width: 0.03),
  ]),
  'knee_push_up': DemoMotion([
    _p(t: 52, leg: const Limb(-128, -38, 1, -90)),
    _p(t: 80, arm: const Limb(-120, 162), leg: const Limb(-100, -10, 1, -90)),
  ], anchor: DemoAnchor.nearKnee),
  'chest_dip': DemoMotion([
    _p(t: 15, arm: const Limb(0), leg: const Limb(10, 80)),
    _p(t: 30, arm: const Limb(-70, 70), leg: const Limb(10, 80)),
  ], anchor: DemoAnchor.nearHand, floor: false, props: const [
    DemoProp.line(Offset(-0.12, 0.0), Offset(0.12, 0.0), width: 0.03),
  ]),
  'band_chest_press': DemoMotion([
    _p(arm: const Limb(-40, 130)),
    _p(arm: const Limb(90, 0)),
  ], cable: const Offset(-0.3, -0.6)),

  // Back
  'barbell_deadlift': _hinge(t: 55, leg: _flat(60, 75)),
  'barbell_row': _bentRow(),
  't_bar_row': _bentRow(),
  'pull_up': DemoMotion([
    _p(arm: const Limb(175, 0), leg: const Limb(5, 30)),
    _p(arm: const Limb(15, 160), leg: const Limb(5, 30)),
  ], anchor: DemoAnchor.nearHand, floor: false, props: const [
    DemoProp.line(Offset(-0.2, 0), Offset(0.2, 0), width: 0.025),
  ]),
  'chin_up': DemoMotion([
    _p(arm: const Limb(175, 0), leg: const Limb(10, 60)),
    _p(arm: const Limb(25, 150), leg: const Limb(10, 60)),
  ], anchor: DemoAnchor.nearHand, floor: false, props: const [
    DemoProp.line(Offset(-0.2, 0), Offset(0.2, 0), width: 0.025),
  ]),
  'assisted_pull_up': DemoMotion([
    _p(arm: const Limb(175, 0), leg: const Limb(0, 90)),
    _p(arm: const Limb(15, 160), leg: const Limb(0, 90)),
  ], anchor: DemoAnchor.nearHand, floor: false, props: const [
    DemoProp.line(Offset(-0.2, 0), Offset(0.2, 0), width: 0.025),
  ]),
  'lat_pulldown': _seated([
    _p(arm: const Limb(170, 0), leg: _seatLeg),
    _p(t: -10, arm: const Limb(15, 150), leg: _seatLeg),
  ], back: false, cable: const Offset(0.1, -0.85)),
  'seated_cable_row': _row(const Limb(90, 0), const Limb(-40, 130), cable: const Offset(0.62, 0.1), seatedFloor: true),
  'machine_row': _row(const Limb(90, 0), const Limb(-40, 130)),
  'dumbbell_row': _bentRow(farArm: const Limb(55, 0)),
  'straight_arm_pulldown': DemoMotion([
    _p(t: 25, arm: const Limb(150, 0), leg: const Limb(10, 20, 1, 10)),
    _p(t: 25, arm: const Limb(0, 0), leg: const Limb(10, 20, 1, 10)),
  ], cable: const Offset(0.45, -0.95)),
  'inverted_row': DemoMotion([
    _p(t: -60, arm: const Limb(180, 0), leg: const Limb(60, 0, 1, 40)),
    _p(t: -60, arm: const Limb(50, 130), leg: const Limb(60, 0, 1, 40)),
  ], anchor: DemoAnchor.nearHand, props: const [
    DemoProp.line(Offset(-0.2, 0), Offset(0.2, 0), width: 0.025),
  ]),
  'back_extension': DemoMotion([
    _p(t: 150, arm: const Limb(150, 150), leg: const Limb(-45, 0, 1, 40)),
    _p(t: 55, arm: const Limb(-90, 170), leg: const Limb(-45, 0, 1, 40)),
  ], anchor: DemoAnchor.pelvis, props: const [
    DemoProp.line(Offset(0.0, 0.04), Offset(-0.22, 0.26), width: 0.05),
    DemoProp.line(Offset(-0.1, 0.17), Offset(-0.1, 0.45), width: 0.03),
  ]),
  'resistance_band_row': _row(const Limb(90, 0), const Limb(-40, 130), cable: const Offset(0.62, 0.15), seatedFloor: true),

  // Shoulders
  'overhead_press': _press(),
  'dumbbell_shoulder_press': _press(seated: true),
  'machine_shoulder_press': _press(seated: true),
  'arnold_press': DemoMotion([
    _p(arm: const Limb(10, 160)),
    _p(arm: const Limb(178, 2)),
  ]),
  'lateral_raise': DemoMotion([
    _p(arm: const Limb(8, 10)),
    _p(arm: const Limb(88, 10)),
  ], view: DemoView.front),
  'cable_lateral_raise': DemoMotion([
    _p(arm: const Limb(8, 10), farArm: const Limb(5)),
    _p(arm: const Limb(88, 10), farArm: const Limb(5)),
  ], view: DemoView.front, gearAt: GearAt.nearHand),
  'front_raise': DemoMotion([
    _p(arm: const Limb(5, 5)),
    _p(arm: const Limb(95, 5)),
  ]),
  'rear_delt_fly': DemoMotion([
    _p(t: 70, arm: const Limb(0, 15), leg: const Limb(20, 30, 1, 10)),
    _p(t: 70, arm: const Limb(-20, 15, 0.35), leg: const Limb(20, 30, 1, 10)),
  ]),
  'face_pull': DemoMotion([
    _p(arm: const Limb(100, 0)),
    _p(arm: const Limb(110, 70, 0.55)),
  ], cable: const Offset(0.62, -0.62)),
  'band_pull_apart': DemoMotion([
    _p(arm: const Limb(90, 0, 0.25)),
    _p(arm: const Limb(90, 0)),
  ], view: DemoView.front),
  'pike_push_up': DemoMotion([
    _p(t: 140, arm: const Limb(40, 0), leg: const Limb(-40, 0, 1, 20)),
    _p(t: 152, arm: const Limb(-30, 95), leg: const Limb(-30, 0, 1, 10)),
  ], anchor: DemoAnchor.nearToe),

  // Biceps
  'barbell_curl': _curl(),
  'dumbbell_curl': _curl(),
  'hammer_curl': _curl(top: const Limb(0, 130)),
  'incline_dumbbell_curl': DemoMotion([
    _p(t: -30, arm: const Limb(-5, 0), leg: _seatLeg),
    _p(t: -30, arm: const Limb(-5, 140), leg: _seatLeg),
  ], anchor: DemoAnchor.pelvis, props: const [
    DemoProp.line(Offset(-0.06, 0.03), Offset(-0.24, -0.3), width: 0.05),
    ..._seat,
  ]),
  'preacher_curl': _seated([
    _p(t: 10, arm: const Limb(45, 0), leg: _seatLeg),
    _p(t: 10, arm: const Limb(45, 115), leg: _seatLeg),
  ], back: false),
  'cable_curl': _curl(cable: const Offset(0.35, 0.02)),
  'concentration_curl': _seated([
    _p(t: 40, arm: const Limb(15, 0), farArm: const Limb(60, 30), leg: const Limb(90, 90)),
    _p(t: 40, arm: const Limb(15, 135), farArm: const Limb(60, 30), leg: const Limb(90, 90)),
  ], back: false, gearAt: GearAt.nearHand),
  'band_curl': _curl(cable: const Offset(0.02, 0.0)),

  // Triceps
  'tricep_pushdown': DemoMotion([
    _p(t: 8, arm: const Limb(5, 100)),
    _p(t: 8, arm: const Limb(5, 0)),
  ], cable: const Offset(0.3, -0.95)),
  'overhead_tricep_extension': DemoMotion([
    _p(arm: const Limb(170, 150)),
    _p(arm: const Limb(175, 2)),
  ]),
  'overhead_cable_extension': DemoMotion([
    _p(t: 30, arm: const Limb(150, 140), leg: const Limb(-20, 0), farLeg: const Limb(20, 20)),
    _p(t: 30, arm: const Limb(110, 0), leg: const Limb(-20, 0), farLeg: const Limb(20, 20)),
  ], cable: const Offset(-0.45, -0.6)),
  'skull_crusher': _supine([
    _p(t: -90, arm: const Limb(160, 145), leg: _benchLeg),
    _p(t: -90, arm: const Limb(165, 10), leg: _benchLeg),
  ]),
  'close_grip_bench_press': _benchPress(),
  'tricep_kickback': DemoMotion([
    _p(t: 70, arm: const Limb(-100, 100), leg: const Limb(30, 40, 1, 10)),
    _p(t: 70, arm: const Limb(-100, 0), leg: const Limb(30, 40, 1, 10)),
  ]),
  'bench_dip': DemoMotion([
    _p(t: 5, arm: const Limb(-12, 0), leg: const Limb(80, 0, 1, -40)),
    _p(t: 5, arm: const Limb(-95, 95), leg: const Limb(75, 0, 1, -40)),
  ], anchor: DemoAnchor.nearHand, props: const [
    DemoProp.pad(Offset(-0.25, 0.01), Offset(0.06, 0.06)),
    DemoProp.line(Offset(-0.18, 0.06), Offset(-0.18, 0.45), width: 0.03),
  ]),
  'diamond_push_up': _pushUp(low: const Limb(-140, 175)),

  // Quads
  'barbell_back_squat': _squat(arm: _barOnBack, gearAt: GearAt.shoulders),
  'front_squat': _squat(arm: _frontRack, gearAt: GearAt.chest, lean: 22),
  'goblet_squat': _squat(arm: _gobletHold, gearAt: GearAt.chest, lean: 28),
  'bodyweight_squat': _squat(armDown: const Limb(0)),
  'leg_press': DemoMotion([
    _p(t: -55, arm: const Limb(20, 20), leg: const Limb(160, 120)),
    _p(t: -55, arm: const Limb(20, 20), leg: const Limb(118, 0)),
  ], anchor: DemoAnchor.pelvis, props: const [
    DemoProp.line(Offset(0.0, 0.04), Offset(-0.3, -0.18), width: 0.05),
    DemoProp.line(Offset(0.15, -0.55), Offset(0.62, -0.2), width: 0.04),
  ], floor: false),
  'hack_squat': _squat(arm: _barOnBack, gearAt: GearAt.none, lean: 15),
  'leg_extension': _seated([
    _p(arm: const Limb(20, 10), leg: const Limb(90, 90)),
    _p(arm: const Limb(20, 10), leg: const Limb(90, 0)),
  ]),
  'bulgarian_split_squat': DemoMotion([
    _p(t: 5, leg: const Limb(30, 30, 1, 0), farLeg: const Limb(-20, 110)),
    _p(t: 12, leg: _flat(80, 95), farLeg: const Limb(-30, 115)),
  ], props: const [
    DemoProp.pad(Offset(-0.62, -0.28), Offset(-0.38, -0.23)),
    DemoProp.line(Offset(-0.5, -0.23), Offset(-0.5, 0), width: 0.03),
  ]),
  'walking_lunge': DemoMotion([
    _p(arm: const Limb(5), leg: const Limb(20, 0), farLeg: const Limb(-20, 0, 1, -40)),
    _p(t: 5, arm: const Limb(5), leg: _flat(80, 80), farLeg: const Limb(-25, 70, 1, -10)),
  ]),
  'reverse_lunge': DemoMotion([
    _p(),
    _p(t: 5, leg: _flat(80, 80), farLeg: const Limb(-25, 70, 1, -10)),
  ]),
  'step_up': DemoMotion([
    _p(t: 15, leg: _flat(70, 80), farLeg: const Limb(-5, 0)),
    _p(leg: const Limb(0), farLeg: const Limb(25, 60)),
  ], props: const [
    DemoProp.pad(Offset(-0.12, 0.0), Offset(0.22, 0.24)),
  ]),
  'wall_sit': DemoMotion([
    _p(arm: const Limb(0), leg: _flat(90, 90)),
    _p(arm: const Limb(0), leg: _flat(88, 88)),
  ], cycle: _hold, props: const [
    DemoProp.line(Offset(-0.26, -0.75), Offset(-0.26, 0.03), width: 0.04),
  ]),
  'jump_squat': DemoMotion([
    _p(t: 40, arm: const Limb(-30, 20), leg: _flat(80, 105)),
    _p(t: 0, arm: const Limb(150, 0), leg: const Limb(0, 0, 1, -40), shift: const Offset(0, -0.12)),
  ], cycle: _quick),
  'burpee': DemoMotion([
    _p(t: 0, arm: const Limb(170, 0), shift: const Offset(0, -0.08)),
    _p(t: 50, arm: const Limb(30, 0), leg: _flat(95, 125)),
    _p(t: 66, leg: const Limb(-114, 0, 1, 70), shift: const Offset(-0.45, 0)),
    _p(t: 50, arm: const Limb(30, 0), leg: _flat(95, 125)),
  ], cycle: const Duration(milliseconds: 3200)),

  // Hamstrings
  'romanian_deadlift': _hinge(),
  'dumbbell_romanian_deadlift': _hinge(),
  'single_leg_rdl': DemoMotion([
    _p(t: 5, farLeg: const Limb(-10, 10)),
    _p(t: 80, leg: const Limb(15, 20, 1, 5), farLeg: const Limb(-95, 0, 1, 60)),
  ], gearAt: GearAt.nearHand),
  'good_morning': _hinge(t: 75, leg: const Limb(15, 20, 1, 5), arm: _barOnBack, gearAt: GearAt.shoulders),
  'lying_leg_curl': DemoMotion([
    _p(t: 90, arm: const Limb(30, 120), leg: const Limb(-90, 0, 1, 0)),
    _p(t: 90, arm: const Limb(30, 120), leg: const Limb(-90, 110, 1, 0)),
  ], anchor: DemoAnchor.pelvis, props: const [
    DemoProp.pad(Offset(-0.3, 0.03), Offset(0.38, 0.08)),
    DemoProp.line(Offset(0.0, 0.08), Offset(0.0, 0.3), width: 0.03),
  ]),
  'seated_leg_curl': _seated([
    _p(t: -10, arm: const Limb(20, 10), leg: const Limb(90, 0)),
    _p(t: -10, arm: const Limb(20, 10), leg: const Limb(90, 100)),
  ]),
  'nordic_curl': DemoMotion([
    _p(arm: const Limb(30, 60), leg: const Limb(0, 90, 1, -90)),
    _p(t: 55, arm: const Limb(80, 40), leg: const Limb(55, 145, 1, -90)),
  ], anchor: DemoAnchor.nearKnee, cycle: const Duration(milliseconds: 3400)),

  // Glutes
  'hip_thrust': _bridge(low: -70, high: -95, props: const [
    DemoProp.pad(Offset(-0.62, -0.2), Offset(-0.36, -0.15)),
    DemoProp.line(Offset(-0.5, -0.15), Offset(-0.5, 0.02), width: 0.03),
  ]),
  'sumo_deadlift': _hinge(t: 45, leg: _flat(60, 70)),
  'glute_bridge': _bridge(),
  'single_leg_glute_bridge': _bridge(farLeg: const Limb(150, 30)),
  'cable_kickback': DemoMotion([
    _p(t: 20, arm: const Limb(60, 20), leg: const Limb(10, 20), farLeg: const Limb(0)),
    _p(t: 20, arm: const Limb(60, 20), leg: const Limb(-40, 10), farLeg: const Limb(0)),
  ], anchor: DemoAnchor.pelvis, gearAt: GearAt.none),
  'hip_abduction_machine': DemoMotion([
    _p(arm: const Limb(15, 10), leg: const Limb(4)),
    _p(arm: const Limb(15, 10), leg: const Limb(28)),
  ], view: DemoView.front, anchor: DemoAnchor.pelvis),
  'banded_lateral_walk': DemoMotion([
    _p(t: 0, arm: const Limb(20, 60), leg: const Limb(5, 25)),
    _p(t: 0, arm: const Limb(20, 60), leg: const Limb(22, 25), shift: const Offset(0.05, 0)),
  ], view: DemoView.front, anchor: DemoAnchor.pelvis),
  'kettlebell_swing': DemoMotion([
    _p(t: 60, arm: const Limb(-25, 0), leg: _flat(40, 50)),
    _p(t: 0, arm: const Limb(90, 0)),
  ], cycle: const Duration(milliseconds: 1800), gearAt: GearAt.nearHand),

  // Calves
  'standing_calf_raise': _calfRaise(),
  'seated_calf_raise': _calfRaise(seated: true),
  'single_leg_calf_raise': _calfRaise(single: true),

  // Core
  'plank': DemoMotion([
    _p(t: 82, arm: const Limb(0, 90), leg: const Limb(-98, 0, 1, 70)),
    _p(t: 80, arm: const Limb(0, 90), leg: const Limb(-100, 0, 1, 70)),
  ], anchor: DemoAnchor.nearToe, cycle: _hold),
  'side_plank': DemoMotion([
    _p(t: 72, arm: const Limb(0, 90), farArm: const Limb(180), leg: const Limb(-108, 0, 1, 80)),
    _p(t: 70, arm: const Limb(0, 90), farArm: const Limb(180), leg: const Limb(-110, 0, 1, 80)),
  ], anchor: DemoAnchor.nearToe, cycle: _hold),
  'dead_bug': _supine([
    _p(t: -90, arm: const Limb(180), leg: const Limb(180, 90)),
    _p(t: -90, arm: const Limb(180), farArm: const Limb(-100), leg: const Limb(180, 90), farLeg: const Limb(100, 0)),
  ], props: const []),
  'bird_dog': DemoMotion([
    _p(t: 90, arm: const Limb(0), leg: const Limb(0, 90, 1, -90)),
    _p(t: 90, arm: const Limb(0), farArm: const Limb(90), leg: const Limb(-90, 0), farLeg: const Limb(0, 90, 1, -90)),
  ], anchor: DemoAnchor.farKnee, cycle: _hold),
  'crunch': _supine([
    _p(t: -90, arm: const Limb(-150, 160), leg: const Limb(135, 125)),
    _p(t: -60, arm: const Limb(-150, 160), leg: const Limb(135, 125)),
  ], props: const []),
  'bicycle_crunch': _supine([
    _p(t: -70, arm: const Limb(-150, 160), leg: const Limb(150, 120), farLeg: const Limb(100, 0)),
    _p(t: -70, arm: const Limb(-150, 160), leg: const Limb(100, 0), farLeg: const Limb(150, 120)),
  ], props: const [], cycle: const Duration(milliseconds: 2000)),
  'russian_twist': _supine([
    _p(t: -40, arm: const Limb(70, 40), leg: const Limb(130, 100)),
    _p(t: -40, arm: const Limb(70, 40, 0.4), leg: const Limb(130, 100)),
  ], props: const [], cycle: const Duration(milliseconds: 1800)),
  'leg_raise': _supine([
    _p(t: -90, arm: const Limb(90), leg: const Limb(95, 0)),
    _p(t: -90, arm: const Limb(90), leg: const Limb(178, 0)),
  ], props: const []),
  'hanging_knee_raise': DemoMotion([
    _p(arm: const Limb(178, 0)),
    _p(arm: const Limb(178, 0), leg: const Limb(100, 100)),
  ], anchor: DemoAnchor.nearHand, floor: false, props: const [
    DemoProp.line(Offset(-0.2, 0), Offset(0.2, 0), width: 0.025),
  ]),
  'mountain_climber': DemoMotion([
    _p(t: 64, leg: const Limb(10, 120), farLeg: const Limb(-116, 0, 1, 70)),
    _p(t: 64, leg: const Limb(-116, 0, 1, 70), farLeg: const Limb(10, 120)),
  ], anchor: DemoAnchor.nearHand, cycle: _quick),
  'pallof_press': DemoMotion([
    _p(arm: const Limb(25, 145)),
    _p(arm: const Limb(90, 0)),
  ], cable: const Offset(-0.1, -0.45), gearAt: GearAt.none),

  // Stretches
  'chest_doorway_stretch': _stretch(
    _p(t: 5, arm: const Limb(-80, 90), farArm: const Limb(0)),
    _p(t: 12, arm: const Limb(-95, 90), farArm: const Limb(0), leg: const Limb(10, 15)),
    props: const [DemoProp.line(Offset(-0.12, -0.95), Offset(-0.12, 0.03), width: 0.03)],
  ),
  'cross_body_shoulder_stretch': _stretch(
    _p(arm: const Limb(-90, 0, 0.8), farArm: const Limb(-40, 100)),
    _p(arm: const Limb(-90, 0, 0.7), farArm: const Limb(-45, 105)),
    view: DemoView.front,
  ),
  'cat_cow': DemoMotion([
    _p(t: 96, head: 35, leg: const Limb(0, 90, 1, -90)),
    _p(t: 84, head: -35, leg: const Limb(0, 90, 1, -90)),
  ], anchor: DemoAnchor.nearKnee, cycle: _hold),
  'childs_pose': _stretch(
    _p(t: 118, arm: const Limb(100, 0), leg: const Limb(70, 160, 1, -90)),
    _p(t: 122, arm: const Limb(98, 0), leg: const Limb(68, 158, 1, -90)),
    anchor: DemoAnchor.nearKnee,
  ),
  'cobra_stretch': DemoMotion([
    _p(t: 88, arm: const Limb(-130, 170), leg: const Limb(-90, 0, 1, -90)),
    _p(t: 55, arm: const Limb(-5, 0), leg: const Limb(-90, 0, 1, -90)),
  ], anchor: DemoAnchor.pelvis, cycle: _hold),
  'standing_quad_stretch': _stretch(
    _p(arm: const Limb(-30, 20), farArm: const Limb(60, 10), leg: const Limb(0, 160), farLeg: const Limb(0)),
    _p(arm: const Limb(-35, 20), farArm: const Limb(60, 10), leg: const Limb(-8, 165), farLeg: const Limb(0)),
    anchor: DemoAnchor.pelvis,
  ),
  'hamstring_stretch': _stretch(
    _p(t: 40, arm: const Limb(110, 0), leg: const Limb(90, 0, 1, -60)),
    _p(t: 58, arm: const Limb(100, 0), leg: const Limb(90, 0, 1, -60)),
    anchor: DemoAnchor.pelvis,
  ),
  'hip_flexor_stretch': _stretch(
    _p(t: 0, arm: const Limb(0), leg: _flat(85, 85), farLeg: const Limb(-20, 70, 1, -10)),
    _p(t: -8, arm: const Limb(170), leg: _flat(95, 95), farLeg: const Limb(-30, 60, 1, -10)),
  ),
  'figure_four_stretch': _stretch(
    _p(t: -90, arm: const Limb(110, 40), leg: const Limb(140, 110), farLeg: const Limb(120, 30)),
    _p(t: -90, arm: const Limb(120, 40), leg: const Limb(150, 115), farLeg: const Limb(130, 30)),
    anchor: DemoAnchor.pelvis,
  ),

  // Cardio
  'jumping_jack': DemoMotion([
    _p(arm: const Limb(8, 5), leg: const Limb(3)),
    _p(arm: const Limb(165, 10), leg: const Limb(18), shift: const Offset(0, -0.04)),
  ], view: DemoView.front, anchor: DemoAnchor.pelvis, cycle: const Duration(milliseconds: 1100)),
  'step_jack': DemoMotion([
    _p(arm: const Limb(8, 5), leg: const Limb(3)),
    _p(arm: const Limb(165, 10), leg: const Limb(18), farLeg: const Limb(3)),
  ], view: DemoView.front, anchor: DemoAnchor.pelvis, cycle: const Duration(milliseconds: 1600)),
  'high_knees': DemoMotion([
    _p(arm: const Limb(-30, 80), farArm: const Limb(40, 80), leg: const Limb(90, 90), farLeg: const Limb(0, 0, 1, -30)),
    _p(arm: const Limb(40, 80), farArm: const Limb(-30, 80), leg: const Limb(0, 0, 1, -30), farLeg: const Limb(90, 90)),
  ], anchor: DemoAnchor.pelvis, cycle: const Duration(milliseconds: 900)),
  'march_in_place': DemoMotion([
    _p(arm: const Limb(-20, 70), farArm: const Limb(30, 70), leg: const Limb(70, 80), farLeg: const Limb(0)),
    _p(arm: const Limb(30, 70), farArm: const Limb(-20, 70), leg: const Limb(0), farLeg: const Limb(70, 80)),
  ], anchor: DemoAnchor.pelvis, cycle: const Duration(milliseconds: 1500)),
  'skater_hop': DemoMotion([
    _p(arm: const Limb(40, 20), farArm: const Limb(120, 10), leg: const Limb(10, 40), farLeg: const Limb(-25, 60), shift: const Offset(0.18, 0)),
    _p(arm: const Limb(120, 10), farArm: const Limb(40, 20), leg: const Limb(-25, 60), farLeg: const Limb(10, 40), shift: const Offset(-0.18, 0)),
  ], view: DemoView.front, anchor: DemoAnchor.pelvis, cycle: const Duration(milliseconds: 1500)),
  'squat_to_reach': DemoMotion([
    _p(t: 40, arm: const Limb(20, 0), leg: _flat(80, 105)),
    _p(t: 0, arm: const Limb(175, 0), leg: const Limb(0, 0, 1, -25)),
  ], cycle: const Duration(milliseconds: 2000)),
};
