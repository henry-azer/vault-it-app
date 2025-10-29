import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/settings/data/providers/local_backup_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/account_provider.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';
import 'package:vault_it/data/datasources/account_local_datasource.dart';
import 'package:vault_it/data/datasources/category_local_datasource.dart';

class BackupImportScreen extends StatefulWidget {
  const BackupImportScreen({super.key});

  @override
  State<BackupImportScreen> createState() => _BackupImportScreenState();
}

class _BackupImportScreenState extends State<BackupImportScreen> {
  late LocalBackupProvider _backupProvider;
  bool _isValidating = false;
  bool _isImporting = false;

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

  Future<void> _validateFile() async {
    if (_isValidating || _isImporting) return;

    setState(() => _isValidating = true);

    try {
      final result = await _backupProvider.validateBackupFile();

      if (mounted) {
        setState(() => _isValidating = false);

        if (result.success && result.backupInfo != null) {
          _showValidationDialog(result);
        } else {
          SnackBarHelper.showError(
            context,
            result.error ?? AppStrings.invalidBackupFile.tr,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isValidating = false);
        SnackBarHelper.showError(context, 'Validation failed: $e');
      }
    }
  }

  Future<void> _importBackup() async {
    if (_isImporting) return;

    setState(() => _isImporting = true);

    try {
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
          SnackBarHelper.showWarning(context, 'No accounts found in backup file');
        }
        return;
      }

      if (!mounted) return;

      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      // Get datasources directly to preserve sortOrder
      final accountDataSource = GetIt.instance<AccountLocalDataSource>();
      final categoryDataSource = GetIt.instance<CategoryLocalDataSource>();

      int accountsImported = 0;
      int accountsSkipped = 0;
      int categoriesImported = 0;
      int categoriesSkipped = 0;

      // Import categories first (if present) - directly to database to preserve sortOrder
      if (result.categories != null && result.categories!.isNotEmpty) {
        for (final category in result.categories!) {
          final exists = categoryProvider.categories.any((c) => c.id == category.id);
          if (!exists) {
            await categoryDataSource.addCategory(category);
            categoriesImported++;
          } else {
            categoriesSkipped++;
          }
        }
      }

      // Import accounts with their sortOrder preserved - directly to database
      for (final account in result.accounts!) {
        final existingAccounts = accountProvider.accounts.where((a) => a.id == account.id);
        if (existingAccounts.isEmpty) {
          await accountDataSource.addAccount(account);

          // Link categories after account is created
          final categoryIds = result.accountCategoryLinks?[account.id] ?? [];
          if (categoryIds.isNotEmpty) {
            await categoryDataSource.updateAccountCategories(account.id, categoryIds);
          }

          accountsImported++;
        } else {
          accountsSkipped++;
        }
      }

      if (mounted) {
        final message = categoriesImported > 0 || categoriesSkipped > 0
            ? '${AppStrings.importComplete.tr.replaceAll('{imported}', '$accountsImported').replaceAll('{skipped}', '$accountsSkipped')}\n'
                'Categories: $categoriesImported imported, $categoriesSkipped skipped'
            : AppStrings.importComplete.tr
                .replaceAll('{imported}', '$accountsImported')
                .replaceAll('{skipped}', '$accountsSkipped');

        SnackBarHelper.showSuccess(context, message);

        // Reload providers
        await accountProvider.loadAccounts();
        await categoryProvider.loadCategories();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '${AppStrings.importFailed.tr}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
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
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImportOptions(isDark),
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
                      Icons.restore_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.importData.tr,
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

  Widget _buildImportOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildImportOption(
          isDark: isDark,
          icon: Icons.cloud_download_outlined,
          title: AppStrings.importFromFile.tr,
          description: AppStrings.importFileDescription.tr,
          color: AppColors.success,
          onTap: _importBackup,
          isLoading: _isImporting,
        ),
        const SizedBox(height: 12),
        _buildImportOption(
          isDark: isDark,
          icon: Icons.search,
          title: AppStrings.validateFile.tr,
          description: AppStrings.validateFileDesc.tr,
          color: AppColors.info,
          onTap: _validateFile,
          isLoading: _isValidating,
        ),
      ],
    );
  }

  Widget _buildImportOption({
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
        onTap: isLoading || _isImporting || _isValidating ? null : onTap,
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

  void _showValidationDialog(ImportResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backupInfo = result.backupInfo!;

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
              child: Icon(Icons.check_circle_outline, color: AppColors.success, size: 24),
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
        content: SingleChildScrollView(
          child: Column(
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, color: AppColors.info, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${AppStrings.accounts.tr}: ${backupInfo.accountCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (backupInfo.categoryCount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.label_outline, color: AppColors.info, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${AppStrings.categories.tr}: ${backupInfo.categoryCount}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(AppStrings.backupAppName.tr, backupInfo.appName, isDark),
              const SizedBox(height: 8),
              _buildInfoRow(AppStrings.backupVersion.tr, backupInfo.version, isDark),
              const SizedBox(height: 8),
              _buildInfoRow(AppStrings.backupDate.tr, backupInfo.formattedExportDate, isDark),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                AppStrings.close.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
