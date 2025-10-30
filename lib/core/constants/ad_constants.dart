/// Ad timing and frequency constants for optimal user experience and revenue
class AdConstants {
  // ==================== AD FREQUENCY CONTROL ====================
  
  /// Minimum time between interstitial ads (2 minutes)
  static const Duration interstitialCooldown = Duration(minutes: 2);
  
  /// Minimum time between app open ads (4 hours)
  static const Duration appOpenCooldown = Duration(hours: 4);
  
  /// Minimum actions required before showing first interstitial
  static const int minActionsBeforeInterstitial = 3;
  
  /// Actions between interstitial ads
  static const int actionsBetweenInterstitials = 5;
  
  /// Minimum app usage days before showing interstitials
  static const int minDaysBeforeInterstitials = 2;
  
  /// Minimum background time before showing app open ad (30 seconds)
  static const Duration minBackgroundTimeForAppOpen = Duration(seconds: 30);
  
  /// Ad impressions before showing "Remove Ads" prompt
  static const int impressionsBeforePrompt = 5;
  
  /// Hours to wait before showing prompt again if dismissed
  static const Duration promptCooldown = Duration(hours: 24);
  
  // ==================== AD UNIT IDS ====================
  
  // Android Test IDs (replace with real IDs in production)
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String androidAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  
  // iOS Test IDs (replace with real IDs in production)
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String iosAppOpenId = 'ca-app-pub-3940256099942544/5575463023';
  
  // ==================== PRODUCTION AD UNIT IDS ====================
  // TODO: Replace these with your actual AdMob ad unit IDs before production release
  
  // static const String androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String androidRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String androidAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // static const String iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String iosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  // static const String iosAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // ==================== STORAGE KEYS ====================
  
  static const String keyLastInterstitialTime = 'last_interstitial_time';
  static const String keyLastAppOpenTime = 'last_app_open_time';
  static const String keyActionCount = 'action_count';
  static const String keyAdImpressions = 'ad_impressions';
  static const String keyLastPromptTime = 'last_prompt_time';
  static const String keyInstallDate = 'install_date';
  static const String keyAppBackgroundTime = 'app_background_time';
}
