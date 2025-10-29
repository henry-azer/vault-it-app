import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/settings/data/providers/local_backup_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';

class BackupExportScreen extends StatefulWidget {
  const BackupExportScreen({super.key});

  @override
  State<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends State<BackupExportScreen> {
  late LocalBackupProvider _backupProvider;
  bool _isSaving = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _backupProvider = LocalBackupProvider();
  }

  @override
  void dispose() {
    _backupProvider.dispose();
    super.dispose();
  }

  Future<void> _exportToFile() async {
    if (_isSaving || _isSharing) return;

    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    final accounts = accountProvider.accounts;
    final categories = categoryProvider.categories;

    if (accounts.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.noAccountsToExport.tr);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build account-category links map
      final Map<String, List<String>> accountCategoryLinks = {};
      for (final account in accounts) {
        final categoryList = accountProvider.getCategoriesForAccount(account.id);
        if (categoryList.isNotEmpty) {
          accountCategoryLinks[account.id] = categoryList.map((c) => c.id).toList();
        }
      }

      final result = await _backupProvider.exportToFile(
        accounts,
        categories,
        accountCategoryLinks,
      );

      if (mounted) {
        if (result.success) {
          SnackBarHelper.showSuccess(
            context,
            AppStrings.exportSuccessMessage.tr.replaceAll('{count}', '${accounts.length}'),
          );
        } else {
          SnackBarHelper.showError(
            context,
            result.message ?? AppStrings.exportFailed.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppStrings.exportFailed.tr}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareBackup() async {
    if (_isSaving || _isSharing) return;

    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    final accounts = accountProvider.accounts;
    final categories = categoryProvider.categories;

    if (accounts.isEmpty) {
      SnackBarHelper.showWarning(context, AppStrings.noAccountsToExport.tr);
      return;
    }

    setState(() => _isSharing = true);

    try {
      // Build account-category links map
      final Map<String, List<String>> accountCategoryLinks = {};
      for (final account in accounts) {
        final categoryList = accountProvider.getCategoriesForAccount(account.id);
        if (categoryList.isNotEmpty) {
          accountCategoryLinks[account.id] = categoryList.map((c) => c.id).toList();
        }
      }

      final result = await _backupProvider.shareBackup(
        accounts,
        categories,
        accountCategoryLinks,
      );

      if (mounted) {
        if (result.success) {
          SnackBarHelper.showSuccess(
            context,
            result.message ?? AppStrings.backupSharedSuccessfully.tr,
          );
        } else {
          SnackBarHelper.showError(
            context,
            result.message ?? AppStrings.exportFailed.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppStrings.exportFailed.tr}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountProvider = Provider.of<AccountProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatisticsCard(isDark, accountProvider, categoryProvider),
                  const SizedBox(height: 16),
                  _buildExportOptions(isDark),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCardBackground
                      : AppColors.lightCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Row(
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
                    child: const Icon(
                      Icons.backup_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.exportData.tr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(
    bool isDark,
    AccountProvider accountProvider,
    CategoryProvider categoryProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics_outlined, color: AppColors.info, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.vaultStatistics.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  isDark,
                  Icons.folder_outlined,
                  AppStrings.accounts.tr,
                  '${accountProvider.accountCount}',
                  isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  isDark,
                  Icons.label_outline,
                  AppStrings.categories.tr,
                  '${categoryProvider.categoryCount}',
                  isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    bool isDark,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExportOption(
          isDark: isDark,
          icon: Icons.save_outlined,
          title: AppStrings.saveToFile.tr,
          description: AppStrings.saveToFileDescription.tr,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          onTap: _exportToFile,
          isLoading: _isSaving,
        ),
        const SizedBox(height: 12),
        _buildExportOption(
          isDark: isDark,
          icon: Icons.share_outlined,
          title: AppStrings.shareBackup.tr,
          description: AppStrings.shareBackupDescription.tr,
          color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
          onTap: _shareBackup,
          isLoading: _isSharing,
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
