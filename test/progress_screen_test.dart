import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  testWidgets('streak card → progress with recap and badges', (tester) async {
    final app = await launchApp(tester);
    expect(find.textContaining('streak'), findsNothing); // no workouts yet

    // Log one workout with a set
    await tester.runAsync(() async {
      final w = app.workouts;
      await w.start(name: 'A');
      await w.addExercise('barbell_bench_press');
      final s = w.setsFor('barbell_bench_press').single;
      await w.updateSet(s.copyWith(weightKg: 60, reps: 10, done: true));
      await w.finish();
    });
    await tester.pumpAndSettle();

    // Progress & badges live on the Me tab
    await tester.tap(find.text('Me').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progress & badges'));
    await tester.pumpAndSettle();

    expect(find.text('This month'), findsOneWidget);
    expect(find.text('1 workout'), findsOneWidget);
    expect(find.text('1 set · 600 kg lifted'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('First workout'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(find.textContaining('of 10 badges'), findsOneWidget);
    // First workout earned → trophy, not a lock
    final tile = find.ancestor(of: find.text('First workout'), matching: find.byType(Row)).first;
    expect(find.descendant(of: tile, matching: find.byIcon(Icons.emoji_events_rounded)),
        findsOneWidget);

    // Last month is empty
    await tester.scrollUntilVisible(find.text('Last month'), -200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing logged in this period yet.'), findsOneWidget);
    expect(find.text('Share'), findsNothing);
  });
}
