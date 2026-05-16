import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ── Ad Unit IDs ────────────────────────────────────────────────────────────
// Replace test IDs with real ones before publishing to the store.
String get _bannerAdUnitId {
  if (Platform.isAndroid) {
    // Test ID — swap with your real Android banner ID before release
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  // Test ID — swap with your real iOS banner ID before release
  return 'ca-app-pub-3940256099942544/2934735716';
}

String get _interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/1033173712';
  }
  return 'ca-app-pub-3940256099942544/4411468910';
}

class AdService {
  AdService._();
  static final instance = AdService._();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _bannerLoaded = false;

  bool get bannerReady => _bannerLoaded && _bannerAd != null;

  // ── Initialize ─────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Banner ─────────────────────────────────────────────────────────────────
  Future<void> loadBanner() async {
    _bannerAd?.dispose();
    _bannerLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _bannerLoaded = false;
        },
      ),
    );
    await _bannerAd!.load();
  }

  BannerAd? get bannerAd => _bannerAd;

  // ── Interstitial ───────────────────────────────────────────────────────────
  Future<void> loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void showInterstitial() {
    _interstitialAd?.show();
    _interstitialAd = null;
    // Preload the next one
    loadInterstitial();
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }
}
