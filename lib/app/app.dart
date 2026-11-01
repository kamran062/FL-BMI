import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/app_provider.dart';
import 'package:bmi_health/app/router.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/shared/theme/app_theme.dart';

class BmiHealthApp extends StatefulWidget {
  const BmiHealthApp({super.key});

  @override
  State<BmiHealthApp> createState() => _BmiHealthAppState();
}

class _BmiHealthAppState extends State<BmiHealthApp>
    with WidgetsBindingObserver {
  // Created once — rebuilding the router would reset navigation.
  late final GoRouter _router = createRouter(context.read<AppProvider>());

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
    final themeMode = context.select<AppProvider, ThemeMode>((p) => p.themeMode);
    return MaterialApp.router(
      title: 'BMI Calculator & Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
