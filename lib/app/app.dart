import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/metrics/body_provider.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/app/router.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/l10n/l10n.dart';
import 'package:bmi_health/shared/theme/app_theme.dart';

/// Supplies the app-wide state objects. Used by main() and by tests.
class BmiHealthProviders extends StatelessWidget {
  const BmiHealthProviders({
    super.key,
    required this.settings,
    required this.profile,
    required this.bmi,
    required this.body,
    required this.child,
  });

  final SettingsProvider settings;
  final ProfileProvider profile;
  final BmiProvider bmi;
  final BodyProvider body;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider.value(value: bmi),
          ChangeNotifierProvider.value(value: body),
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
    if (state != AppLifecycleState.resumed) return;
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
