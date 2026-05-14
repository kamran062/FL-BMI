import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/main_app.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class BmiHealthApp extends StatelessWidget {
  const BmiHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'BMI Health',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: provider.themeMode,
          home: provider.loading
              ? const _LoadingScreen()
              : const _RootNavigator(),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE8F7EF),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1FB573),
        ),
      ),
    );
  }
}

class _RootNavigator extends StatefulWidget {
  const _RootNavigator();

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  _Phase _phase = _Phase.splash;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (_phase == _Phase.splash) {
      return SplashScreen(onDone: () {
        setState(() {
          _phase = provider.onboardingDone
              ? _Phase.app
              : _Phase.onboarding;
        });
      });
    }

    if (_phase == _Phase.onboarding) {
      if (provider.onboardingDone) return const MainApp();
      return const OnboardingScreen();
    }

    return const MainApp();
  }
}

enum _Phase { splash, onboarding, app }
