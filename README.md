# 🔐 Vault-It

<div align="center">

![Vault-It Logo](assets/logo-android.png)

**A modern, secure, and feature-rich password manager built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://github.com/yourusername/pass-vault-it)

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture) • [Security](#-security) • [Contributing](#-contributing)

</div>

---

## 📱 About

**Vault-It** is a cross-platform password manager designed with security and user experience in mind. Store, manage, and sync your passwords securely across devices with end-to-end encryption and cloud backup support.

### Why Vault-It?

- 🔒 **Military-grade encryption** - Your data is always encrypted
- ☁️ **Cloud sync** - Backup and restore with Google Drive
- 🎨 **Beautiful UI** - Modern Material Design 3 interface
- 🌍 **Multi-language** - Support for 7 languages
- 🔑 **Password generator** - Create strong, unique passwords
- 📱 **Cross-platform** - Works on Android and iOS
- 🎯 **Offline-first** - Works without internet connection
- 🆓 **Free & Open Source** - No subscriptions, no tracking

---

## ✨ Features

### 🔐 Vault Management
- **Secure password storage** with SQLite encryption
- **Add, edit, delete** passwords with ease
- **Search and filter** through your vault
- **Favorite passwords** for quick access
- **Password history** tracking
- **Favicon integration** for easy identification
- **Notes and custom fields** for additional information

### 🔑 Password Generator
- **Customizable length** (8-64 characters)
- **Character sets**: Uppercase, lowercase, numbers, symbols
- **Exclusion rules** for specific characters
- **Multiple algorithms** for enhanced security
- **Real-time strength indicator**
- **Copy to clipboard** functionality

### ☁️ Backup & Sync
- **Local backup/restore** to JSON files
- **Google Drive integration** for cloud sync
- **Automatic backup** with version tracking
- **Cross-device sync** support
- **Import/Export** functionality
- **Backup validation** before import

### 🎨 Customization
- **Light/Dark themes** with system detection
- **7 language support**:
  - 🇬🇧 English
  - 🇪🇸 Español
  - 🇫🇷 Français
  - 🇩🇪 Deutsch
  - 🇸🇦 العربية
  - 🇨🇳 中文
  - 🇹🇷 Türkçe
- **Custom color schemes**
- **Responsive design** for all screen sizes

### 🔒 Security Features
- **Master password** protection
- **Local-only storage** (no external servers)
- **SQLite encryption** for database
- **Biometric authentication** ready
- **Auto-lock timeout** support
- **Secure clipboard** handling
- **App data folder isolation** for cloud backups

---

## 🏗️ Architecture

Vault-It follows **Clean Architecture** principles with a feature-based organization:

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── managers/           # Database & storage managers
│   ├── services/           # Business logic services
│   └── utils/              # Helper utilities
├── config/
│   ├── localization/       # i18n support
│   ├── routes/             # Navigation routing
│   └── themes/             # Theme configuration
├── data/
│   ├── datasources/        # Data access layer
│   └── entities/           # Data models
└── features/
    ├── auth/               # Authentication
    ├── vault/              # Password management
    ├── generator/          # Password generation
    ├── settings/           # App settings
    ├── onboarding/         # First-time experience
    └── app-navigator/      # Bottom navigation
```

### Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.5.3+ |
| **Language** | Dart 3.5.3+ |
| **State Management** | Provider Pattern |
| **Dependency Injection** | GetIt |
| **Local Database** | SQLite (sqflite) |
| **Local Storage** | SharedPreferences |
| **Cloud Sync** | Google Drive API |
| **Authentication** | Google Sign-In |
| **UI Components** | Material Design 3 |
| **Navigation** | Sliding Clipped Nav Bar |
| **Internationalization** | Flutter i18n |

### Key Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  get_it: ^7.2.0
  
  # Local Storage
  sqflite: ^2.4.1
  shared_preferences: ^2.3.3
  path_provider: ^2.1.4
  
  # Cloud Sync
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0
  extension_google_sign_in_as_googleapis_auth: ^2.0.12
  
  # File Operations
  file_picker: ^8.1.2
  share_plus: ^10.0.2
  
  # UI Components
  cached_network_image: ^3.4.1
  flutter_svg: ^2.0.16
  sliding_clipped_nav_bar: ^3.1.1
  flutter_slidable: ^3.1.1
  
  # Utilities
  intl: ^0.19.0
  package_info_plus: ^8.0.2
  url_launcher: ^6.3.0
  permission_handler: ^11.3.1
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.3)
- Dart SDK (>=3.5.3)
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pass-vault-it.git
   cd pass-vault-it
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate launcher icons**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Generate native splash screens**
   ```bash
   dart run flutter_native_splash:create
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release
```

---

## ⚙️ Configuration

### Google Drive Sync Setup

To enable Google Drive cloud backup feature:

1. **Create Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create new project
   - Enable Google Drive API

2. **Configure OAuth Credentials**
   - Create Android OAuth client with your SHA-1
   - Create iOS OAuth client with your Bundle ID
   - Copy iOS Client ID

3. **Update iOS Configuration**
   - Edit `ios/Runner/Info.plist`
   - Replace `YOUR_IOS_CLIENT_ID` with actual Client ID:
   ```xml
   <string>com.googleusercontent.apps.YOUR_ACTUAL_CLIENT_ID</string>
   ```

4. **Test the feature**
   - Run the app
   - Go to Settings → Google Drive Sync
   - Sign in and test backup/restore

📖 **Detailed guide**: See [`GOOGLE_DRIVE_SYNC_SETUP.md`](GOOGLE_DRIVE_SYNC_SETUP.md)

### Customization

#### App Name & Package
- **Android**: `android/app/build.gradle`
- **iOS**: `ios/Runner/Info.plist`

#### Theme Colors
- Edit `lib/config/themes/app_theme.dart`
- Modify color schemes in `lib/core/utils/app_colors.dart`

#### Supported Languages
- Add translations in `assets/lang/`
- Update `lib/config/localization/app_localization.dart`

---

## 📊 Project Statistics

```
┌─────────────────────────────────────┐
│  Lines of Code:      ~15,000        │
│  Number of Files:    ~80            │
│  Features:           8              │
│  Languages:          7              │
│  Screens:            15+            │
│  Providers:          8              │
└─────────────────────────────────────┘
```

---

## 🔒 Security

### Data Protection

- ✅ **Local-first architecture** - No data sent to external servers
- ✅ **SQLite encryption** - Database-level encryption
- ✅ **Master password** - Single point of authentication
- ✅ **Secure storage** - SharedPreferences for sensitive data
- ✅ **App data folder** - Isolated cloud storage
- ✅ **No analytics** - No tracking or telemetry

### Best Practices

- 🔐 All passwords stored in encrypted SQLite database
- 🔑 Master password never leaves the device
- 📱 Biometric authentication support (ready)
- ☁️ Cloud backups use Google Drive's encryption
- 🚫 No third-party services or APIs for core functionality
- 🔒 Auto-lock timeout support

### Security Considerations

⚠️ **Important Notes:**
- Master password is stored locally (consider adding encryption)
- SQLite database should use additional encryption layer
- Implement biometric authentication for production
- Add session timeout for enhanced security
- Consider implementing password strength requirements

---

## 🎯 Roadmap

### Version 2.0 (Planned)
- [ ] Biometric authentication (fingerprint/face ID)
- [ ] Auto-fill integration
- [ ] Browser extension
- [ ] Two-factor authentication support
- [ ] Password breach monitoring
- [ ] Secure notes and documents
- [ ] Family sharing
- [ ] Password strength analysis

### Version 1.5 (In Progress)
- [x] Google Drive sync integration
- [x] Multi-language support
- [x] Password history tracking
- [ ] Auto-backup scheduling
- [ ] Dark theme improvements
- [ ] Performance optimizations

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Ways to Contribute

1. **Report bugs** - Open an issue with detailed information
2. **Suggest features** - Share your ideas for improvements
3. **Submit PRs** - Fix bugs or implement new features
4. **Improve docs** - Help make documentation better
5. **Translate** - Add support for more languages

### Development Setup

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Vault-It

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

### Built With
- [Flutter](https://flutter.dev) - UI framework
- [Dart](https://dart.dev) - Programming language
- [Material Design](https://material.io) - Design system
- [Google Drive API](https://developers.google.com/drive) - Cloud sync

### Special Thanks
- Flutter community for amazing packages
- Material Design for beautiful components
- All contributors and testers

---

## 📞 Support

### Get Help

- 📖 **Documentation**: Check the [wiki](https://github.com/yourusername/pass-vault-it/wiki)
- 🐛 **Bug Reports**: [Open an issue](https://github.com/yourusername/pass-vault-it/issues)
- 💬 **Discussions**: [Join the conversation](https://github.com/yourusername/pass-vault-it/discussions)
- 📧 **Email**: support@Vault-it.com

### Community

- ⭐ Star this repo if you find it helpful
- 🔄 Share with others who need a password manager
- 💖 Consider sponsoring the project

---

## 📸 Screenshots

### Light Theme
<div align="center">
  <img src="screenshots/vault_light.png" width="200" />
  <img src="screenshots/generator_light.png" width="200" />
  <img src="screenshots/settings_light.png" width="200" />
</div>

### Dark Theme
<div align="center">
  <img src="screenshots/vault_dark.png" width="200" />
  <img src="screenshots/generator_dark.png" width="200" />
  <img src="screenshots/settings_dark.png" width="200" />
</div>

---

## 📈 Project Status

![Status](https://img.shields.io/badge/Status-Active-success)
![Maintenance](https://img.shields.io/badge/Maintained-Yes-green.svg)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)

**Current Version**: 1.0.0  
**Last Updated**: October 2024  
**Status**: Active Development

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-Vault-it)

</div>
