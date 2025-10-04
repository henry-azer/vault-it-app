# Google Drive Sync - Quick Start

## For Users

### How to Enable Google Drive Sync

1. Open PassVault-It app
2. Go to **Settings** tab
3. Scroll to **Data Management** section
4. Find **Google Drive Sync** card
5. Tap **Sign in to enable cloud backup**
6. Sign in with your Google account
7. Grant Drive permission

### How to Backup

1. After signing in, tap **Backup** button
2. Your vault is uploaded to Google Drive
3. Success message confirms backup

### How to Restore

1. Tap **Restore** button
2. Confirm restoration (replaces current data)
3. Your vault is downloaded and restored

---

## For Developers

### Quick Setup (5 minutes)

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Create Google Cloud Project:**
   - Go to [console.cloud.google.com](https://console.cloud.google.com)
   - Create new project
   - Enable Google Drive API

3. **Configure OAuth:**
   - Create Android OAuth client
   - Create iOS OAuth client
   - Copy iOS Client ID

4. **Update iOS config:**
   - Edit `ios/Runner/Info.plist`
   - Replace `YOUR_IOS_CLIENT_ID` with actual Client ID

5. **Test:**
   ```bash
   flutter run
   ```

**Full setup guide:** See `GOOGLE_DRIVE_SYNC_SETUP.md`

---

## Architecture

```
User Interface (Settings Screen)
        ↓
Google Drive Sync Provider (State Management)
        ↓
Google Drive Sync Service (Business Logic)
        ↓
Google APIs (Drive + Sign-In)
```

---

## Security

- ✅ App data folder (isolated storage)
- ✅ Minimal permissions (appdata scope only)
- ✅ Encrypted in transit and at rest
- ✅ User-controlled manual sync

---

## Support

**Issues?** Check `GOOGLE_DRIVE_SYNC_SETUP.md` troubleshooting section.
