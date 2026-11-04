import 'dart:convert';

import 'package:bmi_health/features/fuel/barcode/food_product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response off(Map<String, dynamic>? product) => http.Response(
    jsonEncode(product == null ? {'status': 0} : {'status': 1, 'product': product}), 200);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('parses kcal, protein, serving and a clean name', () {
    final p = FoodProduct.fromOff('8964000001234', {
      'product_name': 'Digestive biscuits',
      'brands': 'Peek Freans, Foo',
      'serving_quantity': 30,
      'nutriments': {'energy-kcal_100g': 480, 'proteins_100g': 7.2},
    })!;
    expect(p.name, 'Digestive biscuits · Peek Freans');
    expect(p.kcalFor(30), 144);
    expect(p.proteinFor(30), 2.2);
    expect(p.servingG, 30);
  });

  test('falls back to kJ when kcal is missing', () {
    final p = FoodProduct.fromOff('12345678',
        {'product_name': 'Juice', 'nutriments': {'energy-kj_100g': 184}})!;
    expect(p.kcalPer100g, 44);
  });

  test('entries without energy (or nonsense energy) are rejected', () {
    expect(FoodProduct.fromOff('12345678', {'product_name': 'X', 'nutriments': {}}), isNull);
    expect(FoodProduct.fromOff('12345678',
        {'nutriments': {'energy-kcal_100g': 5000}}), isNull);
  });

  test('barcode format check', () {
    expect(FoodLookup.isBarcode('8964000001234'), isTrue); // EAN-13
    expect(FoodLookup.isBarcode('12345678'), isTrue); // EAN-8
    expect(FoodLookup.isBarcode('https://example.com'), isFalse); // QR code
  });

  test('lookup: found, cached for offline, not found, no nutrition, offline',
      () async {
    var calls = 0;
    final lookup = FoodLookup(client: MockClient((req) async {
      calls++;
      expect(req.headers['User-Agent'], startsWith('BMIHealth'));
      return switch (req.url.pathSegments.last) {
        '8964000001234.json' => off({
            'product_name': 'Nimko',
            'nutriments': {'energy-kcal_100g': 520}
          }),
        '11111111.json' => off({'product_name': 'Water', 'nutriments': {}}),
        _ => off(null),
      };
    }));

    final ok = await lookup.lookup('8964000001234');
    expect(ok.product!.name, 'Nimko');
    // Second scan comes from the cache (works offline)
    final again = await lookup.lookup('8964000001234');
    expect(again.product!.kcalPer100g, 520);
    expect(calls, 1);

    expect((await lookup.lookup('99999999')).error, LookupError.notFound);
    expect((await lookup.lookup('11111111')).error, LookupError.noNutrition);

    final offline = FoodLookup(client: MockClient((_) async => throw Exception('no net')));
    expect((await offline.lookup('22222222')).error, LookupError.offline);
  });
}
