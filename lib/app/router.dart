import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/app_provider.dart';
import 'package:bmi_health/app/app_shell.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/bmi/ui/goal_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/history_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/home_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/result_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/share_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/tips_screen.dart';
import 'package:bmi_health/features/onboarding/ui/onboarding_screen.dart';
import 'package:bmi_health/features/onboarding/ui/splash_screen.dart';
import 'package:bmi_health/features/profile/ui/settings_screen.dart';

/// Route paths. Use these instead of string literals.
abstract final class Routes {
  static const splash     = '/splash';
  static const onboarding = '/onboarding';
  static const calculate  = '/calculate';
  static const history    = '/history';
  static const tips       = '/tips';
  static const settings   = '/settings';
  static const result     = '/result';
  static const goal       = '/goal';
  static const share      = '/share';

  /// Result for a saved BMI (read-only) — or a fresh calculation when [bmi] is null.
  static String resultFor([double? bmi]) => bmi == null
      ? result
      : Uri(path: result, queryParameters: {'bmi': '$bmi'}).toString();

  static String shareFor(double bmi) =>
      Uri(path: share, queryParameters: {'bmi': '$bmi'}).toString();
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter(AppProvider provider) {
  // Redirects depend only on onboarding state. Listening to the whole provider
  // would re-run routing on every keystroke in the calculator.
  final onboardingDone = ValueNotifier(provider.onboardingDone);
  provider.addListener(() => onboardingDone.value = provider.onboardingDone);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: onboardingDone,
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (path == Routes.splash) return null;
      if (!provider.onboardingDone && path != Routes.onboarding) {
        return Routes.onboarding;
      }
      if (provider.onboardingDone && path == Routes.onboarding) {
        return Routes.calculate;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, _) => SplashScreen(
          onDone: () => context.go(
            provider.onboardingDone ? Routes.calculate : Routes.onboarding,
          ),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Tabs ──────────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.calculate,
              builder: (context, _) => HomeScreen(
                onCalculate: () => context.push(Routes.resultFor()),
                onOpenSettings: () => context.go(Routes.settings),
                onViewLastResult: (bmi) => context.push(Routes.resultFor(bmi)),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.history,
              builder: (context, _) => HistoryScreen(
                onAddEntry: () => context.go(Routes.calculate),
                onViewEntry: (entry) =>
                    context.push(Routes.resultFor(entry.bmi)),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.tips,
              builder: (_, __) => const TipsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.settings,
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Full-screen pages above the tabs (hide nav bar and banner) ────────
      GoRoute(
        path: Routes.result,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => _ResultPage(
          savedBmi: double.tryParse(state.uri.queryParameters['bmi'] ?? ''),
        ),
      ),
      GoRoute(
        path: Routes.goal,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => GoalScreen(
          currentWeight: context.read<AppProvider>().profile.weightInKg,
          onStart: () => context.go(Routes.history),
          onClose: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.share,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ShareScreen(
          bmi: double.tryParse(state.uri.queryParameters['bmi'] ?? '') ??
              _currentBmiOrDefault(context.read<AppProvider>()),
          onClose: () => context.pop(),
        ),
      ),
    ],
  );
}

double _currentBmiOrDefault(AppProvider p) =>
    p.currentBmi > 0 ? p.currentBmi : 24.0;

/// Result page. [savedBmi] set → viewing a history entry (read-only);
/// null → a fresh calculation from the current profile.
class _ResultPage extends StatelessWidget {
  final double? savedBmi;
  const _ResultPage({this.savedBmi});

  bool get _readOnly => savedBmi != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final bmi = savedBmi ?? _currentBmiOrDefault(provider);

    // Leaving a fresh result (close button or system back) is a natural
    // break → interstitial. Viewing a history entry never shows an ad.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_readOnly) AdService.instance.showInterstitialIfReady();
      },
      child: ResultScreen(
        bmi: bmi,
        readOnly: _readOnly,
        onClose: () => context.pop(),
        onSave: _readOnly
            ? null
            : () async {
                await provider.saveCurrentResult();
                if (!context.mounted) return;
                // go() replaces the stack, so PopScope does not fire —
                // show the interstitial for this natural break here.
                context.go(Routes.history);
                AdService.instance.showInterstitialIfReady();
              },
        onSetGoal: () => context.push(Routes.goal),
        onShare: () => context.push(Routes.shareFor(bmi)),
      ),
    );
  }
}
