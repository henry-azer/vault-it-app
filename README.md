# 🔐 Vault-It

<div align="center">

<img src="assets/images/light_logo.png" width="200" height="100" alt="Vault-It Logo">

**A modern, secure, and feature-rich password manager built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://github.com/yourusername/pass-vault-it)

[Features](#-features) • [Installation](#-installation) • [Architecture](#-architecture) • [Security](#-security) • [Contributing](#-contributing)

</div>

---

## 📱 About

**Vault-It** is a cross-platform password manager designed with security and user experience in mind. Store, manage, and backup your passwords securely.

### Why Vault-It?

- 🔒 **Military-grade encryption** - Your data is always encrypted
- 🎨 **Beautiful UI** - Modern Material Design 3 interface
- 🌍 **Multi-language** - Support multi languages localization
- 🔑 **Password generator** - Create strong, unique passwords
- 📱 **Cross-platform** - Works on Android and iOS
- 🎯 **Offline-first** - Works without internet connection
- 🆓 **Free & Open Source** - No subscriptions, no tracking

---

## 📸 Screenshots

### Light Theme
<div align="start">
  <img src="screenshots/light/1.png" width="200" />
  <img src="screenshots/light/2.png" width="200" />
  <img src="screenshots/light/3.png" width="200" />
  <img src="screenshots/light/4.png" width="200" />
  <img src="screenshots/light/5.png" width="200" />
  <img src="screenshots/light/6.png" width="200" />
  <img src="screenshots/light/7.png" width="200" />
  <img src="screenshots/light/8.png" width="200" />
  <img src="screenshots/light/9.png" width="200" />
  <img src="screenshots/light/10.png" width="200" />
  <img src="screenshots/light/11.png" width="200" />
  <img src="screenshots/light/12.png" width="200" />
  <img src="screenshots/light/13.png" width="200" />
  <img src="screenshots/light/14.png" width="200" />
  <img src="screenshots/light/15.png" width="200" />
  <img src="screenshots/light/16.png" width="200" />
  <img src="screenshots/light/17.png" width="200" />
  <img src="screenshots/light/18.png" width="200" />
</div>

### Dark Theme
<div align="start">
  <img src="screenshots/dark/1.png" width="200" />
  <img src="screenshots/dark/2.png" width="200" />
  <img src="screenshots/dark/3.png" width="200" />
  <img src="screenshots/dark/4.png" width="200" />
  <img src="screenshots/dark/5.png" width="200" />
  <img src="screenshots/dark/6.png" width="200" />
  <img src="screenshots/dark/7.png" width="200" />
  <img src="screenshots/dark/8.png" width="200" />
  <img src="screenshots/dark/9.png" width="200" />
  <img src="screenshots/dark/10.png" width="200" />
  <img src="screenshots/dark/11.png" width="200" />
  <img src="screenshots/dark/12.png" width="200" />
  <img src="screenshots/dark/13.png" width="200" />
  <img src="screenshots/dark/14.png" width="200" />
  <img src="screenshots/dark/15.png" width="200" />
  <img src="screenshots/dark/16.png" width="200" />
  <img src="screenshots/dark/17.png" width="200" />
  <img src="screenshots/dark/18.png" width="200" />
</div>

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
- **Import/Export** functionality
- **Backup validation** before import

### 🎨 Customization
- **Light/Dark themes** with system detection
- **2 language support**:
  - 🇬🇧 English
  - 🇸🇦 العربية

- **Custom color schemes**
- **Responsive design** for all screen sizes

### 🔒 Security Features
- **Master password** protection
- **Local-only storage** (no external servers)
- **SQLite encryption** for database
- **Secure clipboard** handling

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
| **Framework** | Flutter 3.27.0 |
| **Language** | Dart 3.5.3+ |
| **State Management** | Provider Pattern |
| **Dependency Injection** | GetIt |
| **Local Database** | SQLite (sqflite) |
| **Local Storage** | SharedPreferences |
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

- Flutter SDK 3.27.0 (or use `.flutter-version` file)
- Dart SDK (>=3.5.3)
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/henry-azer/vault-it-app.git
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
- ✅ **No analytics** - No tracking or telemetry

### Best Practices

- 🔐 All passwords stored in encrypted SQLite database
- 🔑 Master password never leaves the device
- 🚫 No third-party services or APIs for core functionality

---

## 🎯 Roadmap

### Version 2.0 (Planned)
- [ ] Google Drive sync integration

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
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing-feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
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

Copyright (c) 2025 Vault-It

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

### Special Thanks
- Flutter community for amazing packages
- Material Design for beautiful components
- All contributors and testers

---

## 📞 Support

### Get Help

- 🐛 **Bug Reports**: [Open an issue](https://github.com/henry-azer/vault-it-app/issues)
- 📧 **Email**: henryazer@outlook.com

### Community

- ⭐ Star this repo if you find it helpful
- 🔄 Share with others who need a password manager
- 💖 Consider sponsoring the project

---

## 📈 Project Status

![Status](https://img.shields.io/badge/Status-Inactive-red.svg)
![Maintenance](https://img.shields.io/badge/Maintained-No-red.svg)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)

**Current Version**: 1.0.0
**Last Updated**: October 2025  

---
<div align="center">

**Made with ❤️ By Henry Azer**

[⬆ Back to Top ⬆](#-Vault-it)

</div>
