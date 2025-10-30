import 'package:vault_it/core/ads/ad_manager.dart';

/// Helper class for showing interstitial ads at appropriate times
class InterstitialAdHelper {
  static final AdManager _adManager = AdManager();

  /// Show interstitial ad after user action (save, delete, etc.)
  static Future<void> showAfterAction() async {
    // Increment action count
    await _adManager.incrementActionCount();
    
    // AdManager will automatically show ad if conditions are met
  }

  /// Force show interstitial ad (use sparingly)
  static Future<bool> forceShow() async {
    return await _adManager.showInterstitialAd();
  }
}
