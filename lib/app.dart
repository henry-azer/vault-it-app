import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/localization_helper.dart';
import 'features/settings/presentation/providers/language_provider.dart';

class PassVaultItApp extends StatelessWidget {
  final ThemeMode? themeMode;
  final Locale? locale;
  const PassVaultItApp({Key? key, this.themeMode, this.locale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'app_name'.tr,
          locale: locale ?? languageProvider.currentLocale,
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          darkTheme: appDarkTheme(),
          themeMode: themeMode ?? ThemeMode.system,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            // If the locale is not supported, return the first one (English)
            return supportedLocales.first;
          },
        );
      },
    );
  }
}
