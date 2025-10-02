import 'package:flutter/material.dart';
import 'package:pass_vault_it/config/localization/app_localization.dart';
import 'package:pass_vault_it/config/themes/theme_provider.dart';
import 'package:pass_vault_it/core/utils/app_strings.dart';
import 'package:pass_vault_it/features/app-navigator/presentation/providers/navigation_provider.dart';
import 'package:pass_vault_it/features/generator/presentation/screens/generator_screen.dart';
import 'package:pass_vault_it/features/settings/presentation/screens/settings_screen.dart';
import 'package:pass_vault_it/features/vault/presentation/screens/vault_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class AppNavigatorScreen extends StatefulWidget {
  const AppNavigatorScreen({super.key});

  @override
  State<AppNavigatorScreen> createState() => _AppNavigatorScreenState();
}

class _AppNavigatorScreenState extends State<AppNavigatorScreen> {

  final List<Widget> _screens = [
    const VaultScreen(),
    const GeneratorScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, ThemeProvider>(
      builder: (context, navigationProvider, themeProvider, child) {
        return Scaffold(
          body: PageView(
            controller: navigationProvider.pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: navigationProvider.onPageChanged,
            children: _screens,
          ),
          bottomNavigationBar: SlidingClippedNavBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onButtonPressed: navigationProvider.setSelectedIndex,
            iconSize: 30,
            activeColor: Theme.of(context).colorScheme.primary,
            selectedIndex: navigationProvider.selectedIndex,
            barItems: [
              BarItem(
                icon: Icons.lock,
                title: AppStrings.vault.tr,
              ),
              BarItem(
                icon: Icons.vpn_key,
                title: AppStrings.generator.tr,
              ),
              BarItem(
                icon: Icons.settings,
                title: AppStrings.settings.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}
