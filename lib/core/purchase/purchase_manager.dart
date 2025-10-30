import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault_it/core/purchase/purchase_config.dart';

/// Singleton Purchase Manager for handling in-app purchases
class PurchaseManager {
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();

  // ==================== STATE ====================
  
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isInitialized = false;
  bool _isPremium = false;
  SharedPreferences? _prefs;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  ProductDetails? _removeAdsProduct;
  bool _isProductAvailable = false;
  bool _isPurchasing = false;
  
  // Callbacks
  Function(bool success, String? error)? _onPurchaseComplete;
  
  // ==================== GETTERS ====================
  
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  bool get isProductAvailable => _isProductAvailable;
  bool get isPurchasing => _isPurchasing;
  ProductDetails? get removeAdsProduct => _removeAdsProduct;
  String get productPrice => _removeAdsProduct?.price ?? PurchaseConfig.displayPrice;
  
  // ==================== INITIALIZATION ====================
  
  /// Initialize IAP and check premium status
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if IAP is available
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('⚠️ In-app purchases not available on this device');
        return;
      }
      
      // Load preferences
      _prefs = await SharedPreferences.getInstance();
      _isPremium = _prefs?.getBool(PurchaseConfig.keyIsPremium) ?? false;
      
      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          debugPrint('❌ Purchase stream error: $error');
        },
      );
      
      // Load product details
      await _loadProducts();
      
      // Restore purchases
      await restorePurchases();
      
      _isInitialized = true;
      debugPrint('✅ PurchaseManager initialized - Premium: $_isPremium');
    } catch (e) {
      debugPrint('❌ PurchaseManager initialization failed: $e');
    }
  }
  
  /// Load product details from stores
  Future<void> _loadProducts() async {
    try {
      const productIds = {PurchaseConfig.removeAdsProductId};
      final response = await _iap.queryProductDetails(productIds);
      
      if (response.error != null) {
        debugPrint('❌ Failed to load products: ${response.error}');
        return;
      }
      
      if (response.productDetails.isEmpty) {
        debugPrint('⚠️ No products found');
        return;
      }
      
      _removeAdsProduct = response.productDetails.first;
      _isProductAvailable = true;
      
      debugPrint('✅ Product loaded: ${_removeAdsProduct?.title} - ${_removeAdsProduct?.price}');
    } catch (e) {
      debugPrint('❌ Failed to load products: $e');
    }
  }
  
  // ==================== PURCHASE FLOW ====================
  
  /// Purchase remove ads premium
  Future<bool> purchaseRemoveAds({
    Function(bool success, String? error)? onComplete,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ PurchaseManager not initialized');
      onComplete?.call(false, 'Purchase system not ready');
      return false;
    }
    
    if (_isPremium) {
      debugPrint('⚠️ Already premium');
      onComplete?.call(false, 'Already premium');
      return false;
    }
    
    if (!_isProductAvailable || _removeAdsProduct == null) {
      debugPrint('⚠️ Product not available');
      onComplete?.call(false, 'Product not available');
      return false;
    }
    
    if (_isPurchasing) {
      debugPrint('⚠️ Purchase already in progress');
      return false;
    }
    
    try {
      _isPurchasing = true;
      _onPurchaseComplete = onComplete;
      
      final purchaseParam = PurchaseParam(
        productDetails: _removeAdsProduct!,
      );
      
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        _isPurchasing = false;
        _onPurchaseComplete = null;
        onComplete?.call(false, 'Failed to initiate purchase');
        return false;
      }
      
      debugPrint('🛒 Purchase initiated');
      return true;
    } catch (e) {
      _isPurchasing = false;
      _onPurchaseComplete = null;
      debugPrint('❌ Purchase failed: $e');
      onComplete?.call(false, e.toString());
      return false;
    }
  }
  
  /// Handle purchase updates from stream
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('📦 Purchase update: ${purchase.status}');
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('⏳ Purchase pending');
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify purchase
          final valid = await _verifyPurchase(purchase);
          
          if (valid) {
            await _deliverProduct(purchase);
            _onPurchaseComplete?.call(true, null);
            debugPrint('✅ Purchase successful');
          } else {
            _onPurchaseComplete?.call(false, 'Purchase verification failed');
            debugPrint('❌ Purchase verification failed');
          }
          
          // Complete purchase
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          
          _isPurchasing = false;
          _onPurchaseComplete = null;
          break;
          
        case PurchaseStatus.error:
          _onPurchaseComplete?.call(false, purchase.error?.message);
          debugPrint('❌ Purchase error: ${purchase.error}');
          _isPurchasing = false;
          _onPurchaseComplete = null;
          break;
          
        case PurchaseStatus.canceled:
          _onPurchaseComplete?.call(false, 'Purchase canceled');
          debugPrint('⚠️ Purchase canceled');
          _isPurchasing = false;
          _onPurchaseComplete = null;
          break;
      }
    }
  }
  
  /// Verify purchase (implement server-side verification in production)
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // TODO: Implement server-side verification in production
    // For now, we trust the platform
    return true;
  }
  
  /// Deliver product to user
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    if (purchase.productID == PurchaseConfig.removeAdsProductId) {
      await _setPremiumStatus(true);
      
      // Save purchase details
      await _prefs?.setString(
        PurchaseConfig.keyPurchaseDate,
        DateTime.now().toIso8601String(),
      );
      
      if (purchase.verificationData.serverVerificationData.isNotEmpty) {
        await _prefs?.setString(
          PurchaseConfig.keyPurchaseToken,
          purchase.verificationData.serverVerificationData,
        );
      }
    }
  }
  
  // ==================== RESTORE PURCHASES ====================
  
  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      debugPrint('⚠️ PurchaseManager not initialized');
      return false;
    }
    
    try {
      debugPrint('🔄 Restoring purchases...');
      await _iap.restorePurchases();
      
      // Check if premium was restored
      if (_isPremium) {
        debugPrint('✅ Premium restored');
        return true;
      } else {
        debugPrint('⚠️ No purchases to restore');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Restore purchases failed: $e');
      return false;
    }
  }
  
  // ==================== PREMIUM STATUS ====================
  
  /// Set premium status
  Future<void> _setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    await _prefs?.setBool(PurchaseConfig.keyIsPremium, isPremium);
    debugPrint('🎉 Premium status updated: $isPremium');
  }
  
  /// Manually set premium status (for testing or promo codes)
  Future<void> setPremiumStatusManually(bool isPremium) async {
    await _setPremiumStatus(isPremium);
  }
  
  // ==================== CLEANUP ====================
  
  /// Dispose purchase manager
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('🧹 PurchaseManager disposed');
  }
}
