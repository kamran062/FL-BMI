import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  setUpAll(setUpAppHarness);

  const needsSetup = {'profile_setup_dismissed': false};

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('a user who has not answered yet is asked after the intro',
      (tester) async {
    await launchApp(tester, prefs: needsSetup);
    expect(find.text('What should we call you?'), findsOneWidget);
    expect(find.text('Step 1 of 7'), findsOneWidget);
  });

  testWidgets('completing every step saves the profile and opens the app',
      (tester) async {
    final app = await launchApp(tester, prefs: needsSetup);

    await tester.enterText(find.byType(TextField), 'Kamran');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Male');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue'); // body: defaults are valid
    await tapText(tester, 'Build muscle');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Beginner');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Gym');
    await tapText(tester, 'Continue');
    await tapText(tester, '4');
    await tapText(tester, 'Finish');

    final p = app.profile.profile;
    expect(p.completed, isTrue);
    expect(p.name, 'Kamran');
    expect(p.gender, 'm');
    expect(p.goal, FitnessGoal.buildMuscle);
    expect(p.experience, Experience.beginner);
    expect(p.equipment, Equipment.gym);
    expect(p.daysPerWeek, 4);
    expect(p.demonstrator, Sex.male);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('"Later" skips setup and does not ask again', (tester) async {
    final app = await launchApp(tester, prefs: needsSetup);
    await tapText(tester, 'Later');

    expect(app.settings.profileSetupDismissed, isTrue);
    expect(app.profile.profile.completed, isFalse);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('goal is required before continuing', (tester) async {
    await launchApp(tester, prefs: needsSetup);
    await tapText(tester, 'Continue'); // name
    await tapText(tester, 'Continue'); // gender
    await tapText(tester, 'Continue'); // body
    expect(find.text('What is your main goal?'), findsOneWidget);

    await tapText(tester, 'Continue'); // disabled: nothing happens
    expect(find.text('What is your main goal?'), findsOneWidget);
  });

  testWidgets('choosing "Other" asks for formula basis and trainer',
      (tester) async {
    await launchApp(tester, prefs: needsSetup);
    await tapText(tester, 'Continue');
    expect(find.text('Calculations based on'), findsNothing);

    await tapText(tester, 'Other');
    expect(find.text('Calculations based on'), findsOneWidget);
    expect(find.text('Exercise videos show'), findsOneWidget);
  });

  testWidgets('body step rejects impossible values', (tester) async {
    await launchApp(tester, prefs: needsSetup);
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue');
    await tester.enterText(find.byType(TextField).first, '5'); // 5 cm
    await tapText(tester, 'Continue');

    expect(find.text('About your body'), findsOneWidget); // still here
    expect(find.textContaining('Enter a height between'), findsOneWidget);
  });

  testWidgets('Settings → Personal details opens the editor prefilled',
      (tester) async {
    final app = await launchApp(tester);
    // Real database I/O must run outside the test's fake clock
    await tester.runAsync(() =>
        app.profile.update(app.profile.profile.copyWith(name: 'Ayesha')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Ayesha'), findsOneWidget); // row shows the name
    await tester.tap(find.text('Personal details'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'Ayesha');

    await pressBack(tester); // step 1: back leaves the editor
    expect(find.text('Dark mode'), findsOneWidget);
  });
}
