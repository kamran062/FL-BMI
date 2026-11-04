import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/movement/domain/timeline.dart';
import 'package:bmi_health/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  testWidgets('a long silence is explained, with a fix guide', (tester) async {
    final app = await launchApp(tester, prefs: {'tracking_enabled': true});
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day, 0, 5);
    final db = tester.element(find.byType(Scaffold).first).read<DatabaseHelper>();
    await tester.runAsync(() async {
      for (final m in [0, 5, 10, 100, 105]) { // 90-min silence after 0:15
        await db.insertPoint(LocationPoint(
            time: d0.add(Duration(minutes: m)), lat: 31.5, lng: 74.3, accuracyM: 5));
      }
      await app.movement.refresh();
    });
    await tester.pumpAndSettle();
    expect(app.movement.gaps, hasLength(1));

    await tester.scrollUntilVisible(find.text('YOUR DAY'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('YOUR DAY'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tracking stopped from'), findsOneWidget);
    await tester.tap(find.text('How to keep tracking on'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Xiaomi'), findsOneWidget);
    expect(find.textContaining('Samsung'), findsOneWidget);
  });

  testWidgets('battery saver is remembered', (tester) async {
    final app = await launchApp(tester, prefs: {'tracking_enabled': true});
    await tester.runAsync(() => app.movement.setBatterySaver(true, lookupAppLocalizations(const Locale('en'))));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('tracking_battery_saver'), isTrue);
    expect(app.movement.batterySaver, isTrue);
  });
}
