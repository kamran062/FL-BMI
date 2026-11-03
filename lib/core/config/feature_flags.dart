import 'package:flutter/foundation.dart';

/// Build-time feature switches.
///
/// Defaults live here. Any flag can be overridden for one build without a
/// code change, e.g.:
///   flutter run --flavor dev --dart-define=FLAG_ADS=false
///   flutter build appbundle --flavor prod --dart-define=FLAG_URDU=true
///
/// Every unfinished feature ships behind a flag that defaults to off in
/// release builds, so it can be merged early without users seeing it.
abstract final class FeatureFlags {
  /// Urdu language option. Release builds keep it off until a native
  /// speaker has reviewed the translations; debug/profile always have it.
  static bool get urdu => _urduOverride ?? !kReleaseMode;

  /// Ads (banner, interstitial, app open). Turn off for store screenshots
  /// or test builds.
  static const bool ads = bool.fromEnvironment('FLAG_ADS', defaultValue: true);
}

// bool.fromEnvironment needs a constant name, so each override is spelled
// out. null = not set for this build.
const bool? _urduOverride = bool.hasEnvironment('FLAG_URDU')
    ? bool.fromEnvironment('FLAG_URDU')
    : null;
