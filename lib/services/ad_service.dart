import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ── Ad Unit IDs ────────────────────────────────────────────────────────────────
// Release mode → real IDs; debug/profile → official Google test IDs.
//
// TODO before publishing:
//   1. Create banner + interstitial + app-open units in AdMob console
//   2. Replace the _real* constants below with your actual unit IDs
//   3. Make sure the app ID in AndroidManifest / Info.plist is the real one too

const _realBannerAndroid   = 'ca-app-pub-REPLACE_ME/BANNER_ANDROID';
const _realBannerIos       = 'ca-app-pub-REPLACE_ME/BANNER_IOS';
const _realInterAndroid    = 'ca-app-pub-REPLACE_ME/INTER_ANDROID';
const _realInterIos        = 'ca-app-pub-REPLACE_ME/INTER_IOS';
const _realAppOpenAndroid  = 'ca-app-pub-REPLACE_ME/APPOPEN_ANDROID';
const _realAppOpenIos      = 'ca-app-pub-REPLACE_ME/APPOPEN_IOS';

// Official Google test IDs — safe in dev, never generate revenue
const _testBannerAndroid   = 'ca-app-pub-3940256099942544/6300978111';
const _testBannerIos       = 'ca-app-pub-3940256099942544/2934735716';
const _testInterAndroid    = 'ca-app-pub-3940256099942544/1033173712';
const _testInterIos        = 'ca-app-pub-3940256099942544/4411468910';
const _testAppOpenAndroid  = 'ca-app-pub-3940256099942544/9257395921';
const _testAppOpenIos      = 'ca-app-pub-3940256099942544/5575463023';

String get _bannerAdUnitId => kReleaseMode
    ? (Platform.isAndroid ? _realBannerAndroid  : _realBannerIos)
    : (Platform.isAndroid ? _testBannerAndroid  : _testBannerIos);

String get _interAdUnitId => kReleaseMode
    ? (Platform.isAndroid ? _realInterAndroid   : _realInterIos)
    : (Platform.isAndroid ? _testInterAndroid   : _testInterIos);

String get _appOpenAdUnitId => kReleaseMode
    ? (Platform.isAndroid ? _realAppOpenAndroid : _realAppOpenIos)
    : (Platform.isAndroid ? _testAppOpenAndroid : _testAppOpenIos);

// Expose banner unit ID for BannerAdWidget
String get bannerAdUnitId => _bannerAdUnitId;

// AdRequest with health/fitness keywords → more relevant ads → higher eCPM
const _adRequest = AdRequest(
  keywords: <String>[
    'health', 'fitness', 'bmi', 'weight loss', 'diet',
    'nutrition', 'body mass', 'workout', 'wellness',
  ],
);

// ── AdService ──────────────────────────────────────────────────────────────────

class AdService {
  AdService._();
  static final instance = AdService._();

  // ── Interstitial state ─────────────────────────────────────────────────────
  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;

  // 2-minute cooldown — conservative and AdMob policy-safe
  static const _interCooldown = Duration(seconds: 120);
  DateTime? _lastInterShown;

  // ── App Open state ─────────────────────────────────────────────────────────
  AppOpenAd? _appOpenAd;
  bool _appOpenLoading = false;

  // App Open ads should not appear more than once every 4 hours
  static const _appOpenCooldown = Duration(hours: 4);
  DateTime? _lastAppOpenShown;

  // ── Initialize ─────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();

    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment:
              TagForChildDirectedTreatment.unspecified,
          testDeviceIds: const <String>[
            // Add your physical test device ID here (from logcat/console output)
            // e.g. '33BE2250B43518CCDA7DE426D04EE231'
          ],
        ),
      );
    }
  }

  // ── Preload ────────────────────────────────────────────────────────────────

  /// Call once at app start so the first ads are ready immediately.
  Future<void> preload() async {
    _loadInterstitial();
    _loadAppOpen();
  }

  // ── Interstitial ───────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (_interstitialLoading || _interstitial != null) return;
    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interAdUnitId,
      request: _adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitial = ad;
          ad.setImmersiveMode(true);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitial);
        },
      ),
    );
  }

  /// Shows the interstitial at a natural break point (e.g. after saving a result).
  /// Returns true if an ad was shown.
  bool showInterstitialIfReady() {
    if (_interstitial == null) {
      _loadInterstitial();
      return false;
    }
    if (_lastInterShown != null &&
        DateTime.now().difference(_lastInterShown!) < _interCooldown) {
      return false;
    }

    _lastInterShown = DateTime.now();
    _interstitial!.show();
    _interstitial = null;
    return true;
  }

  // ── App Open ───────────────────────────────────────────────────────────────

  void _loadAppOpen() {
    if (_appOpenLoading || _appOpenAd != null) return;
    _appOpenLoading = true;

    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: _adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpenAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
              _loadAppOpen();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _appOpenAd = null;
              _loadAppOpen();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _appOpenLoading = false;
          Future.delayed(const Duration(seconds: 30), _loadAppOpen);
        },
      ),
    );
  }

  /// Shows the App Open ad when the user returns to the app from the background.
  /// Call this from an AppLifecycleState.resumed handler.
  /// Returns true if an ad was shown.
  bool showAppOpenIfReady() {
    if (_appOpenAd == null) {
      _loadAppOpen();
      return false;
    }
    if (_lastAppOpenShown != null &&
        DateTime.now().difference(_lastAppOpenShown!) < _appOpenCooldown) {
      return false;
    }

    _lastAppOpenShown = DateTime.now();
    _appOpenAd!.show();
    _appOpenAd = null;
    return true;
  }
}
