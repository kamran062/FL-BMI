import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bmi_health/features/ads/ad_service.dart';

/// Self-contained adaptive banner ad.
/// Reports its height via [onHeightChanged] only once an ad has actually
/// loaded, so the parent never reserves space for an empty banner.
class BannerAdWidget extends StatefulWidget {
  final ValueChanged<double>? onHeightChanged;
  const BannerAdWidget({super.key, this.onHeightChanged});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loading = false;
  // Retry with backoff: 30s → 60s → 120s, then give up for this session
  static const _retryDelays = [30, 60, 120];
  int _retryCount = 0;
  bool _gaveUp = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    AdService.instance.ready.addListener(_maybeLoad);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  // Guarded entry point: dependency changes (e.g. keyboard opening) and the
  // ready notifier can both call this, but only one load runs at a time.
  void _maybeLoad() {
    if (!mounted ||
        !AdService.instance.ready.value ||
        _ad != null ||
        _loading ||
        _gaveUp ||
        (_retryTimer?.isActive ?? false)) {
      return;
    }
    _loadAd();
  }

  Future<void> _loadAd() async {
    _loading = true;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          width,
        ) ??
        AdSize.banner;

    if (!mounted) {
      _loading = false;
      return;
    }

    BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: adSize,
      request: AdService.instance.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loading = false;
          _retryCount = 0;
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _ad = ad as BannerAd);
          widget.onHeightChanged?.call(adSize.height.toDouble());
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _loading = false;
          if (!mounted) return;
          if (_retryCount < _retryDelays.length) {
            final delay = _retryDelays[_retryCount++];
            _retryTimer = Timer(Duration(seconds: delay), _maybeLoad);
          } else {
            _gaveUp = true;
          }
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    AdService.instance.ready.removeListener(_maybeLoad);
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();

    // No SafeArea here: the parent positions the banner above the nav bar,
    // which already accounts for the bottom inset.
    return SizedBox(
      height: ad.size.height.toDouble(),
      width: double.infinity,
      child: AdWidget(ad: ad),
    );
  }
}
