import 'dart:convert';

import 'package:bmi_health/features/coach/ai_client.dart';
import 'package:bmi_health/features/coach/photo_estimate_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  Future<void> settleIO(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('hidden when not configured', (tester) async {
    await launchApp(tester);
    expect(find.text('AI coach'), findsNothing);
    await tester.tap(find.text('Fuel'));
    await tester.pumpAndSettle();
    expect(find.text('Photo estimate'), findsNothing);
  });

  testWidgets('coach: consent once, sends profile, shows reply, handles limit',
      (tester) async {
    final sent = <Map<String, dynamic>>[];
    var limited = false;
    final ai = AiClient(
      coachUrl: 'https://example.test/coach',
      foodUrl: '',
      client: MockClient((req) async {
        sent.add(jsonDecode(req.body) as Map<String, dynamic>);
        if (limited) return http.Response('{"error":"daily_limit"}', 429);
        return http.Response(jsonEncode({'reply': 'Aim for 1.6 g/kg protein.'}), 200);
      }),
    );
    await launchApp(tester, ai: ai);
    await tester.tap(find.text('AI coach'));
    await tester.pumpAndSettle();
    expect(find.textContaining("I'm not a doctor"), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'How much protein?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Before you start'), findsOneWidget); // consent first
    await tester.tap(find.text('I agree'));
    await settleIO(tester);

    expect(find.text('Aim for 1.6 g/kg protein.'), findsOneWidget);
    final body = sent.single;
    expect((body['messages'] as List).single, {'role': 'user', 'content': 'How much protein?'});
    expect(body['profile'], containsPair('sex', 'female'));
    expect(body['profile'], isNot(contains('name')));
    expect(body['installId'], hasLength(32));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AiClient.consentKey), isTrue);

    // Second question: no consent dialog; limit reached message
    limited = true;
    await tester.enterText(find.byType(TextField), 'And carbs?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await settleIO(tester);
    expect(find.text('Before you start'), findsNothing);
    expect(find.textContaining("today's limit"), findsOneWidget);
    // The failed question is not sent again as history next time
    expect((sent.last['messages'] as List).length, 3);
  });

  testWidgets('photo estimate: labelled estimate, logs only selected items',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final app = await launchApp(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute<void>(
      builder: (_) => PhotoEstimateScreen(
        estimate: Future.value(const FoodEstimate(true, [
          FoodItem('Chicken biryani', 350, 610, 28.4),
          FoodItem('Raita', 100, 70, 3.5),
        ], 'medium')),
        onClose: nav.pop,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('AI estimate from a photo'), findsOneWidget);
    expect(find.text('Total: 680 kcal'), findsOneWidget);

    await tester.tap(find.text('Raita'));
    await tester.pumpAndSettle();
    expect(find.text('Total: 610 kcal'), findsOneWidget);
    await tester.tap(find.text('Log selected'));
    await settleIO(tester);

    expect(app.fuel.food.single.name, 'Chicken biryani (estimate)');
    expect(app.fuel.food.single.kcal, 610);
  });
}
