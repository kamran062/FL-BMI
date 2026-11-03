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
import 'package:bmi_health/features/body/ui/body_screen.dart';
import 'package:bmi_health/features/train/exercises/domain/exercise.dart';
import 'package:bmi_health/features/train/exercises/ui/exercise_detail_screen.dart';
import 'package:bmi_health/features/train/exercises/ui/exercise_library_screen.dart';
import 'package:bmi_health/features/train/ui/train_screen.dart';
import 'package:bmi_health/features/train/workouts/ui/active_workout_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/home_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/result_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/share_screen.dart';
import 'package:bmi_health/features/body/bmi/ui/tips_screen.dart';
import 'package:bmi_health/features/onboarding/ui/onboarding_screen.dart';
import 'package:bmi_health/features/onboarding/ui/splash_screen.dart';
import 'package:bmi_health/features/profile/ui/settings_screen.dart';
import 'package:bmi_health/features/fuel/ui/fuel_screen.dart';
import 'package:bmi_health/features/today/ui/today_screen.dart';
import 'package:bmi_health/features/movement/ui/timeline_screen.dart';

/// Route paths. Use these instead of string literals.
abstract final class Routes {
  static const splash     = '/splash';
  static const onboarding = '/onboarding';
  static const today      = '/today';
  static const tips       = '/today/tips';
  static const movement   = '/today/movement';
  static const body       = '/body';
  static const calculate  = '/body/calculate';
  static const history    = '/body/history';
  static const fuel       = '/fuel';
  static const settings   = '/settings';
  static const result     = '/result';
  static const goal       = '/goal';
  static const share      = '/share';
  static const setup      = '/setup';
  static const train      = '/train';
  static const workout    = '/workout';
  static const exercises  = '/exercises';
  static String exercise(String id) => '/exercises/$id';
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
        return Routes.today;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, _) => SplashScreen(
          // The redirect sends new users to onboarding / profile setup.
          onDone: () => context.go(Routes.today),
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
              path: Routes.today,
              builder: (context, _) => TodayScreen(
                onOpenWorkout: () => context.push(Routes.workout),
                onOpenFuel: () => context.go(Routes.fuel),
                onOpenBody: () => context.go(Routes.body),
                onCalculateBmi: () => context.go(Routes.calculate),
                onOpenTips: () => context.go(Routes.tips),
                onOpenTimeline: () => context.go(Routes.movement),
              ),
              routes: [
                GoRoute(
                  path: 'tips',
                  builder: (context, _) =>
                      TipsScreen(onBack: () => context.go(Routes.today)),
                ),
                GoRoute(
                  path: 'movement',
                  builder: (context, _) =>
                      TimelineScreen(onBack: () => context.go(Routes.today)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.body,
              builder: (context, _) => BodyScreen(
                onOpenBmiHistory: () => context.go(Routes.history),
                onCalculateBmi: () => context.go(Routes.calculate),
              ),
              routes: [
                // Nested so the Body tab stays underneath and Back returns to it
                GoRoute(
                  path: 'calculate',
                  builder: (context, _) => HomeScreen(
                    onCalculate: () => context.push(Routes.resultFor()),
                    onOpenSettings: () => context.go(Routes.settings),
                    onViewLastResult: (bmi) =>
                        context.push(Routes.resultFor(bmi)),
                    onBack: () => context.go(Routes.body),
                  ),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, _) => HistoryScreen(
                    onAddEntry: () => context.go(Routes.calculate),
                    onViewEntry: (entry) =>
                        context.push(Routes.resultFor(entry.bmi)),
                    onBack: () => context.go(Routes.body),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.train,
              builder: (context, _) => TrainScreen(
                onOpenWorkout: () => context.push(Routes.workout),
                onOpenLibrary: () => context.push(Routes.exercises),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.fuel,
              builder: (context, _) => FuelScreen(
                onOpenProfile: () => context.push(Routes.profile),
              ),
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
        path: Routes.workout,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => ActiveWorkoutScreen(
          // The picker returns the chosen exercise id via pop()
          pickExercise: () =>
              context.push<String>('${Routes.exercises}?pick=1'),
          onClose: () => context.pop(),
        ),
      ),
      GoRoute(
        path: Routes.exercises,
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final picking = state.uri.queryParameters['pick'] == '1';
          return ExerciseLibraryScreen(
            onPick: picking ? (e) => context.pop(e.id) : null,
            onOpen: (e) => context.push(Routes.exercise(e.id)),
            onClose: () => context.pop(),
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (context, state) {
              final e = context
                  .read<ExerciseCatalog>()
                  .byId(state.pathParameters['id']!);
              if (e == null) return const SizedBox.shrink();
              return ExerciseDetailScreen(
                  exercise: e, onClose: () => context.pop());
            },
          ),
        ],
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
