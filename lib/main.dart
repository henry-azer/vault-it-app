import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:pass_vault_it/app.dart';
import 'injection_container.dart' as di;
import 'core/utils/localization_helper.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/vault/presentation/providers/password_provider.dart';
import 'features/generator/presentation/providers/generator_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/providers/language_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/app-navigator/presentation/providers/navigation_provider.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await di.init();
  
  // Initialize localization with default language
  try {
    await LocalizationHelper.initialize();
  } catch (e) {
    debugPrint('Warning: Localization initialization failed: $e');
    // Continue without localization if it fails
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => GeneratorProvider()),
      ],
      builder: (context, child) {
        _removeSplash();
        return Consumer2<ThemeProvider, LanguageProvider>(
          builder: (context, themeProvider, languageProvider, child) {
            return PassVaultItApp(
              themeMode: themeProvider.themeMode,
              locale: languageProvider.currentLocale,
            );
          },
        );
      },
    );
  }

  void _removeSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }
}
