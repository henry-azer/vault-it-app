# Google Drive Sync Setup Guide

This guide will help you configure Google Drive sync for the PassVault-It app.

## Overview

The Google Drive sync feature allows users to:
- **Backup** their password vault to Google Drive
- **Restore** their vault from Google Drive
- **Automatic sync** of vault data across devices

## Prerequisites

- Google Cloud Console account
- Flutter development environment
- Android Studio (for Android builds)
- Xcode (for iOS builds)

---

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Enter project name: `PassVault-It` (or your preferred name)
4. Click **Create**

---

## Step 2: Enable Google Drive API

1. In Google Cloud Console, go to **APIs & Services** → **Library**
2. Search for "Google Drive API"
3. Click on it and press **Enable**

---

## Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** user type (unless you have Google Workspace)
3. Click **Create**
4. Fill in the required information:
   - **App name**: PassVault-It
   - **User support email**: Your email
   - **Developer contact email**: Your email
5. Click **Save and Continue**
6. On **Scopes** screen, click **Add or Remove Scopes**
   - Add: `https://www.googleapis.com/auth/drive.appdata`
   - This scope allows the app to access its own data folder in Drive
7. Click **Save and Continue**
8. Add test users (your Google account) for testing
9. Click **Save and Continue**

---

## Step 4: Create OAuth 2.0 Credentials

### For Android

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Select **Android** as Application type
4. Enter:
   - **Name**: PassVault-It Android
   - **Package name**: `com.vaultit.app` (or your package name from `android/app/build.gradle`)
   - **SHA-1 certificate fingerprint**: Get this by running:
     ```bash
     # For debug build
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     
     # For Windows
     keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
     ```
5. Click **Create**
6. **Note**: You don't need to add this Client ID to your code. Google Sign-In handles it automatically.

### For iOS

1. Click **Create Credentials** → **OAuth client ID**
2. Select **iOS** as Application type
3. Enter:
   - **Name**: PassVault-It iOS
   - **Bundle ID**: Get this from `ios/Runner.xcodeproj/project.pbxproj`
4. Click **Create**
5. **Copy the iOS Client ID** (format: `xxx.apps.googleusercontent.com`)

---

## Step 5: Configure iOS

1. Open `ios/Runner/Info.plist`
2. Find the line with `YOUR_IOS_CLIENT_ID`
3. Replace it with your iOS Client ID from Step 4:
   ```xml
   <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
   ```
   Change to:
   ```xml
   <string>com.googleusercontent.apps.123456789-abcdefg.apps.googleusercontent.com</string>
   ```

---

## Step 6: Test the Implementation

1. Run the app on a physical device or emulator
2. Navigate to **Settings**
3. Scroll to **Data Management** section
4. You should see **Google Drive Sync** card
5. Tap **Sign in to enable cloud backup**
6. Complete Google Sign-In flow
7. Grant permissions for Drive access
8. After successful sign-in, you'll see:
   - Your Google account email
   - **Backup** button (uploads vault to Drive)
   - **Restore** button (downloads vault from Drive)

---

## Usage

### Backup to Google Drive
1. Tap **Backup** button
2. Your passwords are encrypted and uploaded to Google Drive's app data folder
3. Success message will appear

### Restore from Google Drive
1. Tap **Restore** button
2. Confirm the restore action (this will replace current data)
3. Your passwords are downloaded and restored
4. Success message shows number of restored accounts

### Sign Out
1. Tap the three-dot menu icon
2. Select **Sign Out**
3. You'll be signed out of Google Drive sync

---

## Security Notes

- Passwords are stored in Google Drive's **app data folder**
- This folder is private to the app and not accessible by users directly
- Data is automatically encrypted by Google Drive
- Only the app can access this data
- Deleting the app will delete the app data folder

---

## Troubleshooting

### "Sign in failed" error
- Verify OAuth credentials are correctly configured
- Check that SHA-1 fingerprint matches your keystore
- Ensure Google Drive API is enabled in Cloud Console
- For iOS, verify the URL scheme in Info.plist matches your Client ID

### "Failed to upload backup" error
- Check internet connection
- Verify Google Drive API quota (free tier has limits)
- Ensure user has granted Drive permissions

### "No backup found" error
- User hasn't created a backup yet
- Backup may have been created with a different Google account
- Check if app data folder exists in Google Drive

---

## Development Notes

### Architecture
- **Service**: `lib/core/services/google_drive_sync_service.dart`
- **Provider**: `lib/features/settings/data/providers/google_drive_sync_provider.dart`
- **UI**: `lib/features/settings/presentation/screens/settings_screen.dart`

### Key Dependencies
```yaml
google_sign_in: ^6.2.1
googleapis: ^13.2.0
extension_google_sign_in_as_googleapis_auth: ^2.0.12
```

### Backup Format
```json
{
  "backup_info": {
    "app_name": "Vault It",
    "version": "1.0.0",
    "export_date": "2024-01-01T12:00:00.000Z",
    "account_count": 10,
    "device_id": "google_drive"
  },
  "accounts": [...]
}
```

---

## Publishing Considerations

### For Production Release

1. **Create production OAuth credentials** with your release keystore SHA-1
   ```bash
   # Get release SHA-1
   keytool -list -v -keystore /path/to/release.keystore -alias your-alias
   ```

2. **Move OAuth consent screen to Production**
   - Go to OAuth consent screen
   - Click **Publish App**
   - This allows any Google user to use the app

3. **Update Info.plist** with production iOS Client ID

4. **Test thoroughly** with production credentials before release

---

## Cost Considerations

- Google Drive API is **free** for most use cases
- Quotas:
  - 1 billion queries per day
  - 10,000 requests per 100 seconds per user
- PassVault-It sync uses minimal API calls, well within free tier

---

## Support

If you encounter issues:
1. Check this guide thoroughly
2. Review Google Cloud Console error logs
3. Verify all credentials are correctly configured
4. Ensure app has necessary permissions

---

## License

This implementation follows the app's existing license.
