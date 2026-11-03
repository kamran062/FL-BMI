import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmi_health/app/app.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/core/database/database_helper.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/features/profile/data/profile_repository.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts ship with the app (assets/google_fonts); never download them.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

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
    final body = BodyProvider(db);
    final workouts = WorkoutProvider(db);
    final catalog = await ExerciseCatalog.loadBundled();
    await Future.wait([
      settings.load(), profile.load(), bmi.load(), body.load(), workouts.load(),
    ]);

    runApp(BmiHealthProviders(
      settings: settings,
      profile: profile,
      bmi: bmi,
      body: body,
      workouts: workouts,
      catalog: catalog,
      child: const BmiHealthApp(),
    ));

    // Ads start after the first frame so launch is never blocked by the network.
    // Consent (UMP) is gathered first; no ad is requested before it completes.
    AdService.instance.initialize();
  });
}
