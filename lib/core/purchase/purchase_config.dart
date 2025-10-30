/// In-App Purchase configuration
class PurchaseConfig {
  // ==================== PRODUCT IDS ====================
  
  /// Remove ads premium product ID (must match Google Play Console & App Store Connect)
  static const String removeAdsProductId = 'remove_ads_premium';
  
  /// Premium product price (for display only - actual price comes from stores)
  static const String displayPrice = '\$1.99';
  
  // ==================== STORAGE KEYS ====================
  
  static const String keyIsPremium = 'is_premium';
  static const String keyPurchaseDate = 'purchase_date';
  static const String keyPurchaseToken = 'purchase_token';
  
  // ==================== PREMIUM FEATURES ====================
  
  static const List<String> premiumFeatures = [
    'Remove all ads forever',
    'Priority support',
    'Unlimited backup exports',
    'Early access to new features',
    'Premium themes (coming soon)',
    'Support app development',
  ];
}
