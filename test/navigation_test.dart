import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> launchApp(WidgetTester tester) async {
    // iPhone 14-sized screen instead of the default 800×600 test surface
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    PackageInfo.setMockInitialValues(
      appName: 'BMI Health', packageName: 'com.bmihealth.bmi_health',
      version: '1.0.1', buildNumber: '3', buildSignature: '',
    );
    final provider = AppProvider();
    await tester.runAsync(provider.init);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const BmiHealthApp(),
      ),
    );
    // Splash hands off after 2.6 s
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('returning user lands on the Calculate tab', (tester) async {
    await launchApp(tester);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('back on another tab returns to Calculate', (tester) async {
    await launchApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Dark mode'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Dark mode'), findsNothing);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });

  testWidgets('back closes the result page', (tester) async {
    await launchApp(tester);
    await tester.ensureVisible(find.text('Calculate BMI'));
    await tester.tap(find.text('Calculate BMI'));
    await tester.pumpAndSettle();
    expect(find.text('Your result'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Your result'), findsNothing);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });
}
