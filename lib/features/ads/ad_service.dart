import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bmi_health/core/config/feature_flags.dart';

// ── Ad Unit IDs ────────────────────────────────────────────────────────────────
// Release builds read real IDs injected at build time from .env.json:
//   flutter build appbundle --dart-define-from-file=.env.json
// Debug and profile builds always use Google's official test IDs, so real ads
// are never requested from a development device.
// See .env.example.json for the required keys.

const _bannerAndroid  = String.fromEnvironment('BANNER_AD_ANDROID');
const _bannerIos      = String.fromEnvironment('BANNER_AD_IOS');
const _interAndroid   = String.fromEnvironment('INTER_AD_ANDROID');
const _interIos       = String.fromEnvironment('INTER_AD_IOS');
const _appOpenAndroid = String.fromEnvironment('APP_OPEN_AD_ANDROID');
const _appOpenIos     = String.fromEnvironment('APP_OPEN_AD_IOS');

// https://developers.google.com/admob/flutter/test-ads
const _testBannerAndroid  = 'ca-app-pub-3940256099942544/6300978111';
const _testBannerIos      = 'ca-app-pub-3940256099942544/2934735716';
const _testInterAndroid   = 'ca-app-pub-3940256099942544/1033173712';
const _testInterIos       = 'ca-app-pub-3940256099942544/4411468910';
const _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
const _testAppOpenIos     = 'ca-app-pub-3940256099942544/5575463023';

String _pick(String android, String ios, String testAndroid, String testIos) {
  if (!kReleaseMode) return Platform.isAndroid ? testAndroid : testIos;
  return Platform.isAndroid ? android : ios;
}

String get _bannerAdUnitId =>
    _pick(_bannerAndroid, _bannerIos, _testBannerAndroid, _testBannerIos);
String get _interAdUnitId =>
    _pick(_interAndroid, _interIos, _testInterAndroid, _testInterIos);
String get _appOpenAdUnitId =>
    _pick(_appOpenAndroid, _appOpenIos, _testAppOpenAndroid, _testAppOpenIos);

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

  /// True once consent has been gathered and the SDK is initialized.
  /// Widgets must not request ads before this is true.
  final ValueNotifier<bool> ready = ValueNotifier(false);

  /// Premium users see no ads (set by PurchaseService).
  final ValueNotifier<bool> premiumNotifier = ValueNotifier(false);
  bool get premium => premiumNotifier.value;
  set premium(bool v) => premiumNotifier.value = v;

  /// True when the user is in a region where a privacy options entry point
  /// must be shown in Settings (e.g. EEA / UK).
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  // Public accessors for widgets
  String get bannerAdUnitId => _bannerAdUnitId;
  AdRequest get adRequest => _adRequest;

  bool _initStarted = false;

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

  // ── App Open suppression ───────────────────────────────────────────────────
  // Returning from a full-screen ad, the share sheet or a store purchase sheet
  // fires AppLifecycleState.resumed. That is not a real "return to the app",
  // so no App Open ad may be shown then.
  int _externalUiDepth = 0;
  DateTime? _suppressAppOpenUntil;
  static const _resumeGrace = Duration(seconds: 3);

  /// Call before opening UI that leaves the app (share sheet, purchase sheet).
  void beginExternalUi() => _externalUiDepth++;

  /// Call when that UI has closed.
  void endExternalUi() {
    if (_externalUiDepth > 0) _externalUiDepth--;
    _suppressAppOpenUntil = DateTime.now().add(_resumeGrace);
  }

  bool get _appOpenSuppressed =>
      _externalUiDepth > 0 ||
      (_suppressAppOpenUntil != null &&
          DateTime.now().isBefore(_suppressAppOpenUntil!));

  // ── Initialize ─────────────────────────────────────────────────────────────

  /// Gathers consent (UMP), then initializes the SDK and preloads ads.
  /// Call once after runApp — the consent form needs a visible screen.
  Future<void> initialize() async {
    if (_initStarted) return;
    _initStarted = true;

    if (!FeatureFlags.ads) {
      debugPrint('AdService: ads turned off for this build (FLAG_ADS=false).');
      return;
    }

    if (kReleaseMode && !_hasReleaseIds) {
      debugPrint('AdService: ad unit IDs missing — build with '
          '--dart-define-from-file=.env.json. Ads disabled.');
      return;
    }

    await _gatherConsent();

    if (!await ConsentInformation.instance.canRequestAds()) return;

    await MobileAds.instance.initialize();

    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: const <String>[
            // Paste your device hash here, e.g. '33BE2250B43518CCDA7DE426D04EE231'
          ],
        ),
      );
    }

    ready.value = true;
    _loadInterstitial();
    _loadAppOpen();
  }

  bool get _hasReleaseIds {
    final ids = Platform.isAndroid
        ? const [_bannerAndroid, _interAndroid, _appOpenAndroid]
        : const [_bannerIos, _interIos, _appOpenIos];
    return ids.every((id) => id.isNotEmpty);
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint('AdService: consent form error ${formError.message}');
          }
          if (!done.isCompleted) done.complete();
        });
      },
      (error) {
        // Fall through — canRequestAds() still reflects consent from a
        // previous session, so returning users keep getting ads offline.
        debugPrint('AdService: consent update failed ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.then((_) async {
      privacyOptionsRequired.value =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
              PrivacyOptionsRequirementStatus.required;
    });
  }

  /// Opens the UMP privacy options form so users can change their choice.
  Future<void> showPrivacyOptions() async {
    beginExternalUi();
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint('AdService: privacy options error ${formError.message}');
      }
    });
    endExternalUi();
  }

  // ── Interstitial ───────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (!ready.value || _interstitialLoading || _interstitial != null) return;
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
              endExternalUi();
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              endExternalUi();
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
    if (!ready.value || premium) return false;
    if (_interstitial == null) {
      _loadInterstitial();
      return false;
    }
    if (_lastInterShown != null &&
        DateTime.now().difference(_lastInterShown!) < _interCooldown) {
      return false;
    }

    _lastInterShown = DateTime.now();
    beginExternalUi();
    _interstitial!.show();
    _interstitial = null;
    return true;
  }

  // ── App Open ───────────────────────────────────────────────────────────────

  void _loadAppOpen() {
    if (!ready.value || _appOpenLoading || _appOpenAd != null) return;
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
              endExternalUi();
              _loadAppOpen();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              endExternalUi();
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
    if (!ready.value || premium || _appOpenSuppressed) return false;
    if (_appOpenAd == null) {
      _loadAppOpen();
      return false;
    }
    if (_lastAppOpenShown != null &&
        DateTime.now().difference(_lastAppOpenShown!) < _appOpenCooldown) {
      return false;
    }

    _lastAppOpenShown = DateTime.now();
    beginExternalUi();
    _appOpenAd!.show();
    _appOpenAd = null;
    return true;
  }
}
