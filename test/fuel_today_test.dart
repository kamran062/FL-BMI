import 'package:bmi_health/features/fuel/domain/nutrition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
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

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('${target - 650} kcal left'), findsOneWidget);
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
