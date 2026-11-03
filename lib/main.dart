import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Everything runs inside crash reporting so start-up failures
  // (e.g. a database migration error) are reported too.
  await runWithCrashReporting(() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final db = DatabaseHelper.instance;
    final settings = SettingsProvider();
    final profile = ProfileProvider(ProfileRepository(db));
    final bmi = BmiProvider(db);
    await Future.wait([settings.load(), profile.load(), bmi.load()]);

    runApp(BmiHealthProviders(
      settings: settings,
      profile: profile,
      bmi: bmi,
      child: const BmiHealthApp(),
    ));

    // Ads start after the first frame so launch is never blocked by the network.
    // Consent (UMP) is gathered first; no ad is requested before it completes.
    AdService.instance.initialize();
  });
}
