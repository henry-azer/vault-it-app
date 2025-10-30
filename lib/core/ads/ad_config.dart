import 'dart:io';
import 'package:vault_it/core/constants/ad_constants.dart';

/// Ad configuration helper to get platform-specific ad unit IDs
class AdConfig {
  /// Get banner ad unit ID for current platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AdConstants.androidBannerId;
    } else if (Platform.isIOS) {
      return AdConstants.iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get interstitial ad unit ID for current platform
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AdConstants.androidInterstitialId;
    } else if (Platform.isIOS) {
      return AdConstants.iosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get rewarded ad unit ID for current platform
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return AdConstants.androidRewardedId;
    } else if (Platform.isIOS) {
      return AdConstants.iosRewardedId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get app open ad unit ID for current platform
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return AdConstants.androidAppOpenId;
    } else if (Platform.isIOS) {
      return AdConstants.iosAppOpenId;
    }
    throw UnsupportedError('Unsupported platform');
  }
}
