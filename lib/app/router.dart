import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_health/app/settings_provider.dart';
import 'package:bmi_health/app/app_shell.dart';
import 'package:bmi_health/features/ads/ad_service.dart';
import 'package:bmi_health/features/body/bmi/bmi_provider.dart';
import 'package:bmi_health/features/body/bmi/domain/bmi_calculator.dart';
import 'package:bmi_health/features/profile/domain/user_profile.dart';
import 'package:bmi_health/features/profile/profile_provider.dart';
import 'package:bmi_health/features/profile/ui/profile_setup_screen.dart';
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
  static const setup      = '/setup';
  static const profile    = '/profile';

  /// Result for a saved BMI (read-only) — or a fresh calculation when [bmi] is null.
  static String resultFor([double? bmi]) => bmi == null
      ? result
      : Uri(path: result, queryParameters: {'bmi': '$bmi'}).toString();

  static String shareFor(double bmi) =>
      Uri(path: share, queryParameters: {'bmi': '$bmi'}).toString();
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter(SettingsProvider settings, ProfileProvider profile) {
  // Routing only depends on these flags. Listening to the providers
  // directly would re-run it on every keystroke in the calculator.
  ({bool onboarded, bool needsSetup}) gate() => (
        onboarded: settings.onboardingDone,
        needsSetup:
            !profile.profile.completed && !settings.profileSetupDismissed,
      );
  final gateState = ValueNotifier(gate());
  void refresh() => gateState.value = gate();
  settings.addListener(refresh);
  profile.addListener(refresh);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: gateState,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final g = gateState.value;
      if (path == Routes.splash) return null;
      if (!g.onboarded) return path == Routes.onboarding ? null : Routes.onboarding;
      // Intro done: new users and not-yet-asked existing users answer the
      // profile questions once (they can choose "Later").
      if (g.needsSetup) return path == Routes.setup ? null : Routes.setup;
      if (path == Routes.onboarding || path == Routes.setup) {
        return Routes.calculate;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, _) => SplashScreen(
          // The redirect sends new users to onboarding / profile setup.
          onDone: () => context.go(Routes.calculate),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.setup,
        builder: (context, _) => ProfileSetupScreen(
          mode: ProfileSetupMode.firstRun,
          // Saving marks the profile complete; the redirect moves on.
          onDone: () {},
          onDismiss: () => context.read<SettingsProvider>().dismissProfileSetup(),
        ),
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
              builder: (context, _) => SettingsScreen(
                onOpenProfile: () => context.push(Routes.profile),
              ),
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
        path: Routes.profile,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => ProfileSetupScreen(
          mode: ProfileSetupMode.edit,
          onDone: () => context.pop(),
          onDismiss: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.goal,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => GoalScreen(
          currentWeight: context.read<ProfileProvider>().profile.weightInKg,
          onStart: () => context.go(Routes.history),
          onClose: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.share,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ShareScreen(
          bmi: double.tryParse(state.uri.queryParameters['bmi'] ?? '') ??
              _currentBmiOrDefault(context.read<ProfileProvider>().profile),
          onClose: () => context.pop(),
        ),
      ),
    ],
  );
}

double _currentBmiOrDefault(UserProfile p) => p.bmi > 0 ? p.bmi : 24.0;

/// Result page. [savedBmi] set → viewing a history entry (read-only);
/// null → a fresh calculation from the current profile.
class _ResultPage extends StatelessWidget {
  final double? savedBmi;
  const _ResultPage({this.savedBmi});

  bool get _readOnly => savedBmi != null;

  @override
  Widget build(BuildContext context) {
    final profile = context.read<ProfileProvider>().profile;
    final bmi = savedBmi ?? _currentBmiOrDefault(profile);

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
                await context.read<BmiProvider>().saveResult(profile);
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
