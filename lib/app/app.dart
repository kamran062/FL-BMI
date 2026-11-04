import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/workouts/workout_provider.dart';
import 'package:bmi_health/features/fuel/fuel_provider.dart';
import 'package:bmi_health/features/movement/steps_provider.dart';
import 'package:bmi_health/features/movement/movement_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/app/router.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_theme.dart';
import 'package:bmi_health/features/premium/purchase_service.dart';
import 'package:bmi_health/features/recovery/recovery_provider.dart';
import 'package:bmi_health/features/cycle/cycle_provider.dart';
import 'package:bmi_health/features/body/photos/photos_provider.dart';

/// Supplies the app-wide state objects. Used by main() and by tests.
class BmiHealthProviders extends StatelessWidget {
  const BmiHealthProviders({
    super.key,
    required this.settings,
    required this.profile,
    required this.bmi,
    required this.body,
    required this.workouts,
    required this.fuel,
    required this.steps,
    required this.movement,
    required this.purchases,
    required this.recovery,
    required this.cycle,
    required this.photos,
    required this.catalog,
    required this.child,
  });

  final SettingsProvider settings;
  final ProfileProvider profile;
  final BmiProvider bmi;
  final BodyProvider body;
  final WorkoutProvider workouts;
  final FuelProvider fuel;
  final StepsProvider steps;
  final MovementProvider movement;
  final PurchaseService purchases;
  final RecoveryProvider recovery;
  final CycleProvider cycle;
  final PhotosProvider photos;
  final ExerciseCatalog catalog;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider.value(value: bmi),
          ChangeNotifierProvider.value(value: body),
          ChangeNotifierProvider.value(value: workouts),
          ChangeNotifierProvider.value(value: fuel),
          ChangeNotifierProvider.value(value: steps),
          ChangeNotifierProvider.value(value: movement),
          ChangeNotifierProvider.value(value: purchases),
          ChangeNotifierProvider.value(value: recovery),
          ChangeNotifierProvider.value(value: cycle),
          ChangeNotifierProvider.value(value: photos),
          Provider.value(value: catalog),
        ],
        child: child,
      );
}

class BmiHealthApp extends StatefulWidget {
  const BmiHealthApp({super.key});

  @override
  State<BmiHealthApp> createState() => _BmiHealthAppState();
}

class _BmiHealthAppState extends State<BmiHealthApp>
    with WidgetsBindingObserver {
  // Created once — rebuilding the router would reset navigation.
  late final GoRouter _router = createRouter(
      context.read<SettingsProvider>(), context.read<ProfileProvider>());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  // Show App Open ad when user returns to the app from the background.
  // The 4-hour cooldown inside AdService prevents over-frequency.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cycle data locks again whenever the app leaves the screen
    if (state == AppLifecycleState.paused) context.read<CycleProvider>().relock();
    if (state != AppLifecycleState.resumed) return;
    // Fresh step count and day rollover whenever the user comes back
    context.read<StepsProvider>().refresh();
    context.read<FuelProvider>().load();
    context.read<MovementProvider>().refresh();
    context.read<RecoveryProvider>().refresh();
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    if (path == Routes.splash || path == Routes.onboarding) return;
    AdService.instance.showAppOpenIfReady();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsProvider, ThemeMode>((p) => p.themeMode);
    final locale = context.select<SettingsProvider, Locale?>((p) => p.locale);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      // A saved 'ur' choice is ignored in builds where Urdu is not enabled yet.
      locale: appSupportedLocales.contains(locale) ? locale : null,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
