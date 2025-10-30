import 'package:flutter/material.dart';
import 'package:vault_it/core/ads/ad_manager.dart';
import 'package:vault_it/core/utils/app_colors.dart';

/// Dialog to offer rewarded ad for premium features
class RewardedAdDialog {
  static final AdManager _adManager = AdManager();

  /// Show rewarded ad dialog for premium backup export
  static Future<bool> showForPremiumBackup(BuildContext context) async {
    if (_adManager.isPremium) {
      // Premium users get instant access
      return true;
    }

    // Show dialog
    final watch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Premium Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Watch a short ad to unlock unlimited backup exports for this session!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Or upgrade to Premium for ad-free unlimited backups forever!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (watch != true) return false;

    // Show rewarded ad
    bool rewardGranted = false;
    
    await _adManager.showRewardedAd(
      onUserEarnedReward: (reward) {
        rewardGranted = true;
      },
    );

    return rewardGranted;
  }

  /// Show rewarded ad dialog for any feature
  static Future<bool> showForFeature({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    if (_adManager.isPremium) {
      // Premium users get instant access
      return true;
    }

    // Show dialog
    final watch = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upgrade to Premium for instant access!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch Ad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (watch != true) return false;

    // Show rewarded ad
    bool rewardGranted = false;
    
    await _adManager.showRewardedAd(
      onUserEarnedReward: (reward) {
        rewardGranted = true;
      },
    );

    return rewardGranted;
  }
}
