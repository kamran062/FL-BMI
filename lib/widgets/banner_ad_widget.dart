import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/purchase_service.dart';

/// Shows a banner ad for free users; invisible for premium users.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    if (!PurchaseService.instance.isPremium) {
      AdService.instance.loadBanner().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    AdService.instance.disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PurchaseService.instance.isPremium) return const SizedBox.shrink();

    final ad = AdService.instance.bannerAd;
    if (ad == null || !AdService.instance.bannerReady) {
      return const SizedBox(height: 50);
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        height: ad.size.height.toDouble(),
        width: ad.size.width.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
