import 'package:bmi_health/features/recovery/domain/recovery.dart';
import 'package:bmi_health/features/recovery/recovery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

class FakeRecovery implements RecoverySource {
  bool connected = false;
  @override
  Future<bool> available() async => true;
  @override
  Future<bool> hasAccess() async => connected;
  @override
  Future<bool> requestAccess() async => connected = true;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Future<List<SleepNight>> sleepSegments(DateTime from, DateTime to) async => [
        for (var d = 5; d >= 0; d--)
          SleepNight(_today.subtract(Duration(days: d, hours: 1)),
              _today.subtract(Duration(days: d)).add(const Duration(hours: 7))),
      ];
  @override
  Future<List<DailyValue>> restingHr(DateTime from, DateTime to) async => [
        for (var d = 5; d >= 0; d--)
          (day: _today.subtract(Duration(days: d)), value: 58.0)
      ];
  @override
  Future<List<DailyValue>> hrv(DateTime from, DateTime to) async => const [];
}

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('check-in gives a score; connecting adds sleep', (tester) async {
    final fake = FakeRecovery();
    await launchApp(tester, recovery: fake);
    expect(find.text('RECOVERY'), findsOneWidget);
    expect(find.textContaining('Answer the check-in'), findsOneWidget);

    // Soreness 1 → a score appears and is remembered for today
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '1'));
    await tester.tap(find.widgetWithText(ChoiceChip, '1'));
    await settleIO(tester);
    expect(find.text('100 / 100'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().any((k) => k.startsWith('soreness_')), isTrue);

    // Connect → last night's 8 h sleep and the weekly summary appear
    await tester.ensureVisible(find.text('Connect sleep & heart data'));
    await tester.tap(find.text('Connect sleep & heart data'));
    await settleIO(tester);
    expect(find.text('Last night: 8 h 0 min'), findsOneWidget);
    expect(find.textContaining('7-night average'), findsOneWidget);
    expect(find.textContaining('regular'), findsOneWidget);
    // 14-night chart: six nights recorded
    await tester.ensureVisible(find.text('Last 14 nights'));
    expect(find.text('Last 14 nights'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Sleep for the last 14 nights, 6 nights recorded'),
        findsOneWidget);
  });

  test('fortnight has 14 days, oldest first, gaps empty', () async {
    final fake = FakeRecovery()..connected = true;
    final r = RecoveryProvider(source: fake);
    await r.load();
    final f = r.fortnight;
    expect(f.length, 14);
    expect(f.first.day.isBefore(f.last.day), isTrue);
    expect(f.where((n) => n.sleep != null).length, 6);
    expect(f.last.sleep, const Duration(hours: 8));
    expect(f.first.sleep, isNull);
  });
}
