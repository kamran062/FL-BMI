import 'dart:io';

import 'package:bmi_health/features/fuel/foods/food_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

void main() {
  final catalog = FoodCatalog.parse(File('assets/foods/foods.json').readAsStringSync());

  group('food list', () {
    test('around 150+ foods, unique ids, both languages, sane values', () {
      expect(catalog.foods.length, greaterThanOrEqualTo(150));
      expect(catalog.foods.map((f) => f.id).toSet().length, catalog.foods.length);
      for (final f in catalog.foods) {
        expect(f.en.trim(), isNotEmpty, reason: f.id);
        expect(f.ur.trim(), isNotEmpty, reason: f.id);
        expect(f.portionEn.trim(), isNotEmpty, reason: f.id);
        expect(f.portionUr.trim(), isNotEmpty, reason: f.id);
        expect(f.grams, greaterThan(0), reason: f.id);
        expect(f.kcal, inInclusiveRange(1, 1500), reason: f.id);
        // kcal ≈ 4P + 4C + 9F
        final est = 4 * f.protein + 4 * f.carbs + 9 * f.fat;
        if (f.kcal >= 20) {
          expect((est - f.kcal).abs() / f.kcal, lessThanOrEqualTo(0.15), reason: f.id);
        }
      }
    });

    test('covers everyday Pakistani food', () {
      for (final id in ['roti', 'paratha', 'naan', 'chicken_biryani', 'daal_masoor',
          'chicken_karahi', 'nihari', 'haleem', 'qeema', 'raita', 'lassi_sweet',
          'chai', 'samosa', 'pakora', 'gajar_halwa', 'kheer', 'cholay']) {
        expect(catalog.byId(id), isNotNull, reason: id);
      }
    });

    test('search: English, Urdu, Roman Urdu alias; word starts first', () {
      expect(catalog.search('biryani').first.id, contains('biryani'));
      expect(catalog.search('بریانی').map((f) => f.id), contains('chicken_biryani'));
      expect(catalog.search('chawal').map((f) => f.id), contains('rice_white'));
      expect(catalog.search('anda').map((f) => f.id), contains('egg_boiled'));
      expect(catalog.search('xyzzy'), isEmpty);
      expect(catalog.search('ROTI').first.id, 'roti');
    });

    test('used foods first; empty query lists only used foods', () {
      expect(catalog.search(''), isEmpty);
      final usage = {'beef_biryani': 3, 'roti': 1};
      expect(catalog.search('', usage: usage).map((f) => f.id), ['beef_biryani', 'roti']);
      expect(catalog.search('biryani', usage: usage).first.id, 'beef_biryani');
    });
  });

  testWidgets('Log food: search, pick, double portion fills the fields; recent next time',
      (tester) async {
    setUpAppHarness();
    final app = await launchApp(tester);

    Future<void> settleIO() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await settleIO();

    final search = find.widgetWithText(TextField, 'Search foods (e.g. roti, biryani)');
    expect(search, findsOneWidget);
    await tester.enterText(search, 'chapati');
    await tester.pump();
    await tester.tap(find.text('Roti (chapati)'));
    await tester.pump();
    expect(find.text('Values are approximate.'), findsOneWidget);
    expect(find.widgetWithText(TextField, '120'), findsOneWidget);

    await tester.tap(find.text('2×'));
    await tester.pump();
    expect(find.widgetWithText(TextField, '240'), findsOneWidget);

    // Custom grams: 60 g of a 40 g roti = 1.5 portions
    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Grams eaten'), '60');
    await tester.pump();
    expect(find.widgetWithText(TextField, '180'), findsOneWidget);
    await tester.tap(find.text('2×'));
    await tester.pump();

    await tester.tap(find.text('Save'));
    await settleIO();
    final f = app.fuel.dayFood.single;
    expect((f.name, f.kcal, f.proteinG, f.carbsG, f.fatG),
        ('Roti (chapati)', 240, 8.0, 50.0, 1.2));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(FoodUsage.key), '{"roti":1}');

    // Next time it's offered under Recent without typing
    await tester.ensureVisible(find.text('Log food'));
    await tester.tap(find.text('Log food'));
    await settleIO();
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Roti (chapati)'), findsWidgets);

    // Nothing found: manual entry still works
    await tester.enterText(
        find.widgetWithText(TextField, 'Search foods (e.g. roti, biryani)'), 'xyzzy');
    await tester.pump();
    expect(find.text('Not in the list. Enter the values below.'), findsOneWidget);
  });
}
