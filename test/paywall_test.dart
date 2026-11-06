import 'package:bmi_health/features/premium/paywall_screen.dart';
import 'package:bmi_health/features/premium/entitlement.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(() {
    setUpAppHarness();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('paywall shows no invented prices or features', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: PurchaseService(store: MemoryEntitlementStore()), // no store products loaded
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PaywallScreen(onClose: () {}),
      ),
    ));
    await tester.pumpAndSettle();

    // Prices only ever come from the store
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.textContaining('save'), findsNothing);
    expect(find.text('…'), findsNWidgets(3));

    // Only real benefits are advertised
    expect(find.text('No banner or full-screen ads'), findsOneWidget);
    for (final fake in ['AI', 'cloud backup', '500+', 'charts']) {
      expect(find.textContaining(fake), findsNothing, reason: fake);
    }

    // Buying without store products explains instead of failing silently
    await tester.ensureVisible(find.text('Upgrade now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upgrade now'));
    await tester.pumpAndSettle();
    expect(find.text('The store is not available on this device.'), findsOneWidget);
  });

  testWidgets('no premium row in Settings when premium is not configured',
      (tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Go Premium'), findsNothing);
  });
}
