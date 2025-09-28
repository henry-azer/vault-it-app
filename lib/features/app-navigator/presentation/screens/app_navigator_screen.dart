import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import '../providers/navigation_provider.dart';
import '../../../vault/presentation/screens/vault_screen.dart';
import '../../../generator/presentation/screens/generator_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class AppNavigatorScreen extends StatefulWidget {
  const AppNavigatorScreen({Key? key}) : super(key: key);

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
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: PageView(
            controller: navigationProvider.pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: navigationProvider.onPageChanged,
            children: _screens,
          ),
          bottomNavigationBar: SlidingClippedNavBar(
            backgroundColor: Colors.white,
            onButtonPressed: navigationProvider.setSelectedIndex,
            iconSize: 30,
            activeColor: const Color(0xFFFF5722),
            selectedIndex: navigationProvider.selectedIndex,
            barItems: [
              BarItem(
                icon: Icons.lock,
                title: 'Vault',
              ),
              BarItem(
                icon: Icons.vpn_key,
                title: 'Generator',
              ),
              BarItem(
                icon: Icons.settings,
                title: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
