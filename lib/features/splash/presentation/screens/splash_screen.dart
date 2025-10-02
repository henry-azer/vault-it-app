import 'package:flutter/material.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/routes/app_routes.dart';
import 'package:pass_vault_it/config/themes/theme_provider.dart';
import 'package:pass_vault_it/core/utils/app_assets_manager.dart';
import 'package:pass_vault_it/core/utils/app_media_query_values.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isUserOnboarded = await authProvider.isUserOnboarded();
    final isUserCreated = await authProvider.isUserCreated();

    if (!isUserOnboarded) {
      Navigator.pushReplacementNamed(context, Routes.onboarding);
    } else {
      if (!isUserCreated) {
        Navigator.pushReplacementNamed(context, Routes.register);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<ThemeProvider>(builder: (context, theme, child) {
                return Image.asset(
                  theme.isDarkMode
                      ? AppImageAssets.darkLogo
                      : AppImageAssets.lightLogo,
                  height: 220,
                  width: 350,
                );
              }),
              SizedBox(
                height: context.height * 0.01,
              ),
              Text(
                AppStrings.appName.tr.toUpperCase(),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: context.height * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
