import 'package:flutter/material.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/features/app-navigator/presentation/screens/app_navigator_screen.dart';
import 'package:pass_vault_it/features/auth/presentation/screens/change_password_screen.dart';
import 'package:pass_vault_it/features/auth/presentation/screens/login_screen.dart';
import 'package:pass_vault_it/features/auth/presentation/screens/register_screen.dart';
import 'package:pass_vault_it/features/generator/presentation/screens/generator_screen.dart';
import 'package:pass_vault_it/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pass_vault_it/features/settings/presentation/screens/settings_screen.dart';
import 'package:pass_vault_it/features/splash/presentation/screens/splash_screen.dart';
import 'package:pass_vault_it/features/vault/presentation/screens/add_account_screen.dart';
import 'package:pass_vault_it/features/vault/presentation/screens/vault_screen.dart';

class Routes {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String changePassword = '/auth/change-password';
  
  static const String app = '/app';
  static const String vault = '/app/vault';
  static const String addAccount = '/app/vault/add';
  static const String viewAccount = '/app/vault/view';
  static const String generator = '/app/generator';
  static const String settings = '/app/settings';
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

      case Routes.changePassword:
        return MaterialPageRoute(
            builder: (context) {
              return const ChangePasswordScreen();
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

      case Routes.addAccount:
        return MaterialPageRoute(
            builder: (context) {
              return const AddAccountScreen();
            },
            settings: routeSettings);

      // case Routes.viewPassword:
      //   final password = routeSettings.arguments;
      //   return MaterialPageRoute(
      //       builder: (context) {
      //         return ViewPasswordScreen(password: password);
      //       },
      //       settings: routeSettings);

      case Routes.generator:
        return MaterialPageRoute(
            builder: (context) {
              return const GeneratorScreen();
            },
            settings: routeSettings);

      case Routes.settings:
        return MaterialPageRoute(
            builder: (context) {
              return const SettingsScreen();
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
