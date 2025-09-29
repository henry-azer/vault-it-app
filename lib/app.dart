import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'config/localization/app_localization.dart';
import 'config/localization/language_provider.dart';
import 'config/themes/theme_provider.dart';
import 'features/app-navigator/presentation/providers/navigation_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/generator/presentation/providers/generator_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/vault/presentation/providers/password_provider.dart';

class PassVaultItApp extends StatelessWidget {
  const PassVaultItApp({super.key});

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
    await Future.delayed(const Duration(seconds: 5));
    FlutterNativeSplash.remove();
  }
}
