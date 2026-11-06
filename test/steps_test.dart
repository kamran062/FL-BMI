import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

class FakeSteps implements StepsSource {
  bool installed = true;
  bool granted = false;
  int steps = 5420;
  int requests = 0;

  @override
  Future<StepsStatus> status({required bool userConnected}) async {
    if (!installed) return StepsStatus.needsInstall;
    return userConnected && granted ? StepsStatus.connected : StepsStatus.notConnected;
  }

  /// Like Health Connect: right after a grant, the permission check still
  /// says "no" until the app is resumed.
  @override
  Future<bool> requestAccess() async {
    requests++;
    return true; // `granted` stays false, as seen on a real device
  }

  @override
  Future<void> install() async => installed = true;

  @override
  Future<int> stepsBetween(DateTime from, DateTime to) async => steps;
}

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('never asks for access on its own; Connect shows steps',
      (tester) async {
    final fake = FakeSteps();
    await launchApp(tester, steps: fake);
    expect(fake.requests, 0);
    expect(find.text('Connect'), findsOneWidget);

    await tester.ensureVisible(find.text('Connect'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect'));
    await settleIO(tester);
    expect(fake.requests, 1);
    // The card gets shorter once connected; scroll it back into view
    await tester.ensureVisible(find.text('5420 / 8000', skipOffstage: false));
    await tester.pumpAndSettle();
    expect(find.text('5420 / 8000'), findsOneWidget);
  });

  testWidgets('custom step goal is used on the card and can be changed there',
      (tester) async {
    final fake = FakeSteps();
    final app = await launchApp(tester,
        steps: fake, prefs: {'steps_connected': true, 'steps_goal': 10000});
    fake.granted = true;
    await app.steps.refresh();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('5420 / 10000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5420 / 10000'));
    await tester.pumpAndSettle();
    expect(find.text('Daily step goal'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '6,000'));
    await settleIO(tester);
    expect(find.text('5420 / 6000'), findsOneWidget);
  });

  testWidgets('offers Health Connect when it is missing', (tester) async {
    final fake = FakeSteps()..installed = false;
    await launchApp(tester, steps: fake);
    expect(find.text('Get Health Connect'), findsOneWidget);
  });

  testWidgets('card is hidden where health data is unsupported', (tester) async {
    await launchApp(tester); // real source; tests run on desktop
    expect(find.text('STEPS'), findsNothing);
  });
}
