import 'dart:io';
import 'dart:ui' as ui;

import 'package:bmi_health/features/train/exercises/demo/demo_library.dart';
import 'package:bmi_health/features/train/exercises/demo/demo_pose.dart';
import 'package:bmi_health/features/train/exercises/demo/exercise_demo.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ExerciseCatalog.parse(File('assets/exercises/catalog.json').readAsStringSync());

  test('every catalog exercise has an animation, and nothing extra', () {
    final ids = catalog.exercises.map((e) => e.id).toSet();
    expect(ids.difference(DemoLibrary.ids.toSet()), isEmpty, reason: 'missing animations');
    expect(DemoLibrary.ids.toSet().difference(ids), isEmpty, reason: 'unknown ids');
  });

  test('every pose is finite and the framing has room', () {
    for (final id in DemoLibrary.ids) {
      final m = DemoLibrary.motionFor(id)!;
      expect(m.frames.length, greaterThanOrEqualTo(2), reason: id);
      for (var i = 0; i <= 20; i++) {
        final s = buildSkeleton(m.poseAt(i / 20), m.view, m.anchor);
        for (final p in s.points) {
          expect(p.dx.isFinite && p.dy.isFinite, isTrue, reason: id);
        }
      }
      final f = DemoFrame.of(m);
      expect(f.bounds.width, greaterThan(0.4), reason: id);
      expect(f.bounds.height, greaterThan(0.4), reason: id);
    }
  });

  test('anchored joint stays put through the cycle (feet on the floor)', () {
    final m = DemoLibrary.motionFor('bodyweight_squat')!;
    for (var i = 0; i <= 10; i++) {
      final s = buildSkeleton(m.poseAt(i / 10), m.view, m.anchor);
      expect(s.ankle[0].distance, lessThan(1e-9));
    }
  });

  test('every animation paints at every phase', () {
    const colors = DemoColors(dark: false, accent: Colors.green, prop: Colors.black12);
    for (final e in catalog.exercises) {
      final m = DemoLibrary.motionFor(e.id)!;
      final frame = DemoFrame.of(m);
      for (final t in [0.0, 0.3, 0.5, 0.8]) {
        for (final female in [false, true]) {
          final rec = ui.PictureRecorder();
          DemoPainter(
            motion: m,
            frame: frame,
            t: t,
            equipment: e.equipment,
            primary: e.primary,
            female: female,
            colors: colors,
          ).paint(Canvas(rec), const Size(300, 200));
          rec.endRecording().dispose();
        }
      }
    }
  });

  testWidgets('demo animates, and holds still when motion is reduced', (tester) async {
    final e = catalog.byId('push_up')!;
    Future<void> pump({required bool still}) => tester.pumpWidget(MediaQuery(
          data: MediaQueryData(disableAnimations: still),
          child: MaterialApp(
            home: SizedBox(width: 300, height: 200, child: ExerciseDemo(exercise: e)),
          ),
        ));
    DemoPainter painter() =>
        tester.widget<CustomPaint>(find.descendant(of: find.byType(ExerciseDemo), matching: find.byType(CustomPaint))).painter!
            as DemoPainter;

    await pump(still: false);
    final t0 = painter().t;
    await tester.pump(const Duration(milliseconds: 700));
    expect(painter().t, isNot(t0));

    await pump(still: true);
    await tester.pump(const Duration(milliseconds: 700));
    final s0 = painter().t;
    await tester.pump(const Duration(milliseconds: 700));
    expect(painter().t, s0);
  });
}
