import 'package:flutter/material.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/localization/language_provider.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/config/themes/theme_provider.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/auth/presentation/providers/auth_provider.dart';
import 'package:vault_it/features/settings/data/providers/local_backup_provider.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  late LocalBackupProvider _backupProvider;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _backupProvider = LocalBackupProvider();
  }

  @override
  void dispose() {
    _backupProvider.dispose();
    super.dispose();
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
                        onTap: () => _showThemeDialog(themeProvider),
                      );
                    },
                  ),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return _buildSettingsTile(
                        icon: Icons.language,
                        title: AppStrings.language.tr,
                        subtitle: languageProvider.currentLanguageName,
                        onTap: () => _showLanguageDialog(languageProvider),
                      );
                    },
                  ),
                  _buildSectionHeader(AppStrings.dataManagement.tr),
                  _buildSettingsTile(
                    icon: Icons.label_outline_rounded,
                    title: AppStrings.categories.tr,
                    subtitle: AppStrings.categoriesSubtitle.tr,
                    onTap: () => Navigator.pushNamed(context, Routes.categories),
                  ),
                  _buildSettingsTile(
                    icon: Icons.backup_outlined,
                    title: AppStrings.exportData.tr,
                    subtitle: AppStrings.exportDataSubtitle.tr,
                    onTap: _exportData,
                  ),
                  _buildSettingsTile(
                    icon: Icons.restore_outlined,
                    title: AppStrings.importData.tr,
                    subtitle: AppStrings.importDataSubtitle.tr,
                    onTap: _importData,
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

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.themeDialogTitle.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              themeProvider,
              ThemeMode.system,
              AppStrings.themeSystemTitle.tr,
              AppStrings.themeSystemDescription.tr,
              Icons.brightness_auto,
            ),
            _buildThemeOption(
              themeProvider,
              ThemeMode.light,
              AppStrings.themeLightTitle.tr,
              AppStrings.themeLightDescription.tr,
              Icons.brightness_7,
            ),
            _buildThemeOption(
              themeProvider,
              ThemeMode.dark,
              AppStrings.themeDarkTitle.tr,
              AppStrings.themeDarkDescription.tr,
              Icons.brightness_2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeProvider provider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      value: mode,
      groupValue: provider.themeMode,
      onChanged: (value) {
        if (value != null) {
          provider.setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLanguageDialog(LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.language.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: languageProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: languageProvider.availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = languageProvider.availableLanguages[index];
                    return RadioListTile<String>(
                      title: Text(language.name),
                      value: language.code,
                      groupValue: languageProvider.currentLanguageCode,
                      onChanged: (value) {
                        if (value != null) {
                          languageProvider.changeLanguage(value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    if (!mounted) return;

    try {
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      final accounts = accountProvider.accounts;

      if (accounts.isEmpty) {
        SnackBarHelper.showWarning(context, AppStrings.noAccountsToExport.tr);
        return;
      }

      final choice = await _showExportOptionsDialog();
      if (choice == null) return;

      BackupResult result;
      if (choice == 'file') {
        result = await _backupProvider.exportToFile(accounts);
        if (result.success) {
          if (mounted) {
            SnackBarHelper.showSuccess(
              context,
              AppStrings.exportSuccessMessage.tr
                  .replaceAll('{count}', '${accounts.length}'),
            );
          }
        } else {
          if (mounted) {
            SnackBarHelper.showError(
              context,
              result.message ?? AppStrings.exportFailed.tr,
            );
          }
        }
      } else if (choice == 'share') {
        result = await _backupProvider.shareBackup(accounts);
        if (result.success) {
          if (mounted) {
            SnackBarHelper.showSuccess(
                context, result.message ?? AppStrings.backupSharedSuccessfully.tr);
          }
        } else {
          if (mounted) {
            SnackBarHelper.showError(
              context,
              result.message ?? AppStrings.exportFailed.tr,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppStrings.exportFailed.tr}: $e');
      }
    }
  }

  Future<void> _importData() async {
    try {
      final choice = await _showImportOptionsDialog();
      if (choice == null) return;

      if (choice == 'validate') {
        await _validateBackupFile();
        return;
      }

      final result = await _backupProvider.importFromFile();

      if (!result.success) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            result.error ?? AppStrings.importFailed.tr,
          );
        }
        return;
      }

      if (result.accounts == null || result.accounts!.isEmpty) {
        if (mounted) {
          SnackBarHelper.showWarning(
              context, 'No accounts found in backup file');
        }
        return;
      }

      if (!mounted) return;
      final confirmed = await _showImportConfirmationDialog(result);
      if (!confirmed || !mounted) return;

      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      int imported = 0;
      int skipped = 0;

      for (final account in result.accounts!) {
        final existingAccounts =
            accountProvider.accounts.where((a) => a.id == account.id);
        if (existingAccounts.isEmpty) {
          await accountProvider.addAccount(account);
          imported++;
        } else {
          skipped++;
        }
      }

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          AppStrings.importComplete.tr
              .replaceAll('{imported}', '$imported')
              .replaceAll('{skipped}', '$skipped'),
        );
      }

      await accountProvider.loadAccounts();
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppStrings.importFailed.tr}: $e');
      }
    }
  }

  Future<void> _validateBackupFile() async {
    try {
      final result = await _backupProvider.validateBackupFile();

      if (mounted) {
        if (result.success && result.backupInfo != null) {
          _showValidationResultDialog(result);
        } else {
          SnackBarHelper.showError(
            context,
            result.error ?? AppStrings.invalidBackupFile.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Validation failed: $e');
      }
    }
  }

  Future<String?> _showExportOptionsDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.backup_outlined,
                  color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.exportOptions.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context, 'file'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.save_outlined,
                          color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.saveToFile.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.saveToFileDescription.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.pop(context, 'share'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.share_outlined,
                          color: AppColors.info, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.shareBackup.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.shareViaEmail.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              AppStrings.cancel.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showImportOptionsDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.restore_outlined, color: AppColors.info, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.importOptions.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context, 'import'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_open_outlined,
                          color: AppColors.info, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.importFromFile.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.importFileDescription.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.pop(context, 'validate'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_outlined,
                          color: Colors.purple, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.validateFile.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.validateFileDesc.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              AppStrings.cancel.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showImportConfirmationDialog(ImportResult result) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cloud_download_outlined,
                      color: AppColors.info, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.confirmImportTitle.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_outlined,
                          color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.foundAccountsInBackup.tr.replaceAll(
                            '{count}',
                            '${result.accounts!.length}',
                          ),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.info,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.backupInfo != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.backupInformation.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      AppStrings.backupAppName.tr, result.backupInfo!.appName),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      AppStrings.backupVersion.tr, result.backupInfo!.version),
                  const SizedBox(height: 8),
                  _buildInfoRow(AppStrings.backupDate.tr,
                      result.backupInfo!.formattedExportDate),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.duplicateWarning.tr,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    height: 1.4,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  AppStrings.cancel.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.importButton.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
        ),
      ],
    );
  }

  void _showValidationResultDialog(ImportResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.validBackupFile.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.backupValidationSuccess.tr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (result.backupInfo != null) ...[
              const SizedBox(height: 20),
              Text(
                AppStrings.backupDetails.tr,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                  AppStrings.backupAppName.tr, result.backupInfo!.appName),
              const SizedBox(height: 8),
              _buildInfoRow(
                  AppStrings.backupVersion.tr, result.backupInfo!.version),
              const SizedBox(height: 8),
              _buildInfoRow(AppStrings.backupAccountCount.tr,
                  '${result.backupInfo!.accountCount}'),
              const SizedBox(height: 8),
              _buildInfoRow(AppStrings.backupDate.tr,
                  result.backupInfo!.formattedExportDate),
              const SizedBox(height: 8),
              _buildInfoRow(
                  AppStrings.backupAge.tr, result.backupInfo!.timeSinceExport),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppStrings.close.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
