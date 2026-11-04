import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

// 1×1 transparent PNG
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  setUpAll(setUpAppHarness);

  testWidgets('photos are stored encrypted, compared, and deleted from disk',
      (tester) async {
    final app = await launchApp(tester);
    await tester.tap(find.text('Body'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('PROGRESS PHOTOS'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Compare first and latest'), findsNothing);

    await tester.runAsync(() async {
      await app.photos.add(_png, date: DateTime(2026, 9, 1), weightKg: 80);
      await app.photos.add(_png, date: DateTime(2026, 11, 1), weightKg: 76);
    });
    await tester.pumpAndSettle();
    expect(app.photos.photos, hasLength(2));

    // Encrypted on disk: not a PNG
    final first = app.photos.photos.first;
    final file = File('${app.photosDir.path}/${first.file}');
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync().sublist(0, 4), isNot(_png.sublist(0, 4)));

    // Compare view shows both, with dates and weights
    await tester.scrollUntilVisible(find.text('Compare first and latest'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Compare first and latest'));
    await tester.pumpAndSettle();
    expect(find.text('Sep 1, 2026 · 80.0 kg'), findsOneWidget);
    expect(find.text('Nov 1, 2026 · 76.0 kg'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Delete removes the file from disk
    await tester.runAsync(() => app.photos.delete(first));
    expect(file.existsSync(), isFalse);
    expect(app.photos.photos, hasLength(1));
  });
}
