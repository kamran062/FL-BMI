import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/features/backup/backup_service.dart';
import 'package:bmi_health/features/backup/backup_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> openSettingsHere(WidgetTester tester) async {
    await openSettings(tester);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Create backup'), 200,
        scrollable: find.byType(Scrollable).first);
  }

  testWidgets('create backup checks the passphrase', (tester) async {
    await launchApp(tester);
    await openSettingsHere(tester);
    expect(find.text('Restore from backup'), findsOneWidget);
    expect(find.text('Export as spreadsheet (CSV)'), findsOneWidget);

    await tester.tap(find.text('Create backup'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Only your passphrase can open it"), findsOneWidget);
    expect(find.text('Include cycle data'), findsNothing); // cycle tracking is off

    await tester.enterText(find.widgetWithText(TextField, 'Passphrase'), 'short');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Passphrase'), 'long enough one');
    await tester.enterText(find.widgetWithText(TextField, 'Repeat passphrase'), 'different one');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text("Passphrases don't match."), findsOneWidget);
  });

  testWidgets('restored data shows up without restarting', (tester) async {
    final app = await launchApp(tester);
    final db = tester.element(find.byType(Scaffold).first).read<DatabaseHelper>();
    final svc = BackupService(db, iterations: 1000);

    // Backup with one weight, then wipe it, then restore
    await tester.runAsync(() async {
      await app.body.logWeight(81.5);
    });
    final file = (await tester.runAsync(
        () => svc.create('long enough one', const BackupOptions())))!;
    await tester.runAsync(() async {
      await (await db.db).delete('weight_logs');
      await app.body.load();
    });
    expect(app.body.weights, isEmpty);

    await tester.runAsync(() async {
      await svc.restore(file, 'long enough one');
      await BackupActions.reloadAll(tester.element(find.byType(Scaffold).first));
    });
    expect(app.body.weights.single.weightKg, 81.5);
  });
}
