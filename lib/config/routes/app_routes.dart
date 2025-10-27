import 'package:flutter/material.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/data/entities/account.dart';
import 'package:vault_it/features/app-navigator/presentation/screens/app_navigator_screen.dart';
import 'package:vault_it/features/auth/presentation/screens/login_screen.dart';
import 'package:vault_it/features/auth/presentation/screens/register_screen.dart';
import 'package:vault_it/features/generator/presentation/screens/generator_history_screen.dart';
import 'package:vault_it/features/generator/presentation/screens/generator_screen.dart';
import 'package:vault_it/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/about_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/bug_report_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/help_support_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/rate_app_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/settings_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/user_profile_screen.dart';
import 'package:vault_it/features/splash/presentation/screens/splash_screen.dart';
import 'package:vault_it/features/vault/presentation/screens/account_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/category_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/manage_category_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/theme_screen.dart';
import 'package:vault_it/features/settings/presentation/screens/language_screen.dart';
import 'package:vault_it/features/vault/presentation/screens/vault_screen.dart';
import 'package:vault_it/features/vault/presentation/screens/view_account_screen.dart';
import 'package:vault_it/data/entities/category.dart';

class Routes {
  static const String initial = '/';
  static const String app = '/app';
  static const String onboarding = '/onboarding';

  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static const String vault = '/app/vault';
  static const String account = '/app/vault/account';
  static const String viewAccount = '/app/vault/account/view';

  static const String generator = '/app/generator';
  static const String generatorHistory = '/app/generator/history';

  static const String settings = '/app/settings';
  static const String userProfile = '/app/settings/profile';
  static const String categories = '/app/settings/categories';
  static const String manageCategory = '/app/settings/categories/manage';
  static const String theme = '/app/settings/theme';
  static const String language = '/app/settings/language';
  static const String bugReport = '/app/settings/bug-report';
  static const String helpSupport = '/app/settings/help';
  static const String rateApp = '/app/settings/rate';
  static const String about = '/app/settings/about';
}

class AppRoutes {
  static Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.initial:
        return MaterialPageRoute(
            builder: (context) {
              return const SplashScreen();
            },
            settings: routeSettings);

      case Routes.onboarding:
        return MaterialPageRoute(
            builder: (context) {
              return const OnboardingScreen();
            },
            settings: routeSettings);

      case Routes.login:
        return MaterialPageRoute(
            builder: (context) {
              return const LoginScreen();
            },
            settings: routeSettings);

      case Routes.register:
        return MaterialPageRoute(
            builder: (context) {
              return const RegisterScreen();
            },
            settings: routeSettings);

      case Routes.app:
        return MaterialPageRoute(
            builder: (context) {
              return const AppNavigatorScreen();
            },
            settings: routeSettings);

      case Routes.vault:
        return MaterialPageRoute(
            builder: (context) {
              return const VaultScreen();
            },
            settings: routeSettings);

      case Routes.account:
        final account = routeSettings.arguments as Account?;
        return MaterialPageRoute(
            builder: (context) {
              return AccountScreen(accountToEdit: account);
            },
            settings: routeSettings);

      case Routes.viewAccount:
        final account = routeSettings.arguments as Account;
        return MaterialPageRoute(
            builder: (context) {
              return ViewAccountScreen(account: account);
            },
            settings: routeSettings);

      case Routes.categories:
        return MaterialPageRoute(
            builder: (context) {
              return const CategoryScreen();
            },
            settings: routeSettings);

      case Routes.manageCategory:
        final category = routeSettings.arguments as Category?;
        return MaterialPageRoute(
            builder: (context) {
              return ManageCategoryScreen(categoryToEdit: category);
            },
            settings: routeSettings);

      case Routes.theme:
        return MaterialPageRoute(
            builder: (context) {
              return const ThemeScreen();
            },
            settings: routeSettings);

      case Routes.language:
        return MaterialPageRoute(
            builder: (context) {
              return const LanguageScreen();
            },
            settings: routeSettings);

      case Routes.generator:
        return MaterialPageRoute(
            builder: (context) {
              return const GeneratorScreen();
            },
            settings: routeSettings);

      case Routes.generatorHistory:
        return MaterialPageRoute(
            builder: (context) {
              return const GeneratorHistoryScreen();
            },
            settings: routeSettings);

      case Routes.settings:
        return MaterialPageRoute(
            builder: (context) {
              return const SettingsScreen();
            },
            settings: routeSettings);

      case Routes.userProfile:
        return MaterialPageRoute(
            builder: (context) {
              return const UserProfileScreen();
            },
            settings: routeSettings);

      case Routes.helpSupport:
        return MaterialPageRoute(
            builder: (context) {
              return const HelpSupportScreen();
            },
            settings: routeSettings);

      case Routes.bugReport:
        return MaterialPageRoute(
            builder: (context) {
              return const BugReportScreen();
            },
            settings: routeSettings);

      case Routes.rateApp:
        return MaterialPageRoute(
            builder: (context) {
              return const RateAppScreen();
            },
            settings: routeSettings);

      case Routes.about:
        return MaterialPageRoute(
            builder: (context) {
              return const AboutScreen();
            },
            settings: routeSettings);

      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
        builder: ((context) => const Scaffold(
              body: Center(
                child: Text(AppStrings.noRouteFound),
              ),
            )));
  }
}
