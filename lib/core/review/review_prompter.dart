import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bmi_health/core/monitoring/crash_reporting.dart';
import 'package:bmi_health/features/ads/ad_service.dart';

/// Shows the store's own in-app rating sheet. Tests replace [reviewSheet].
abstract class ReviewSheet {
  Future<bool> available();
  Future<void> show();
}

ReviewSheet reviewSheet = _StoreReviewSheet();

/// For tests: records when the sheet would have been shown.
class RecordingReviewSheet implements ReviewSheet {
  int shown = 0;
  @override
  Future<bool> available() async => true;
  @override
  Future<void> show() async => shown++;
}

class _StoreReviewSheet implements ReviewSheet {
  final _review = InAppReview.instance;
  @override
  Future<bool> available() => _review.isAvailable();
  @override
  Future<void> show() => _review.requestReview();
}

/// Asks for a rating only after the user has had a few good moments (a
/// finished workout or challenge day, a perfect day), and at most once
/// every few months. Never on first launch. The store also limits how often
/// its sheet can appear, so a call may show nothing.
abstract final class ReviewPrompter {
  static const momentsNeeded = 3;
  static const quietDays = 120;
  static const _momentsKey = 'review_moments';
  static const _askedKey = 'review_asked_at';
  static const _perfectDayKey = 'review_perfect_day';

  /// Call after something went well.
  static Future<void> happyMoment({DateTime? now}) async {
    try {
      final t = now ?? DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final asked = prefs.getInt(_askedKey);
      if (asked != null &&
          t.difference(DateTime.fromMillisecondsSinceEpoch(asked)).inDays < quietDays) {
        return;
      }
      final moments = (prefs.getInt(_momentsKey) ?? 0) + 1;
      if (moments < momentsNeeded) {
        await prefs.setInt(_momentsKey, moments);
        return;
      }
      await prefs.setInt(_momentsKey, 0);
      await prefs.setInt(_askedKey, t.millisecondsSinceEpoch);
      if (!await reviewSheet.available()) return;
      // The sheet is shown by Play / the App Store over the app; coming back
      // from it isn't an app open (no App Open ad).
      AdService.instance.beginExternalUi();
      try {
        await reviewSheet.show();
      } finally {
        AdService.instance.endExternalUi();
      }
    } catch (e, st) {
      reportError(e, st, reason: 'review-prompt');
    }
  }

  /// A perfect day counts once per calendar day.
  static Future<void> perfectDay({DateTime? now}) async {
    try {
      final t = now ?? DateTime.now();
      final day = '${t.year}-${t.month}-${t.day}';
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_perfectDayKey) == day) return;
      await prefs.setString(_perfectDayKey, day);
      await happyMoment(now: t);
    } catch (e, st) {
      reportError(e, st, reason: 'review-prompt');
    }
  }
}
