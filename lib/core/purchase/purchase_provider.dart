import 'package:flutter/foundation.dart';
import 'package:vault_it/core/ads/ad_manager.dart';
import 'package:vault_it/core/purchase/purchase_manager.dart';

/// Provider for managing purchase state across the app
class PurchaseProvider extends ChangeNotifier {
  final PurchaseManager _purchaseManager = PurchaseManager();
  final AdManager _adManager = AdManager();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // ==================== GETTERS ====================
  
  bool get isPremium => _purchaseManager.isPremium;
  bool get isProductAvailable => _purchaseManager.isProductAvailable;
  bool get isPurchasing => _purchaseManager.isPurchasing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get productPrice => _purchaseManager.productPrice;
  
  // ==================== INITIALIZATION ====================
  
  /// Initialize purchase system
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _purchaseManager.initialize();
      
      // Sync premium status with ad manager
      await _adManager.setPremiumStatus(_purchaseManager.isPremium);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ PurchaseProvider initialization failed: $e');
    }
  }
  
  // ==================== PURCHASE ====================
  
  /// Purchase remove ads premium
  Future<bool> purchaseRemoveAds() async {
    _errorMessage = null;
    notifyListeners();
    
    final success = await _purchaseManager.purchaseRemoveAds(
      onComplete: (success, error) async {
        if (success) {
          // Update ad manager
          await _adManager.setPremiumStatus(true);
          _errorMessage = null;
        } else {
          _errorMessage = error ?? 'Purchase failed';
        }
        notifyListeners();
      },
    );
    
    return success;
  }
  
  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final restored = await _purchaseManager.restorePurchases();
      
      if (restored) {
        // Update ad manager
        await _adManager.setPremiumStatus(true);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return restored;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
