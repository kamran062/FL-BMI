import 'package:bmi_health/features/train/rep_counter/rep_counter_screen.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // Regression (found on device): the camera start read localisations in
  // initState, which threw before the permission prompt could appear.
  testWidgets('opens without throwing and reports a missing camera',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepCounterScreen(onClose: () {}),
    ));
    await tester.pump();
    // Let the (missing) camera plugin call fail for real
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    // No camera plugin in tests → the friendly "no camera" message
    expect(find.text('No camera is available on this device.'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
  });
}
