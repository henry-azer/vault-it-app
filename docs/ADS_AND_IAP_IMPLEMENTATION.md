# 📱 Ads & In-App Purchase Implementation Guide

## 🎯 Overview

This document provides a complete guide to the production-ready ads and in-app purchase (IAP) system implemented in Vault-It. The system is designed to maximize revenue while maintaining excellent user experience.

---

## 📊 Monetization Strategy

### User Experience Timeline

| Phase | Days | Ad Strategy | Purpose |
|-------|------|-------------|---------|
| **Day 1-2** | 1-2 | Banner ads only (bottom) | Build trust, minimal intrusion |
| **Day 3-4** | 3-4 | Add interstitials (after 3-5 actions) | Gentle introduction to full-screen ads |
| **Day 5+** | 5+ | Enable rewarded ads (backup bonus) | High-value ads with user benefit |
| **Day 7+** | 7+ | App open ads (on resume) | Maximize revenue from engaged users |
| **After 5 ads** | Any | Show "Remove Ads" prompt | Conversion opportunity |

### Ad Types & Revenue

| Ad Type | Location | Frequency | eCPM | User Impact | Implementation |
|---------|----------|-----------|------|-------------|----------------|
| **Banner** | Bottom of screens | Always visible | Low | Minimal | `BannerAdWidget` |
| **Interstitial** | After save/delete actions | Every 3-5 actions | Medium | Moderate | `InterstitialAdHelper` |
| **Rewarded** | Backup export feature | Optional (user choice) | High | Positive | `RewardedAdDialog` |
| **App Open** | App resume (30s+ background) | Once per 4 hours | Medium | Low | `AdManager.showAppOpenAd()` |

---

## 🏗️ Architecture

### Core Components

```
lib/
├── core/
│   ├── ads/
│   │   ├── ad_manager.dart              # Singleton ad controller
│   │   ├── ad_state.dart                # Ad loading states
│   │   ├── ad_config.dart               # Platform-specific ad IDs
│   │   └── ad_helper.dart               # Utility functions
│   ├── purchase/
│   │   ├── purchase_manager.dart        # IAP controller
│   │   ├── purchase_provider.dart       # State management
│   │   └── purchase_config.dart         # Product IDs & features
│   └── constants/
│       └── ad_constants.dart            # Timing & frequency constants
├── features/
│   └── premium/
│       └── presentation/
│           ├── screens/
│           │   └── premium_screen.dart  # Purchase UI
│           └── widgets/
│               ├── premium_card.dart
│               └── feature_item.dart
└── widgets/
    └── ads/
        ├── banner_ad_widget.dart
        ├── interstitial_ad_helper.dart
        └── rewarded_ad_dialog.dart
```

---

## 🔧 Configuration

### 1. AdMob Setup

#### Create AdMob Account
1. Go to [AdMob Console](https://apps.admob.com/)
2. Create new app for Android & iOS
3. Create ad units for each type:
   - Banner (320x50)
   - Interstitial (Full screen)
   - Rewarded (Full screen)
   - App Open (Full screen)

#### Update Ad Unit IDs

**File:** `lib/core/constants/ad_constants.dart`

```dart
// Replace test IDs with your production IDs
static const String androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String androidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String androidRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String androidAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

static const String iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String iosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String iosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String iosAppOpenId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

#### Update App IDs

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

### 2. In-App Purchase Setup

#### Google Play Console
1. Go to **Monetize** → **In-app products**
2. Create new product:
   - **Product ID:** `remove_ads_premium`
   - **Name:** "Premium - Remove Ads"
   - **Description:** "Remove all ads forever and unlock premium features"
   - **Price:** $1.99 (or your chosen price)
   - **Status:** Active

#### App Store Connect
1. Go to **Features** → **In-App Purchases**
2. Create new In-App Purchase:
   - **Type:** Non-Consumable
   - **Reference Name:** "Premium - Remove Ads"
   - **Product ID:** `remove_ads_premium`
   - **Price:** $1.99 (or your chosen price)
3. Add localized descriptions
4. Submit for review

---

## 💻 Usage Examples

### Display Banner Ad

```dart
import 'package:vault_it/widgets/ads/banner_ad_widget.dart';

// In your screen widget
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: YourContent(),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BannerAdWidget(), // Automatically shows/hides based on premium status
        YourBottomNav(),
      ],
    ),
  );
}
```

### Show Interstitial After Action

```dart
import 'package:vault_it/widgets/ads/interstitial_ad_helper.dart';

