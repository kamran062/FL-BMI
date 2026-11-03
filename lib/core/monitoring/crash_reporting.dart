import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Crash reporting (Sentry). Off unless SENTRY_DSN is provided at build time:
//   flutter build appbundle --dart-define-from-file=.env.json
// Never on in debug builds, so development crashes stay local.

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// 'production', 'staging' or 'development'. Set APP_ENV per flavor.
const appEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: kReleaseMode ? 'production' : 'development',
);

bool get crashReportingEnabled => _sentryDsn.isNotEmpty && !kDebugMode;

/// Runs [appRunner] with crash reporting attached when it is enabled.
Future<void> runWithCrashReporting(FutureOr<void> Function() appRunner) async {
  if (!crashReportingEnabled) {
    await appRunner();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = appEnvironment;
      // Health app: never attach anything that could show the user's data.
      options.sendDefaultPii = false;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
      options.tracesSampleRate = 0; // errors only, no performance tracing
      options.beforeBreadcrumb = scrubBreadcrumb;
    },
    appRunner: appRunner,
  );
}

/// Drops breadcrumbs that can carry health data. Route URLs contain the BMI
/// (e.g. /result?bmi=23.7) and console lines can echo user input.
@visibleForTesting
Breadcrumb? scrubBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
  if (breadcrumb == null) return null;
  const dropped = {'navigation', 'console', 'ui.click'};
  if (dropped.contains(breadcrumb.category)) return null;
  return breadcrumb;
}

/// Logs a handled error locally and, when enabled, reports it.
/// Never put health values (weight, BMI, …) in [reason].
Future<void> reportError(Object error, StackTrace stack, {String? reason}) async {
  debugPrint('${reason ?? 'Error'}: $error');
  if (!crashReportingEnabled) return;
  await Sentry.captureException(
    error,
    stackTrace: stack,
    withScope: reason == null ? null : (scope) => scope.setTag('where', reason),
  );
}
