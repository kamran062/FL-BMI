import 'dart:math' as math;

/// Body points the rep counter uses (subset of ML Kit's 33 landmarks).
enum Joint {
  leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist,
  leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle,
}

/// One detected joint: image position plus detection confidence (0–1).
typedef JointPoint = ({double x, double y, double likelihood});

/// A body pose for one camera frame.
typedef Pose = Map<Joint, JointPoint>;

/// Exercises the camera can count (ROADMAP 3.4).
enum CountedExercise { squat, pushUp, curl, shoulderPress, lunge }

/// Form feedback shown live.
enum FormCue { goLower, keepHipsUp, fullExtension, stepIntoFrame }

abstract final class PoseMath {
  /// Angle at [b] formed by a–b–c, in degrees (0–180).
  static double angle(JointPoint a, JointPoint b, JointPoint c) {
    final ab = math.atan2(a.y - b.y, a.x - b.x);
    final cb = math.atan2(c.y - b.y, c.x - b.x);
    var deg = (ab - cb).abs() * 180 / math.pi;
    if (deg > 180) deg = 360 - deg;
    return deg;
  }

  static const minLikelihood = 0.5;

  /// Angle on whichever body side the camera sees best, or null if
  /// neither side is confidently visible.
  static double? sideAngle(Pose p, (Joint, Joint, Joint) left,
      (Joint, Joint, Joint) right) {
    double? side((Joint, Joint, Joint) j) {
      final a = p[j.$1], b = p[j.$2], c = p[j.$3];
      if (a == null || b == null || c == null) return null;
      if ([a, b, c].any((x) => x.likelihood < minLikelihood)) return null;
      return angle(a, b, c);
    }

    double conf((Joint, Joint, Joint) j) =>
        [j.$1, j.$2, j.$3].fold(0.0, (s, k) => s + (p[k]?.likelihood ?? 0));
    final first = conf(left) >= conf(right) ? left : right;
    final second = identical(first, left) ? right : left;
    return side(first) ?? side(second);
  }
}

/// Counts reps from the angle of the exercise's main joint.
///
/// A rep is a full "up → down → up" cycle. Two thresholds with a gap
/// between them (hysteresis) stop jitter around one value from counting
/// extra reps; a 3-frame average smooths detection noise.
class RepCounter {
  RepCounter(this.exercise);

  final CountedExercise exercise;
  int reps = 0;
  FormCue? cue;

  bool _down = false;
  double _deepest = 180;
  final _recent = <double>[];

  /// (down threshold, up threshold, depth for a "good" rep) in degrees.
  ({double down, double up, double good}) get _t => switch (exercise) {
        CountedExercise.squat => (down: 110, up: 160, good: 95),
        CountedExercise.lunge => (down: 110, up: 155, good: 100),
        CountedExercise.pushUp => (down: 100, up: 150, good: 90),
        CountedExercise.curl => (down: 60, up: 140, good: 50),
        CountedExercise.shoulderPress => (down: 90, up: 155, good: 80),
      };

  /// Main joint angle for this exercise.
  double? _angle(Pose p) => switch (exercise) {
        CountedExercise.squat || CountedExercise.lunge => PoseMath.sideAngle(p,
            (Joint.leftHip, Joint.leftKnee, Joint.leftAnkle),
            (Joint.rightHip, Joint.rightKnee, Joint.rightAnkle)),
        CountedExercise.pushUp ||
        CountedExercise.curl ||
        CountedExercise.shoulderPress =>
          PoseMath.sideAngle(p,
              (Joint.leftShoulder, Joint.leftElbow, Joint.leftWrist),
              (Joint.rightShoulder, Joint.rightElbow, Joint.rightWrist)),
      };

  /// Feeds one frame. Returns true when this frame completed a rep.
  bool update(Pose pose) {
    final raw = _angle(pose);
    if (raw == null) {
      cue = FormCue.stepIntoFrame;
      return false;
    }
    if (cue == FormCue.stepIntoFrame) cue = null;
    _recent.add(raw);
    if (_recent.length > 3) _recent.removeAt(0);
    final a = _recent.reduce((x, y) => x + y) / _recent.length;

    if (exercise == CountedExercise.pushUp) _checkHips(pose);

    final t = _t;
    if (!_down && a < t.down) {
      _down = true;
      _deepest = a;
    } else if (_down) {
      if (a < _deepest) _deepest = a;
      if (a > t.up) {
        _down = false;
        reps++;
        cue = _deepest > t.good
            ? (exercise == CountedExercise.curl ||
                    exercise == CountedExercise.shoulderPress
                ? FormCue.fullExtension
                : FormCue.goLower)
            : (cue == FormCue.keepHipsUp ? cue : null);
        return true;
      }
    }
    return false;
  }

  /// Push-ups: shoulder–hip–ankle should stay nearly straight.
  void _checkHips(Pose p) {
    final body = PoseMath.sideAngle(p,
        (Joint.leftShoulder, Joint.leftHip, Joint.leftAnkle),
        (Joint.rightShoulder, Joint.rightHip, Joint.rightAnkle));
    if (body == null) return;
    if (body < 150) {
      cue = FormCue.keepHipsUp;
    } else if (cue == FormCue.keepHipsUp) {
      cue = null;
    }
  }

  void reset() {
    reps = 0;
    cue = null;
    _down = false;
    _deepest = 180;
    _recent.clear();
  }
}

/// Catalog exercise each counted movement is logged as.
String catalogIdFor(CountedExercise e) => switch (e) {
      CountedExercise.squat => 'bodyweight_squat',
      CountedExercise.pushUp => 'push_up',
      CountedExercise.curl => 'dumbbell_curl',
      CountedExercise.shoulderPress => 'dumbbell_shoulder_press',
      CountedExercise.lunge => 'walking_lunge',
    };
