import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('log food and water on Fuel; Today shows the totals', (tester) async {
    final app = await launchApp(tester);
    final target = Nutrition.targetsFor(app.profile.profile).calories;

    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();
    expect(find.text('$target kcal left'), findsOneWidget);

    await tester.tap(find.text('+250 ml'));
    await settleIO(tester);
    expect(app.fuel.waterMl, 250);

    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Calories (kcal)'), '650');
    await tester.enterText(
        find.widgetWithText(TextField, 'What did you eat? (optional)'), 'Biryani');
    await tester.tap(find.text('Save'));
    await settleIO(tester);
    expect(app.fuel.kcal, 650);
    expect(find.text('Biryani'), findsOneWidget);

    // The nav bar's "Today" (the day switcher shows one too)
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    expect(find.text('${target - 650} kcal left'), findsOneWidget);
  });

  testWidgets('Fuel: go back a day, log with macros, edit, chart, back to today',
      (tester) async {
    final app = await launchApp(tester);
    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Previous day'));
    await settleIO(tester);
    expect(app.fuel.viewingToday, isFalse);
    expect(find.text('Yesterday'), findsOneWidget);

    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Calories (kcal)'), '700');
    await tester.enterText(
        find.widgetWithText(TextField, 'What did you eat? (optional)'), 'Nihari');
    await tester.enterText(find.widgetWithText(TextField, 'Carbs (g, optional)'), '20');
    await tester.enterText(find.widgetWithText(TextField, 'Fat (g, optional)'), '45');
    await tester.tap(find.text('Save'));
    await settleIO(tester);
    expect(app.fuel.dayKcal, 700);
    expect(app.fuel.kcal, 0); // today untouched
    expect(find.textContaining('C 20 g · F 45 g'), findsOneWidget);
    expect(find.text('20 / ${Nutrition.targetsFor(app.profile.profile).carbsG} g'),
        findsOneWidget);

    // Edit the entry
    await tester.ensureVisible(find.text('Nihari'));
    await tester.tap(find.text('Nihari'));
    await tester.pumpAndSettle();
    expect(find.text('Edit food'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, '700'), '650');
    await tester.tap(find.text('Save'));
    await settleIO(tester);
    expect(app.fuel.dayFood.single.kcal, 650);
    expect(app.fuel.week.last.kcal, 650);

    // Bad macro value is rejected
    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Calories (kcal)'), '100');
    await tester.enterText(find.widgetWithText(TextField, 'Fat (g, optional)'), '5000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Grams must be between 0 and 1000.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byTooltip('Next day'), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byTooltip('Next day'));
    await settleIO(tester);
    expect(app.fuel.viewingToday, isTrue);
    expect(app.fuel.week[5].kcal, 650);
  });

  testWidgets('calorie entry is validated', (tester) async {
    final app = await launchApp(tester);
    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter calories between 1 and 5000.'), findsOneWidget);
    expect(app.fuel.food, isEmpty);
  });
}
