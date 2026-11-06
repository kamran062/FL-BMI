import 'package:bmi_health/app/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('chest day: plan with sets and rest, starts with sets prefilled',
      (tester) async {
    final app = await launchApp(tester);
    await tester.tap(find.text('Train'));
    await tester.pumpAndSettle();
    final chip = find.widgetWithText(ActionChip, 'Chest');
    await tester.scrollUntilVisible(chip, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('Chest workout'), findsOneWidget);
    expect(find.textContaining('exercises ·'), findsOneWidget);
    expect(find.textContaining('sets ×'), findsWidgets);
    expect(find.textContaining('between sets'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Start this workout'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Start this workout'));
    await settleIO(tester);

    final w = app.workouts;
    expect(w.active, isNotNull);
    expect(w.active!.name, 'Chest workout');
    expect(w.activeExercises, isNotEmpty);
    // New exercise → recommended number of sets, reps at the bottom of the range
    final first = w.activeExercises.first;
    expect(w.setsFor(first).length, greaterThanOrEqualTo(3));
    expect(w.setsFor(first).first.reps, greaterThan(0));
  });

  testWidgets('exercise detail shows recommended, tips, mistakes, alternatives',
      (tester) async {
    await launchApp(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .push(Routes.exercise('barbell_bench_press'));
    await tester.pumpAndSettle();

    for (final t in ['RECOMMENDED', 'TIPS', 'COMMON MISTAKES', 'ALTERNATIVES']) {
      await tester.scrollUntilVisible(find.text(t), 200,
          scrollable: find.byType(Scrollable).last);
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('4 sets × 6–8 reps'), findsOneWidget);
    expect(find.text('Rest 2:30 between sets'), findsOneWidget);
  });
}
