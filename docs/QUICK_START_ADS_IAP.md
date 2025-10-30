# 🚀 Quick Start: Ads & IAP Setup

## ⚡ 5-Minute Setup Guide

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Create AdMob Account

1. Go to https://apps.admob.com/
2. Click "Get Started"
3. Add your app (Android & iOS)
4. Create 4 ad units for each platform:
   - Banner Ad
   - Interstitial Ad
   - Rewarded Ad
   - App Open Ad

### Step 3: Update Ad Unit IDs

**File:** `lib/core/constants/ad_constants.dart`

Replace the test IDs (lines 24-39) with your production IDs from AdMob.

### Step 4: Update App IDs

**Android:** `android/app/src/main/AndroidManifest.xml` (line 65)
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_ANDROID_APP_ID~XXXXXXXXXX"/>
```

**iOS:** `ios/Runner/Info.plist` (line 55)
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_IOS_APP_ID~XXXXXXXXXX</string>
```

### Step 5: Configure In-App Purchase

#### Google Play Console
1. Go to Monetize → In-app products
2. Create product: `remove_ads_premium` at $1.99
3. Activate product

#### App Store Connect
1. Go to Features → In-App Purchases
2. Create Non-Consumable: `remove_ads_premium` at $1.99
3. Submit for review

### Step 6: Test

```bash
# Test on Android
flutter run --release

# Test on iOS
flutter run --release
```

---

## 🎯 Where Ads Appear

### Automatically Integrated

The ads are already integrated and will show automatically based on user behavior:

1. **Banner Ads** - Bottom of main screens (Vault, Generator, Settings)
2. **Interstitial Ads** - After saving/deleting accounts (every 3-5 actions)
3. **Rewarded Ads** - Before premium backup export
4. **App Open Ads** - When app resumes from background (after 5+ days of use)

### Manual Integration (Optional)

To add banner ads to additional screens:

```dart
import 'package:vault_it/widgets/ads/banner_ad_widget.dart';

// Add to bottom of your screen
bottomNavigationBar: const BannerAdWidget(),
```

To show interstitial after custom actions:

```dart
import 'package:vault_it/widgets/ads/interstitial_ad_helper.dart';

// After user action
await InterstitialAdHelper.showAfterAction();
```

---

## 💎 Premium Features

Users can purchase premium ($1.99) to:
- ✅ Remove all ads forever
- ✅ Get priority support
- ✅ Unlock unlimited backups
- ✅ Access early features

Premium button is in Settings screen (top-right corner).

---

## 🧪 Testing Checklist

- [ ] Banner ads show at bottom of screens
- [ ] Interstitial shows after 3+ account saves/deletes
- [ ] Rewarded ad dialog shows before backup export
- [ ] Premium screen opens from settings
- [ ] Purchase flow works (use test account)
- [ ] Ads disappear after purchase
- [ ] Restore purchases works
- [ ] Premium status persists after app restart

---

## 📊 Monitor Performance

### AdMob Dashboard
- Revenue: https://apps.admob.com/
- eCPM, Fill Rate, Impressions

### Play Console / App Store Connect
- Purchase analytics
- Conversion rates
- Revenue reports

---

## 🆘 Need Help?

See full documentation: `docs/ADS_AND_IAP_IMPLEMENTATION.md`

### Common Issues

**Ads not showing?**
- Check if using test IDs (they work but have low fill rate)
- Verify AdMob account is approved
- Check internet connection
- Wait 24-48 hours after adding app to AdMob

**Purchase not working?**
- Verify product ID matches exactly: `remove_ads_premium`
- Check product is active in store console
- Use test account for testing
- App must be published (even in internal testing)

---

## 🎉 You're Done!

Your app now has:
- ✅ Professional ad integration
- ✅ Smart frequency control
- ✅ Premium purchase option
- ✅ Automatic ad removal for premium users
- ✅ Production-ready monetization

**Next Steps:**
1. Test thoroughly on real devices
2. Monitor AdMob dashboard
3. Optimize based on metrics
4. A/B test pricing and frequency
5. Collect user feedback

Good luck with your monetization! 🚀💰
