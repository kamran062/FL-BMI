import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/shared/widgets/app_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

class FakeLock implements AppLock {
  bool allow = true;
  int prompts = 0;
  @override
  Future<bool> canLock() async => true;
  @override
  Future<bool> unlock(String reason) async {
    prompts++;
    return allow;
  }
}

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
    }
  }

  Future<void> openSettingsHere(WidgetTester tester) async {
    await openSettings(tester);
    await tester.pumpAndSettle();
  }

  testWidgets('off by default; opt-in explains, then log a period', (tester) async {
    final app = await launchApp(tester, lock: FakeLock());
    expect(find.text('CYCLE'), findsNothing); // no Today card before opt-in

    await openSettingsHere(tester);
    await tester.scrollUntilVisible(find.text('Cycle tracking'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.descendant(
        of: find.ancestor(of: find.text('Cycle tracking'), matching: find.byType(Row)).first,
        matching: find.byType(AppToggle)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Stored only on this phone'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await settleIO(tester);
    expect(app.cycle.enabled, isTrue);

    // Log a period from the cycle screen
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('CYCLE'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('CYCLE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My period started today'));
    await settleIO(tester);
    expect(find.text('Day 1 · Period'), findsOneWidget);
    expect(find.text('Next period in about 28 days'), findsOneWidget);
    expect(find.text('My period ended today'), findsOneWidget);

    // Symptoms are saved per day
    await tester.scrollUntilVisible(find.text('Cramps'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Cramps'));
    await settleIO(tester);
    expect(app.cycle.symptomsOn(DateTime.now()), isNotEmpty);
  });

  testWidgets('male profile is never offered cycle tracking', (tester) async {
    await launchApp(tester, prefs: {'profile_gender': 'm'});
    await openSettingsHere(tester);
    await tester.scrollUntilVisible(find.text('Dark mode'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Cycle tracking', skipOffstage: false), findsNothing);
  });

  testWidgets('lock hides data until unlocked; delete removes everything',
      (tester) async {
    final lock = FakeLock();
    final app = await launchApp(tester, lock: lock);
    await tester.runAsync(() async {
      await app.cycle.setEnabled(true);
      await app.cycle.startPeriod(DateTime.now().subtract(const Duration(days: 3)));
    });

    // Turning the lock on needs one successful unlock
    lock.allow = false;
    expect(await tester.runAsync(() => app.cycle.setLock(true, 'r')), isFalse);
    lock.allow = true;
    expect(await tester.runAsync(() => app.cycle.setLock(true, 'r')), isTrue);

    // App goes to the background → locked; Today hides the details
    app.cycle.relock();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('CYCLE'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Cycle data is locked.'), findsOneWidget);
    expect(find.textContaining('Day 4'), findsNothing);

    await tester.tap(find.text('CYCLE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock'));
    await settleIO(tester);
    expect(find.textContaining('Day 4'), findsOneWidget);

    // One-tap delete wipes data and turns tracking off
    await tester.runAsync(app.cycle.deleteAll);
    expect(app.cycle.enabled, isFalse);
    expect(app.cycle.periods, isEmpty);
    expect(app.cycle.lockEnabled, isFalse);
  });
}
