import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Self-contained adaptive banner ad.
/// Reports its rendered height via [onHeightChanged] so the parent can
/// add the correct bottom padding to content above it.
class BannerAdWidget extends StatefulWidget {
  final ValueChanged<double>? onHeightChanged;
  const BannerAdWidget({super.key, this.onHeightChanged});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad == null) _loadAd();
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait,
          width,
        ) ??
        AdSize.banner;

    // Report height as soon as ad size is known (before ad renders)
    widget.onHeightChanged?.call(adSize.height.toDouble());

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );

    await ad.load();
    if (mounted) {
      setState(() => _ad = ad);
    } else {
      ad.dispose();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null || !_loaded) {
      return const SizedBox(height: 50);
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _ad!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
