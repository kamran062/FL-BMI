import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  testWidgets('returning user lands on Today', (tester) async {
    await launchApp(tester);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('back on another tab returns to Today', (tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Dark mode'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Dark mode'), findsNothing);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('calculator opens from Body; back closes the result page',
      (tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Body'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Calculate BMI'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculate BMI'));
    await tester.pumpAndSettle();
    expect(find.text('BMI Calculator'), findsOneWidget);

    await tester.ensureVisible(find.text('Calculate BMI').last);
    await tester.tap(find.text('Calculate BMI').last);
    await tester.pumpAndSettle();
    expect(find.text('Your result'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Your result'), findsNothing);
    expect(find.text('BMI Calculator'), findsOneWidget);
  });
}
