import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  testWidgets('returning user lands on the Calculate tab', (tester) async {
    await launchApp(tester);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('back on another tab returns to Calculate', (tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Dark mode'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Dark mode'), findsNothing);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('back closes the result page', (tester) async {
    await launchApp(tester);
    await tester.ensureVisible(find.text('Calculate BMI'));
    await tester.tap(find.text('Calculate BMI'));
    await tester.pumpAndSettle();
    expect(find.text('Your result'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Your result'), findsNothing);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });
}
