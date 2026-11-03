import 'dart:io';
import 'dart:math' as math;

import 'package:bmi_health/features/train/exercises/domain/exercise.dart';

import 'package:bmi_health/features/train/rep_counter/rep_logic.dart';
import 'package:flutter_test/flutter_test.dart';

JointPoint jp(double x, double y, [double l = 0.95]) => (x: x, y: y, likelihood: l);

/// A leg (hip–knee–ankle) with the knee bent to [deg] degrees, side view.
Pose leg(double deg, {double likelihood = 0.95}) {
  const knee = (x: 0.5, y: 0.6);
  final rad = deg * math.pi / 180;
  // thigh straight up from the knee; shin rotated by the knee angle
  return {
    Joint.leftHip: jp(knee.x, knee.y - 0.2, likelihood),
    Joint.leftKnee: jp(knee.x, knee.y, likelihood),
    Joint.leftAnkle: jp(knee.x + 0.2 * math.sin(rad), knee.y - 0.2 * math.cos(rad), likelihood),
  };
}

/// Arm (shoulder–elbow–wrist) bent to [deg]; body straight for push-ups
/// unless [hipDrop] bends shoulder–hip–ankle.
Pose arm(double deg, {double bodyAngle = 175}) {
  const elbow = (x: 0.5, y: 0.5);
  final rad = deg * math.pi / 180;
  final bRad = bodyAngle * math.pi / 180;
  return {
    Joint.leftShoulder: jp(elbow.x, elbow.y - 0.2),
    Joint.leftElbow: jp(elbow.x, elbow.y),
    Joint.leftWrist: jp(elbow.x + 0.2 * math.sin(rad), elbow.y - 0.2 * math.cos(rad)),
    Joint.leftHip: jp(0.3, 0.3),
    Joint.leftAnkle: jp(0.3 + 0.3 * math.sin(bRad), 0.3 - 0.3 * math.cos(bRad)),
  };
}

/// Feeds a smooth up→down→up cycle (each angle 3× so smoothing settles).
int cycle(RepCounter c, Pose Function(double) pose, double top, double bottom) {
  var counted = 0;
  final down = [for (var a = top; a >= bottom; a -= 10) a];
  for (final a in [...down, ...down.reversed]) {
    for (var i = 0; i < 3; i++) {
      if (c.update(pose(a))) counted++;
    }
  }
  return counted;
}

void main() {
  test('angle at the middle joint', () {
    expect(PoseMath.angle(jp(0, 1), jp(0, 0), jp(1, 0)), closeTo(90, 0.01));
    expect(PoseMath.angle(jp(0, 1), jp(0, 0), jp(0, -1)), closeTo(180, 0.01));
    final l = leg(120);
    expect(PoseMath.angle(l[Joint.leftHip]!, l[Joint.leftKnee]!, l[Joint.leftAnkle]!),
        closeTo(120, 0.01));
  });

  test('three deep squats count as three reps with no cue', () {
    final c = RepCounter(CountedExercise.squat);
    for (var i = 0; i < 3; i++) {
      cycle(c, leg, 175, 80);
    }
    expect(c.reps, 3);
    expect(c.cue, isNull);
  });

  test('shallow squat still counts but asks to go lower', () {
    final c = RepCounter(CountedExercise.squat);
    cycle(c, leg, 175, 105);
    expect(c.reps, 1);
    expect(c.cue, FormCue.goLower);
  });

  test('jitter around one angle never counts a rep', () {
    final c = RepCounter(CountedExercise.squat);
    for (var i = 0; i < 60; i++) {
      c.update(leg(i.isEven ? 130 : 140));
    }
    expect(c.reps, 0);
  });

  test('not reaching the down position is not a rep', () {
    final c = RepCounter(CountedExercise.squat);
    cycle(c, leg, 175, 130);
    expect(c.reps, 0);
  });

  test('low-confidence joints are ignored and ask to step into frame', () {
    final c = RepCounter(CountedExercise.squat);
    c.update(leg(90, likelihood: 0.2));
    expect(c.cue, FormCue.stepIntoFrame);
    expect(c.reps, 0);
  });

  test('push-up with sagging hips gets a cue', () {
    final c = RepCounter(CountedExercise.pushUp);
    cycle(c, (a) => arm(a, bodyAngle: 130), 170, 80);
    expect(c.reps, 1);
    expect(c.cue, FormCue.keepHipsUp);
  });

  test('curls count on the elbow; half reps ask for full extension', () {
    final c = RepCounter(CountedExercise.curl);
    cycle(c, arm, 170, 40);
    expect(c.reps, 1);
    expect(c.cue, isNull);
    cycle(c, arm, 170, 55);
    expect(c.reps, 2);
    expect(c.cue, FormCue.fullExtension);
  });

  test('every counted exercise maps to a catalog exercise', () {
    final catalog = ExerciseCatalog.parse(
        File('assets/exercises/catalog.json').readAsStringSync());
    for (final e in CountedExercise.values) {
      expect(catalog.byId(catalogIdFor(e)), isNotNull, reason: '$e');
    }
  });
}