// After user saves/deletes an account
await accountProvider.saveAccount(account);

// Increment action count and show ad if conditions met
await InterstitialAdHelper.showAfterAction();
```

### Show Rewarded Ad for Feature

```dart
import 'package:vault_it/widgets/ads/rewarded_ad_dialog.dart';

// Before premium feature
final granted = await RewardedAdDialog.showForPremiumBackup(context);

if (granted) {
  // User watched ad or is premium - grant access
  await performPremiumBackup();
} else {
  // User declined
  showSnackBar('Watch ad to unlock this feature');
}
```

### Check Premium Status

```dart
import 'package:vault_it/core/ads/ad_manager.dart';

final adManager = AdManager();

if (adManager.isPremium) {
  // User is premium - no ads
  showPremiumFeature();
} else {
  // Free user - show ads
  showAdSupportedFeature();
}
```

### Navigate to Premium Screen

```dart
import 'package:vault_it/config/routes/app_routes.dart';

// From any screen
Navigator.pushNamed(context, Routes.premium);
```

---

## 🎮 Ad Frequency Control

### Automatic Frequency Management

The `AdManager` automatically controls ad frequency based on:

1. **Days Since Install**
   - Interstitials: Wait 2+ days
   - App Open Ads: Wait 5+ days

2. **Cooldown Timers**
   - Interstitials: 2 minutes between ads
   - App Open Ads: 4 hours between ads

3. **Action Count**
   - Minimum 3 actions before first interstitial
   - Show every 5 actions thereafter

4. **Background Time**
   - App Open Ads: Only if app was in background for 30+ seconds

### Customize Frequency

**File:** `lib/core/constants/ad_constants.dart`

```dart
// Adjust these values to optimize for your app
static const Duration interstitialCooldown = Duration(minutes: 2);
static const Duration appOpenCooldown = Duration(hours: 4);
static const int minActionsBeforeInterstitial = 3;
static const int actionsBetweenInterstitials = 5;
static const int minDaysBeforeInterstitials = 2;
```

---

## 💎 Premium Features

### Current Premium Benefits

1. ✅ Remove all ads forever
2. ✅ Priority support badge
3. ✅ Unlimited backup exports
4. ✅ Early access to new features
5. ✅ Premium themes (coming soon)
6. ✅ Support app development

### Add More Premium Features

**File:** `lib/core/purchase/purchase_config.dart`

```dart
static const List<String> premiumFeatures = [
  'Remove all ads forever',
  'Priority support',
  'Unlimited backup exports',
  'Early access to new features',
  'Premium themes (coming soon)',
  'Your new feature here',  // Add more features
];
```

---

## 🧪 Testing

### Test Mode

The app is currently configured with **test ad unit IDs**. These will show test ads that don't generate revenue but allow you to test functionality.

### Test Ads on Device

1. **Android:**
   ```bash
   flutter run --release
   ```

2. **iOS:**
   ```bash
   flutter run --release
   ```

3. Test all ad types:
   - Banner: Should appear at bottom of screens
   - Interstitial: Perform 3+ actions (save/delete accounts)
   - Rewarded: Try backup export feature
   - App Open: Put app in background for 30s, then resume

### Test In-App Purchase

#### Android (Google Play)
1. Add test account in Google Play Console
2. Use internal testing track
3. Test purchase flow
4. Test restore purchases

#### iOS (App Store)
1. Create Sandbox Tester account in App Store Connect
2. Sign out of App Store on device
3. Test purchase (will prompt for sandbox account)
4. Test restore purchases

---

## 📈 Analytics & Monitoring

### Track These Metrics

1. **Ad Performance**
   - Impressions per ad type
   - Click-through rate (CTR)
   - eCPM by ad type
   - Fill rate

2. **User Behavior**
   - Days since install
   - Actions per session
   - Ad impressions before purchase
   - Purchase conversion rate

3. **Revenue**
   - Ad revenue by type
   - IAP revenue
   - Total revenue per user (ARPU)
   - Lifetime value (LTV)

### AdMob Reports

Access detailed reports in [AdMob Console](https://apps.admob.com/):
- Revenue by ad unit
- eCPM trends
- Fill rate issues
- Geographic performance

---

## 🚀 Production Deployment Checklist

### Before Release

- [ ] Replace all test ad unit IDs with production IDs
- [ ] Update AdMob App IDs in AndroidManifest.xml and Info.plist
- [ ] Configure IAP products in Google Play Console
- [ ] Configure IAP products in App Store Connect
- [ ] Test ads on real devices (not emulators)
- [ ] Test purchase flow end-to-end
- [ ] Test restore purchases
- [ ] Verify premium status persists after app restart
- [ ] Test ad frequency limits
- [ ] Verify ads don't show for premium users
- [ ] Test on both Android and iOS
- [ ] Review privacy policy for ads and purchases
- [ ] Add IAP and ads disclosures to store listings

### Post-Release

- [ ] Monitor AdMob dashboard for ad performance
- [ ] Track purchase conversion rate
- [ ] Monitor crash reports for ad-related issues
- [ ] A/B test different ad frequencies
- [ ] A/B test different premium prices
- [ ] Collect user feedback on ad experience
- [ ] Optimize based on metrics

---

## 🔍 Troubleshooting

### Ads Not Showing

1. **Check Premium Status**
   ```dart
   debugPrint('Is Premium: ${AdManager().isPremium}');
   ```

2. **Check Ad State**
   ```dart
   debugPrint('Banner State: ${AdManager().bannerState}');
   debugPrint('Interstitial State: ${AdManager().interstitialState}');
   ```

3. **Check Initialization**
   ```dart
   debugPrint('Ad Manager Initialized: ${AdManager().isInitialized}');
   ```

4. **Common Issues:**
   - Using test IDs in production (low fill rate)
   - AdMob account not approved yet
   - App not added to AdMob
   - Invalid ad unit IDs
   - Network connectivity issues

### Purchase Not Working

1. **Check Initialization**
   ```dart
   debugPrint('Purchase Manager Initialized: ${PurchaseManager().isInitialized}');
   debugPrint('Product Available: ${PurchaseManager().isProductAvailable}');
   ```

2. **Common Issues:**
   - Product ID mismatch
   - Product not active in store console
   - App not published (even in testing track)
   - Billing not configured
   - Test account not configured

### Ad Frequency Issues

1. **Check Timing**
   ```dart
   debugPrint('Days Since Install: ${AdManager().daysSinceInstall}');
   debugPrint('Ad Impressions: ${AdManager().adImpressions}');
   ```

2. **Adjust Constants**
   - Modify values in `ad_constants.dart`
   - Test with shorter durations during development

---

## 📚 Additional Resources

### Documentation
- [Google Mobile Ads Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [In-App Purchase Flutter Plugin](https://pub.dev/packages/in_app_purchase)
- [AdMob Best Practices](https://support.google.com/admob/answer/6128543)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [App Store In-App Purchase](https://developer.apple.com/in-app-purchase/)

### Support
- AdMob Support: https://support.google.com/admob
- Google Play Console Support: https://support.google.com/googleplay
- App Store Connect Support: https://developer.apple.com/support/app-store-connect/

---

## 🎉 Success Metrics

### Target KPIs

| Metric | Target | Notes |
|--------|--------|-------|
| **Ad Fill Rate** | >90% | Percentage of ad requests filled |
| **eCPM** | >$2.00 | Revenue per 1000 impressions |
| **Purchase Conversion** | >2% | Users who purchase premium |
| **ARPU** | >$0.50 | Average revenue per user |
| **Retention (Day 7)** | >40% | Users still active after 7 days |

### Optimization Tips

1. **Increase eCPM:**
   - Enable ad mediation
   - Target tier-1 countries
   - Use all ad formats
   - Optimize ad placement

2. **Increase Conversions:**
   - Show prompt after 5 ad impressions
   - Offer time-limited discounts
   - Bundle more premium features
   - A/B test pricing

3. **Improve Retention:**
   - Don't show ads too early
   - Respect cooldown periods
   - Provide value before monetizing
   - Premium users get best experience

---

## 📝 License & Credits

This implementation follows industry best practices and AdMob policies. Ensure compliance with:
- Google AdMob Program Policies
- Google Play Developer Program Policies
- Apple App Store Review Guidelines
- GDPR/CCPA privacy requirements

---

**Last Updated:** October 2024  
**Version:** 1.0.0  
**Maintainer:** Vault-It Development Team
