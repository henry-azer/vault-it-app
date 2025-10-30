import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/localization/language_provider.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/config/themes/app_theme.dart';
import 'package:vault_it/config/themes/theme_provider.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/features/app-navigator/presentation/providers/navigation_provider.dart';
import 'package:vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:vault_it/features/generator/presentation/providers/generator_provider.dart';
import 'package:vault_it/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:vault_it/features/settings/presentation/providers/biometric_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';
import 'package:vault_it/core/purchase/purchase_provider.dart';
import 'package:provider/provider.dart';

class VaultItApp extends StatelessWidget {
  const VaultItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BiometricProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GeneratorProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
      ],
      builder: (context, child) {
        _removeSplash();
        return Consumer2<ThemeProvider, LanguageProvider>(
          builder: (context, themeProvider, languageProvider, child) {
            return Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return MaterialApp(
                  title: AppStrings.appName.tr,
                  locale: languageProvider.currentLocale,
                  debugShowCheckedModeBanner: false,
                  theme: appTheme(),
                  darkTheme: appDarkTheme(),
                  themeMode: themeProvider.themeMode,
                  onGenerateRoute: AppRoutes.onGenerateRoute,
                  supportedLocales: languageProvider.availableLanguagesLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale?.languageCode) {
                        return supportedLocale;
                      }
                    }
                    return supportedLocales.first;
                  },

                  builder: (context, child) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;

                    final overlayStyle = SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness:
                          isDark ? Brightness.light : Brightness.dark,
                      statusBarBrightness:
                          isDark ? Brightness.light : Brightness.dark,
                      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
                      systemNavigationBarIconBrightness:
                          isDark ? Brightness.light : Brightness.dark,
                      systemNavigationBarDividerColor: Theme.of(context).scaffoldBackgroundColor
                    );

                    return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: overlayStyle,
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _removeSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }
}
