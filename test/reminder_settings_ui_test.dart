import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> openNotifications(WidgetTester tester, String row) async {
    await openSettings(tester);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(row), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  testWidgets('a reminder that is on shows its schedule; tapping edits it',
      (tester) async {
    final app = await launchApp(tester, prefs: {'workout_reminder': true});
    await openNotifications(tester, 'Workout-day reminders');
    // Profile default of 3 days a week → Mon, Wed, Fri
    expect(find.text('Mon, Wed, Fri at 6:00 PM'), findsOneWidget);
    // Off reminders show no schedule
    expect(find.textContaining('Every day at'), findsNothing);

    await tester.tap(find.text('Workout-day reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Tue'));
    await tester.tap(find.widgetWithText(FilterChip, 'Fri'));
    await tester.pumpAndSettle();
    expect(find.text('Mon, Tue, Wed at 6:00 PM'), findsWidgets);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));

    expect(app.settings.reminders.workoutDays, {1, 2, 3});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('workout_reminder_days')?.toSet(), {'1', '2', '3'});
    expect(find.text('Mon, Tue, Wed at 6:00 PM'), findsOneWidget);
  });

  testWidgets('workout reminder needs at least one day', (tester) async {
    await launchApp(tester, prefs: {
      'workout_reminder': true,
      'workout_reminder_days': ['3'],
    });
    await openNotifications(tester, 'Workout-day reminders');
    await tester.tap(find.text('Workout-day reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Wed'));
    await tester.pumpAndSettle();
    expect(find.text('Choose at least one day.'), findsOneWidget);
  });

  testWidgets('water reminder interval', (tester) async {
    final app = await launchApp(tester, prefs: {'water_reminder': true});
    await openNotifications(tester, 'Water reminders');
    expect(find.text('Every 2 h, 9:00 AM–9:00 PM'), findsOneWidget);
    await tester.tap(find.text('Water reminders'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '3 h'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(app.settings.reminders.waterEveryHours, 3);
    expect(find.text('Every 3 h, 9:00 AM–9:00 PM'), findsOneWidget);
  });

  testWidgets('step goal can be changed from Settings', (tester) async {
    final app = await launchApp(tester);
    await openSettings(tester);
    await tester.pumpAndSettle();
    expect(find.text('Daily step goal'), findsOneWidget);
    expect(find.text('8,000'), findsOneWidget);
    await tester.tap(find.text('Daily step goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '10,000'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    expect(app.steps.goal, 10000);
    expect(find.text('10,000'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('steps_goal'), 10000);
  });
}
