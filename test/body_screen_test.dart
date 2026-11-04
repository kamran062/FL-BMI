import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> openBody(WidgetTester tester) async {
    await tester.tap(find.text('Body'));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('empty Body tab explains each card', (tester) async {
    await launchApp(tester);
    await openBody(tester);
    expect(find.text('Log your weight regularly to see your trend.'),
        findsOneWidget);
    // Lower cards are built lazily; scroll down to them
    await tester.scrollUntilVisible(
        find.text('For general wellness only. Not medical advice.'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('No BMI saved yet'), findsOneWidget);
    expect(find.text('For general wellness only. Not medical advice.'),
        findsOneWidget);
  });

  testWidgets('logging a weight saves it and updates the profile weight',
      (tester) async {
    final app = await launchApp(tester);
    await openBody(tester);
    await tapText(tester, 'Log weight');

    await tester.enterText(find.byType(TextField), '82.5');
    // Dialog Save writes to the database: run it outside the fake clock
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(app.body.weights.single.weightKg, 82.5);
    expect(app.profile.profile.weight, 82.5);
    expect(find.text('82.5 kg'), findsOneWidget);
  });

  testWidgets('weight outside the human range is rejected', (tester) async {
    final app = await launchApp(tester);
    await openBody(tester);
    await tapText(tester, 'Log weight');
    await tester.enterText(find.byType(TextField), '0.5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Enter a weight between'), findsOneWidget);
    expect(app.body.weights, isEmpty);
  });

  testWidgets('measurements give a body-fat estimate (female asks hips)',
      (tester) async {
    final app = await launchApp(tester);
    await tester.runAsync(() => app.profile.update(
        app.profile.profile.copyWith(gender: 'f', height: 165)));
    await openBody(tester);
    expect(
        find.text('Add neck, waist and hip measurements to estimate your body fat.'),
        findsOneWidget);

    await tapText(tester, 'Add measurements');
    expect(find.text('Bust'), findsOneWidget); // female wording
    await tester.enterText(find.widgetWithText(TextField, 'Waist'), '76');
    await tester.enterText(find.widgetWithText(TextField, 'Hips'), '98');
    await tester.enterText(find.widgetWithText(TextField, 'Neck'), '33');
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(app.body.latestMeasurement?.waist, 76);
    expect(find.textContaining('%'), findsOneWidget);
  });

  testWidgets('BMI history opens from Body and Back returns', (tester) async {
    final app = await launchApp(tester);
    await tester.runAsync(() => app.bmi.saveResult(const UserProfile()));
    await openBody(tester);
    await tapText(tester, 'View all');
    expect(find.text('History'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('View all'), findsOneWidget);
  });

  testWidgets('History filter sheet closes itself, not the History page',
      (tester) async {
    final app = await launchApp(tester);
    await tester.runAsync(() => app.bmi.saveResult(const UserProfile()));
    await openBody(tester);
    await tapText(tester, 'View all');
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter entries'), findsOneWidget);

    await tapText(tester, 'Apply filter');
    expect(find.text('Filter entries'), findsNothing);
    expect(find.text('History'), findsOneWidget); // still on History
  });
}
