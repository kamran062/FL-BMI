import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  /// Lets real database I/O (started by the app) finish, then rebuilds.
  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Taps and lets real database writes finish outside the fake clock.
  Future<void> tapAndSave(WidgetTester tester, Finder f) async {
    await tester.runAsync(() async {
      await tester.tap(f);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
  }

  testWidgets('library filters by muscle and opens an exercise', (tester) async {
    await launchApp(tester);
    await tapText(tester, 'Train');
    await tapText(tester, 'Exercise library');
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'squat');
    await tester.pumpAndSettle();
    expect(find.text('Goblet Squat'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);

    await tapText(tester, 'Goblet Squat');
    expect(find.text('HOW TO DO IT'), findsOneWidget); // overline labels are upper-case
    expect(find.text('Video coming soon'), findsOneWidget);
  });

  testWidgets('log a workout from start to finish', (tester) async {
    final app = await launchApp(tester);
    await tapText(tester, 'Train');
    await tapAndSave(tester, find.text('Start empty workout'));
    await settleIO(tester);
    expect(app.workouts.active, isNotNull);

    // Add an exercise through the picker
    await tapText(tester, 'Add exercise');
    await tester.enterText(find.byType(TextField), 'push-up');
    await tester.pumpAndSettle();
    await tapAndSave(tester, find.text('Push-up'));
    await settleIO(tester);
    expect(app.workouts.activeExercises, ['push_up']);

    // Enter 12 reps and tick the set
    await tester.pump(const Duration(milliseconds: 500));
    final reps = find.byType(TextField).at(1);
    await tester.enterText(reps, '12');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tapAndSave(tester, find.byIcon(Icons.check_circle_outline_rounded));
    await settleIO(tester);
    expect(app.workouts.setsFor('push_up').single.done, isTrue);
    expect(find.textContaining('Rest'), findsOneWidget); // rest timer started

    await tapAndSave(tester, find.text('Finish'));
    await settleIO(tester);
    expect(find.text('Workout complete'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await settleIO(tester);

    expect(app.workouts.active, isNull);
    expect(app.workouts.history, hasLength(1));
  });
}
