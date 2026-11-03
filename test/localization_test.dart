import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_health/l10n/l10n.dart';

import 'helpers/app_harness.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  setUpAll(setUpAppHarness);

  group('translation files', () {
    test('Urdu has exactly the same strings as English', () {
      final en = _messageKeys(_arb('en'));
      final ur = _messageKeys(_arb('ur'));
      expect(en.difference(ur), isEmpty, reason: 'missing in app_ur.arb');
      expect(ur.difference(en), isEmpty, reason: 'only in app_ur.arb');
    });

    test('every English string has a description for translators', () {
      final en = _arb('en');
      for (final key in _messageKeys(en)) {
        final meta = en['@$key'] as Map<String, dynamic>?;
        expect(meta?['description'], isNotEmpty, reason: key);
      }
    });

    test('Urdu keeps every {placeholder} of the English string', () {
      final en = _arb('en'), ur = _arb('ur');
      final placeholder = RegExp(r'\{(\w+)\}');
      for (final key in _messageKeys(en)) {
        final want = placeholder.allMatches(en[key] as String).map((m) => m[1]).toSet();
        final got = placeholder.allMatches(ur[key] as String).map((m) => m[1]).toSet();
        expect(got, want, reason: key);
      }
    });
  });

  test('every BMI category has full advice in both languages', () {
    for (final locale in const [Locale('en'), Locale('ur')]) {
      final l = lookupAppLocalizations(locale);
      for (final key in ['under', 'normal', 'over', 'obese']) {
        final advice = l.bmiAdvice(key);
        expect(advice.headline, isNotEmpty, reason: '$locale $key');
        expect(advice.copy, isNotEmpty, reason: '$locale $key');
        expect(advice.steps, hasLength(6), reason: '$locale $key');
        expect(advice.steps.every((s) => s.isNotEmpty), isTrue);
        expect(advice.note, isNotEmpty, reason: '$locale $key');
      }
    }
  });

  testWidgets('English is the default', (tester) async {
    await launchApp(tester);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('choosing Urdu shows Urdu text right-to-left', (tester) async {
    await launchApp(tester, prefs: {'language': 'ur'});

    expect(find.text('بی ایم آئی معلوم کریں'), findsOneWidget); // Calculate BMI
    expect(find.text('ترتیبات'), findsOneWidget); // Settings tab
    final dir = Directionality.of(tester.element(find.text('بی ایم آئی معلوم کریں')));
    expect(dir, TextDirection.rtl);
  });

  testWidgets('back navigation still works in Urdu', (tester) async {
    await launchApp(tester, prefs: {'language': 'ur'});
    await tester.tap(find.text('ترتیبات'));
    await tester.pumpAndSettle();
    expect(find.text('ڈارک موڈ'), findsOneWidget); // Dark mode

    await pressBack(tester);
    expect(find.text('بی ایم آئی معلوم کریں'), findsOneWidget);
  });
}
