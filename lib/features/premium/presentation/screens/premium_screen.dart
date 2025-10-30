import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/purchase/purchase_config.dart';
import 'package:vault_it/core/purchase/purchase_provider.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/features/premium/presentation/widgets/feature_item.dart';
import 'package:vault_it/features/premium/presentation/widgets/premium_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize purchase provider if not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final purchaseProvider = context.read<PurchaseProvider>();
      if (!purchaseProvider.isLoading && !purchaseProvider.isPremium) {
        purchaseProvider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Consumer<PurchaseProvider>(
                builder: (context, purchaseProvider, child) {
                  if (purchaseProvider.isPremium) {
                    return _buildPremiumActiveView(isDark);
                  }
                  
                  return _buildPurchaseView(isDark, purchaseProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkHeaderStart, AppColors.darkHeaderEnd]
              : [AppColors.lightHeaderStart, AppColors.lightHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.premiumTitle.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  AppStrings.premiumSubtitle.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseView(bool isDark, PurchaseProvider purchaseProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero Card
        const PremiumCard(),
        const SizedBox(height: 24),
        
        // Features Title
        Text(
          AppStrings.premiumFeatures.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        // Features List
        ...PurchaseConfig.premiumFeatures.map((feature) {
          return FeatureItem(feature: feature);
        }),
        
        const SizedBox(height: 24),
        
        // Error Message
        if (purchaseProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    purchaseProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => purchaseProvider.clearError(),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        
        // Purchase Button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: purchaseProvider.isPurchasing || purchaseProvider.isLoading
                ? null
                : () => _handlePurchase(purchaseProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: purchaseProvider.isPurchasing || purchaseProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.workspace_premium, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${AppStrings.upgradeToPremium.tr} - ${purchaseProvider.productPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Restore Purchases Button
        TextButton(
          onPressed: purchaseProvider.isLoading
              ? null
              : () => _handleRestore(purchaseProvider),
          child: Text(AppStrings.restorePurchases.tr),
        ),
        
        const SizedBox(height: 24),
        
        // Terms & Privacy
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: Text(
                AppStrings.privacyPolicyTitle.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show terms of service
              },
              child: Text(
                AppStrings.termsOfServiceTitle.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumActiveView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.premiumActive.tr,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.premiumActiveMessage.tr,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...PurchaseConfig.premiumFeatures.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(PurchaseProvider purchaseProvider) async {
    final success = await purchaseProvider.purchaseRemoveAds();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.purchaseSuccess.tr),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleRestore(PurchaseProvider purchaseProvider) async {
    final restored = await purchaseProvider.restorePurchases();
    
    if (!mounted) return;
    
    if (restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.purchaseRestored.tr),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noPurchasesToRestore.tr),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
