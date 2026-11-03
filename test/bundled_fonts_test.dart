import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Inter ships in assets/google_fonts with these weights only, and runtime
/// font downloads are off. Any other weight crashes at runtime (found on
/// device with w800), so catch it here.
void main() {
  test('only bundled Inter weights are used', () {
    const bundled = {'w400', 'w500', 'w600', 'w700'};
    final files = {
      for (final f in Directory('assets/google_fonts').listSync())
        f.uri.pathSegments.last
    };
    expect(files, containsAll(
        ['Inter-Regular.ttf', 'Inter-Medium.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf']));

    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final m in RegExp(r'FontWeight\.(w\d00|bold|normal)').allMatches(lines[i])) {
          final w = switch (m[1]) { 'bold' => 'w700', 'normal' => 'w400', final v => v! };
          if (!bundled.contains(w)) offenders.add('${f.path}:${i + 1} ${m[0]}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
