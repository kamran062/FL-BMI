import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('scrubBreadcrumb', () {
    Breadcrumb? scrub(String category) =>
        scrubBreadcrumb(Breadcrumb(category: category, message: 'x'), Hint());

    test('drops navigation, which carries BMI in route URLs', () {
      expect(scrub('navigation'), isNull);
    });

    test('drops console output and taps', () {
      expect(scrub('console'), isNull);
      expect(scrub('ui.click'), isNull);
    });

    test('keeps other breadcrumbs', () {
      expect(scrub('http'), isNotNull);
      expect(scrub('app.lifecycle'), isNotNull);
    });
  });

  test('crash reporting is off in tests (no DSN, debug mode)', () {
    expect(crashReportingEnabled, isFalse);
  });
}
