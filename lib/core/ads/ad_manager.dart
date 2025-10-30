import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault_it/core/ads/ad_config.dart';
import 'package:vault_it/core/ads/ad_state.dart';
import 'package:vault_it/core/constants/ad_constants.dart';

/// Singleton Ad Manager for controlling all ads in the app
/// Handles ad loading, showing, frequency control, and premium status
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // ==================== STATE ====================
  
  bool _isInitialized = false;
  bool _isPremium = false;
  SharedPreferences? _prefs;
  
  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  
  // Ad states
  AdState _bannerState = AdState.notLoaded;
  AdState _interstitialState = AdState.notLoaded;
  AdState _rewardedState = AdState.notLoaded;
  AdState _appOpenState = AdState.notLoaded;
  
  // Timing control
  DateTime? _lastInterstitialTime;
  DateTime? _lastAppOpenTime;
  DateTime? _appBackgroundTime;
  int _actionCount = 0;
  int _adImpressions = 0;
  DateTime? _lastPromptTime;
  DateTime? _installDate;
  
  // Callbacks
  VoidCallback? _onPremiumPromptShow;
  
  // ==================== GETTERS ====================
  
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  AdState get bannerState => _bannerState;
  AdState get interstitialState => _interstitialState;
  AdState get rewardedState => _rewardedState;
  AdState get appOpenState => _appOpenState;
  BannerAd? get bannerAd => _bannerAd;
  int get adImpressions => _adImpressions;
  int get daysSinceInstall => _installDate != null 
      ? DateTime.now().difference(_installDate!).inDays 
      : 0;
  
  // ==================== INITIALIZATION ====================
  
  /// Initialize AdMob SDK and load saved state
  Future<void> initialize({VoidCallback? onPremiumPromptShow}) async {
    if (_isInitialized) return;
    
    try {
      _onPremiumPromptShow = onPremiumPromptShow;
      
      // Initialize Mobile Ads SDK
      await MobileAds.instance.initialize();
      
      // Load preferences
      _prefs = await SharedPreferences.getInstance();
      await _loadState();
      
      // Set install date if first time
      if (_installDate == null) {
        _installDate = DateTime.now();
        await _prefs?.setString(
          AdConstants.keyInstallDate,
          _installDate!.toIso8601String(),
        );
      }
      
      _isInitialized = true;
      
      // Load initial ads if not premium
      if (!_isPremium) {
        loadBannerAd();
        _preloadInterstitialAd();
        _preloadRewardedAd();
      }
      
      debugPrint('✅ AdManager initialized successfully');
    } catch (e) {
      debugPrint('❌ AdManager initialization failed: $e');
    }
  }
  
  /// Load saved state from SharedPreferences
  Future<void> _loadState() async {
    final lastInterstitialStr = _prefs?.getString(AdConstants.keyLastInterstitialTime);
    if (lastInterstitialStr != null) {
      _lastInterstitialTime = DateTime.parse(lastInterstitialStr);
    }
    
    final lastAppOpenStr = _prefs?.getString(AdConstants.keyLastAppOpenTime);
    if (lastAppOpenStr != null) {
      _lastAppOpenTime = DateTime.parse(lastAppOpenStr);
    }
    
    final installDateStr = _prefs?.getString(AdConstants.keyInstallDate);
    if (installDateStr != null) {
      _installDate = DateTime.parse(installDateStr);
    }
    
    final lastPromptStr = _prefs?.getString(AdConstants.keyLastPromptTime);
    if (lastPromptStr != null) {
      _lastPromptTime = DateTime.parse(lastPromptStr);
    }
    
    _actionCount = _prefs?.getInt(AdConstants.keyActionCount) ?? 0;
    _adImpressions = _prefs?.getInt(AdConstants.keyAdImpressions) ?? 0;
  }
  
  // ==================== PREMIUM STATUS ====================
  
  /// Set premium status (removes all ads)
  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    
    if (_isPremium) {
      // Dispose all ads
      _bannerAd?.dispose();
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();
      _appOpenAd?.dispose();
      
      _bannerAd = null;
      _interstitialAd = null;
      _rewardedAd = null;
      _appOpenAd = null;
      
      _bannerState = AdState.notLoaded;
      _interstitialState = AdState.notLoaded;
      _rewardedState = AdState.notLoaded;
      _appOpenState = AdState.notLoaded;
      
      debugPrint('🎉 Premium activated - All ads removed');
    } else {
      // Reload ads
      loadBannerAd();
      _preloadInterstitialAd();
      _preloadRewardedAd();
      
      debugPrint('📢 Premium deactivated - Ads enabled');
    }
  }
  
  // ==================== BANNER AD ====================
  
  /// Load banner ad
  void loadBannerAd() {
    if (_isPremium || _bannerState == AdState.loading || _bannerState == AdState.loaded) {
      return;
    }
    
    _bannerState = AdState.loading;
    
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerState = AdState.loaded;
          debugPrint('✅ Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _bannerState = AdState.failed;
          ad.dispose();
          _bannerAd = null;
          debugPrint('❌ Banner ad failed to load: $error');
        },
        onAdOpened: (ad) {
          _incrementAdImpressions();
          debugPrint('👁️ Banner ad opened');
        },
      ),
    );
    
    _bannerAd?.load();
  }
  
  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerState = AdState.notLoaded;
  }
  
  // ==================== INTERSTITIAL AD ====================
  
  /// Preload interstitial ad
  void _preloadInterstitialAd() {
    if (_isPremium || _interstitialState == AdState.loading || _interstitialState == AdState.loaded) {
      return;
    }
    
    _interstitialState = AdState.loading;
    
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialState = AdState.loaded;
          debugPrint('✅ Interstitial ad loaded');
          
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _interstitialState = AdState.showing;
              _incrementAdImpressions();
              debugPrint('👁️ Interstitial ad showing');
            },
            onAdDismissedFullScreenContent: (ad) {
              _interstitialState = AdState.dismissed;
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitialAd(); // Preload next one
              debugPrint('✅ Interstitial ad dismissed');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _interstitialState = AdState.failed;
              ad.dispose();
              _interstitialAd = null;
              debugPrint('❌ Interstitial ad failed to show: $error');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialState = AdState.failed;
          _interstitialAd = null;
          debugPrint('❌ Interstitial ad failed to load: $error');
        },
      ),
    );
  }
  
  /// Show interstitial ad if conditions are met
  Future<bool> showInterstitialAd() async {
    if (_isPremium) {
      debugPrint('⚠️ Premium user - Interstitial ad skipped');
      return false;
    }
    
    if (!_canShowInterstitial()) {
      debugPrint('⚠️ Interstitial ad conditions not met');
      return false;
    }
    
    if (_interstitialState != AdState.loaded || _interstitialAd == null) {
      debugPrint('⚠️ Interstitial ad not ready');
      _preloadInterstitialAd(); // Try to load
      return false;
    }
    
    await _interstitialAd?.show();
    _lastInterstitialTime = DateTime.now();
    await _prefs?.setString(
      AdConstants.keyLastInterstitialTime,
      _lastInterstitialTime!.toIso8601String(),
    );
    _actionCount = 0;
    await _prefs?.setInt(AdConstants.keyActionCount, _actionCount);
    
    return true;
  }
  
  /// Check if interstitial ad can be shown
  bool _canShowInterstitial() {
    // Check days since install
    if (daysSinceInstall < AdConstants.minDaysBeforeInterstitials) {
      return false;
    }
    
    // Check cooldown
    if (_lastInterstitialTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialTime!);
      if (timeSinceLastAd < AdConstants.interstitialCooldown) {
        return false;
      }
    }
    
    // Check action count
    if (_actionCount < AdConstants.minActionsBeforeInterstitial) {
      return false;
    }
    
    return true;
  }
  
  // ==================== REWARDED AD ====================
  
  /// Preload rewarded ad
  void _preloadRewardedAd() {
    if (_isPremium || _rewardedState == AdState.loading || _rewardedState == AdState.loaded) {
      return;
    }
    
    _rewardedState = AdState.loading;
    
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedState = AdState.loaded;
          debugPrint('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedState = AdState.failed;
          _rewardedAd = null;
          debugPrint('❌ Rewarded ad failed to load: $error');
        },
      ),
    );
  }
  
  /// Show rewarded ad
  Future<bool> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_isPremium) {
      // Premium users get reward without watching ad
      onUserEarnedReward(RewardItem(1, 'premium'));
      debugPrint('🎉 Premium user - Reward granted without ad');
      return true;
    }
    
    if (_rewardedState != AdState.loaded || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not ready');
      _preloadRewardedAd(); // Try to load
      return false;
    }
    
    bool rewardGranted = false;
    
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _rewardedState = AdState.showing;
        _incrementAdImpressions();
        debugPrint('👁️ Rewarded ad showing');
      },
      onAdDismissedFullScreenContent: (ad) {
        _rewardedState = AdState.dismissed;
        ad.dispose();
        _rewardedAd = null;
        _preloadRewardedAd(); // Preload next one
        debugPrint('✅ Rewarded ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _rewardedState = AdState.failed;
        ad.dispose();
        _rewardedAd = null;
        debugPrint('❌ Rewarded ad failed to show: $error');
      },
    );
    
    await _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        rewardGranted = true;
        onUserEarnedReward(reward);
        debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
      },
    );
    
    return rewardGranted;
  }
  
  // ==================== APP OPEN AD ====================
  
  /// Load app open ad
  void loadAppOpenAd() {
    if (_isPremium || _appOpenState == AdState.loading || _appOpenState == AdState.loaded) {
      return;
    }
    
    _appOpenState = AdState.loading;
    
    AppOpenAd.load(
      adUnitId: AdConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenState = AdState.loaded;
          debugPrint('✅ App open ad loaded');
        },
        onAdFailedToLoad: (error) {
          _appOpenState = AdState.failed;
          _appOpenAd = null;
          debugPrint('❌ App open ad failed to load: $error');
        },
      ),
    );
  }
  
  /// Show app open ad if conditions are met
  Future<bool> showAppOpenAd() async {
    if (_isPremium) {
      debugPrint('⚠️ Premium user - App open ad skipped');
      return false;
    }
    
    if (!_canShowAppOpenAd()) {
      debugPrint('⚠️ App open ad conditions not met');
      return false;
    }
    
    if (_appOpenState != AdState.loaded || _appOpenAd == null) {
      debugPrint('⚠️ App open ad not ready');
      loadAppOpenAd(); // Try to load
      return false;
    }
    
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _appOpenState = AdState.showing;
        _incrementAdImpressions();
        debugPrint('👁️ App open ad showing');
      },
      onAdDismissedFullScreenContent: (ad) {
        _appOpenState = AdState.dismissed;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // Preload next one
        debugPrint('✅ App open ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _appOpenState = AdState.failed;
        ad.dispose();
        _appOpenAd = null;
        debugPrint('❌ App open ad failed to show: $error');
      },
    );
    
    await _appOpenAd?.show();
    _lastAppOpenTime = DateTime.now();
    await _prefs?.setString(
      AdConstants.keyLastAppOpenTime,
      _lastAppOpenTime!.toIso8601String(),
    );
    
    return true;
  }
  
  /// Check if app open ad can be shown
  bool _canShowAppOpenAd() {
    // Check days since install (wait at least 5 days)
    if (daysSinceInstall < 5) {
      return false;
    }
    
    // Check cooldown
    if (_lastAppOpenTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAppOpenTime!);
      if (timeSinceLastAd < AdConstants.appOpenCooldown) {
        return false;
      }
    }
    
    // Check background time
    if (_appBackgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_appBackgroundTime!);
      if (backgroundDuration < AdConstants.minBackgroundTimeForAppOpen) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Call when app goes to background
  void onAppBackground() {
    _appBackgroundTime = DateTime.now();
    _prefs?.setString(
      AdConstants.keyAppBackgroundTime,
      _appBackgroundTime!.toIso8601String(),
    );
    debugPrint('📱 App went to background');
  }
  
  /// Call when app comes to foreground
  void onAppForeground() {
    debugPrint('📱 App came to foreground');
    
    // Try to show app open ad
    if (!_isPremium) {
      showAppOpenAd();
    }
  }
  
  // ==================== ACTION TRACKING ====================
  
  /// Increment action count (call after user actions like save, delete, etc.)
  Future<void> incrementActionCount() async {
    if (_isPremium) return;
    
    _actionCount++;
    await _prefs?.setInt(AdConstants.keyActionCount, _actionCount);
    
    debugPrint('📊 Action count: $_actionCount');
    
    // Check if we should show interstitial
    if (_actionCount >= AdConstants.actionsBetweenInterstitials) {
      await showInterstitialAd();
    }
  }
  
  /// Increment ad impressions and check for premium prompt
  Future<void> _incrementAdImpressions() async {
    _adImpressions++;
    await _prefs?.setInt(AdConstants.keyAdImpressions, _adImpressions);
    
    debugPrint('📊 Ad impressions: $_adImpressions');
    
    // Check if we should show premium prompt
    if (_shouldShowPremiumPrompt()) {
      _onPremiumPromptShow?.call();
      _lastPromptTime = DateTime.now();
      await _prefs?.setString(
        AdConstants.keyLastPromptTime,
        _lastPromptTime!.toIso8601String(),
      );
    }
  }
  
  /// Check if premium prompt should be shown
  bool _shouldShowPremiumPrompt() {
    if (_isPremium) return false;
    
    // Check impression count
    if (_adImpressions < AdConstants.impressionsBeforePrompt) {
      return false;
    }
    
    // Check cooldown
    if (_lastPromptTime != null) {
      final timeSinceLastPrompt = DateTime.now().difference(_lastPromptTime!);
      if (timeSinceLastPrompt < AdConstants.promptCooldown) {
        return false;
      }
    }
    
    return true;
  }
  
  // ==================== CLEANUP ====================
  
  /// Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _appOpenAd = null;
    
    debugPrint('🧹 AdManager disposed');
  }
}
