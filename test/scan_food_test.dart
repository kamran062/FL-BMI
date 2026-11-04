import 'dart:convert';

import 'package:bmi_health/features/fuel/barcode/food_product.dart';
import 'package:bmi_health/features/fuel/barcode/scan_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers/app_harness.dart';

final _lookup = FoodLookup(client: MockClient((req) async {
  if (req.url.path.contains('8964000001234')) {
    return http.Response(jsonEncode({
      'status': 1,
      'product': {
        'product_name': 'Digestive biscuits',
        'serving_quantity': 30,
        'nutriments': {'energy-kcal_100g': 480, 'proteins_100g': 7.2},
      }
    }), 200);
  }
  return http.Response(jsonEncode({'status': 0}), 200);
}));

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
    }
  }

  Future<ScanFoodScreenState> open(WidgetTester tester, {VoidCallback? onManual}) async {
    final app = await launchApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute<void>(
      builder: (_) => ScanFoodScreen(
        onClose: nav.pop,
        onManual: onManual ?? () {},
        lookup: _lookup,
        camera: false,
      ),
    ));
    await tester.pumpAndSettle();
    expect(app.fuel.food, isEmpty);
    return tester.state<ScanFoodScreenState>(find.byType(ScanFoodScreen));
  }

  testWidgets('scan → serving pre-filled → log adds calories and protein',
      (tester) async {
    final screen = await open(tester);
    await tester.runAsync(() => screen.handleCode('8964000001234'));
    await tester.pumpAndSettle();

    expect(find.text('Digestive biscuits'), findsOneWidget);
    expect(find.text('144 kcal · 2.2 g protein'), findsOneWidget); // 30 g serving

    await tester.tap(find.text('100 g'));
    await tester.pumpAndSettle();
    expect(find.text('480 kcal · 7.2 g protein'), findsOneWidget);

    await tester.tap(find.text('Log it'));
    await settleIO(tester);
    expect(find.byType(ScanFoodScreen), findsNothing);
    expect(find.text('Logged: Digestive biscuits'), findsOneWidget);
  });

  testWidgets('unknown product offers manual entry', (tester) async {
    var manual = 0;
    final screen = await open(tester, onManual: () => manual++);
    await tester.runAsync(() => screen.handleCode('99999999'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Product not found'), findsOneWidget);
    await tester.tap(find.text('Enter manually'));
    await tester.pumpAndSettle();
    expect(manual, 1);
    expect(find.byType(ScanFoodScreen), findsNothing);
  });
}
