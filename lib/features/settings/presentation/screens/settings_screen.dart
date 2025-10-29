import 'package:flutter/material.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/localization/language_provider.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/config/themes/theme_provider.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.userProfile);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  child: Icon(Icons.person_outline)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authProvider.currentUser?.username ??
                                          AppStrings.user.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppStrings.member.tr,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.verified_user,
                                color: Colors.white.withOpacity(0.8),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionHeader(AppStrings.appearance.tr),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSettingsTile(
                        icon: Icons.brightness_6,
                        title: AppStrings.theme.tr,
                        subtitle: _getThemeText(themeProvider.themeMode),
                        onTap: () => Navigator.pushNamed(context, Routes.theme),
                      );
                    },
                  ),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return _buildSettingsTile(
                        icon: Icons.language,
                        title: AppStrings.language.tr,
                        subtitle: languageProvider.currentLanguageName,
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.language),
                      );
                    },
                  ),
                  _buildSectionHeader(AppStrings.dataManagement.tr),
                  _buildSettingsTile(
                    icon: Icons.label_outline_rounded,
                    title: AppStrings.categories.tr,
                    subtitle: AppStrings.categoriesSubtitle.tr,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.categories),
                  ),
                  _buildSettingsTile(
                    icon: Icons.backup_outlined,
                    title: AppStrings.exportData.tr,
                    subtitle: AppStrings.exportDataSubtitle.tr,
                    onTap: () => Navigator.pushNamed(context, Routes.backupExport),
                  ),
                  _buildSettingsTile(
                    icon: Icons.restore_outlined,
                    title: AppStrings.importData.tr,
                    subtitle: AppStrings.importDataSubtitle.tr,
                    onTap: () => Navigator.pushNamed(context, Routes.backupImport),
                  ),
                  _buildSectionHeader(AppStrings.supportInformation.tr),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: AppStrings.helpSupport.tr,
                    subtitle: AppStrings.helpSupportDescription.tr,
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.helpSupport),
                  ),
                  _buildSettingsTile(
                    icon: Icons.bug_report,
                    title: AppStrings.bugReport.tr,
                    subtitle: AppStrings.bugReportDescription.tr,
                    onTap: () => Navigator.pushNamed(context, Routes.bugReport),
                  ),
                  _buildSettingsTile(
                    icon: Icons.star_rate,
                    title: AppStrings.rateApp.tr,
                    subtitle: AppStrings.rateAppDescription.tr,
                    onTap: () => Navigator.pushNamed(context, Routes.rateApp),
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: AppStrings.about.tr,
                    subtitle:
                        '${AppStrings.aboutSubtitle.tr} ${_packageInfo?.version ?? '1.0.0'}',
                    onTap: () => Navigator.pushNamed(context, Routes.about),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkHeaderStart, AppColors.darkHeaderEnd]
              : [AppColors.lightHeaderStart, AppColors.lightHeaderEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.settings.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isDark) {
    return _buildActionButton(
      icon: Icons.add_shopping_cart_outlined,
      onPressed: () {},
      isDark: isDark,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ??
              (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardBorder
              : AppColors.lightCardBorder,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).primaryColor
                : null,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextDisabled
                  : AppColors.lightTextDisabled,
              size: 20,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return AppStrings.themeSystem.tr;
      case ThemeMode.light:
        return AppStrings.themeLight.tr;
      case ThemeMode.dark:
        return AppStrings.themeDark.tr;
    }
  }
}
