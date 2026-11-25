import 'package:bmi_health/core/review/review_prompter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RecordingReviewSheet sheet;
  final t0 = DateTime(2026, 12, 1, 18);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sheet = RecordingReviewSheet();
    reviewSheet = sheet;
  });

  test('asks only after the third happy moment', () async {
    await ReviewPrompter.happyMoment(now: t0);
    await ReviewPrompter.happyMoment(now: t0);
    expect(sheet.shown, 0);
    await ReviewPrompter.happyMoment(now: t0);
    expect(sheet.shown, 1);
  });

  test('then stays quiet for 120 days, and counts again after', () async {
    for (var i = 0; i < 3; i++) {
      await ReviewPrompter.happyMoment(now: t0);
    }
    for (var i = 0; i < 6; i++) {
      await ReviewPrompter.happyMoment(now: t0.add(const Duration(days: 30)));
    }
    expect(sheet.shown, 1);
    final later = t0.add(const Duration(days: 121));
    for (var i = 0; i < 3; i++) {
      await ReviewPrompter.happyMoment(now: later);
    }
    expect(sheet.shown, 2);
  });

  test('a perfect day counts once per day', () async {
    await ReviewPrompter.perfectDay(now: t0);
    await ReviewPrompter.perfectDay(now: t0.add(const Duration(hours: 2)));
    await ReviewPrompter.perfectDay(now: t0.add(const Duration(hours: 3)));
    expect(sheet.shown, 0);
    await ReviewPrompter.perfectDay(now: t0.add(const Duration(days: 1)));
    await ReviewPrompter.perfectDay(now: t0.add(const Duration(days: 2)));
    expect(sheet.shown, 1);
  });

  test('never throws when the store sheet is missing', () async {
    reviewSheet = _Broken();
    for (var i = 0; i < 3; i++) {
      await ReviewPrompter.happyMoment(now: t0);
    }
  });
}

class _Broken implements ReviewSheet {
  @override
  Future<bool> available() async => throw StateError('no store');
  @override
  Future<void> show() async {}
}
