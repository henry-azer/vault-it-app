import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vault_it/core/ads/ad_manager.dart';
import 'package:vault_it/core/ads/ad_state.dart';

/// Banner ad widget that shows at the bottom of screens
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    // Load banner ad if not already loaded
    if (_adManager.bannerState != AdState.loaded) {
      _adManager.loadBannerAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if premium
    if (_adManager.isPremium) {
      return const SizedBox.shrink();
    }

    // Don't show if not loaded
    if (_adManager.bannerState != AdState.loaded || _adManager.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _adManager.bannerAd!.size.width.toDouble(),
      height: _adManager.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _adManager.bannerAd!),
    );
  }

  @override
  void dispose() {
    // Don't dispose here - AdManager handles it globally
    super.dispose();
  }
}
