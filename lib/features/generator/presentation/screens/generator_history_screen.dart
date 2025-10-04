import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/features/generator/presentation/providers/generator_provider.dart';
import 'package:provider/provider.dart';

class GeneratorHistoryScreen extends StatelessWidget {
  const GeneratorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, screenWidth),
            Expanded(
              child: _buildContent(context, isDark, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double screenWidth) {
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
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
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
                  color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8,),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warning,
                          AppColors.warning.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.passwordHistory.tr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _buildHeaderActions(context, isDark, screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(
      BuildContext context, bool isDark, double screenWidth) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        if (!provider.hasHistory) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.delete_sweep_rounded,
                size: 20, color: AppColors.error),
            onPressed: () => _showClearHistoryDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, double screenWidth) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        if (!provider.hasHistory) {
          return _buildEmptyState(context, isDark, screenWidth);
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
          physics: const BouncingScrollPhysics(),
          itemCount: provider.passwordHistory.length,
          itemBuilder: (context, index) {
            final historyItem = provider.passwordHistory[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 30)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildHistoryCard(
                        context, historyItem, provider, isDark, screenWidth),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
            ),
            child: Icon(
              Icons.history_outlined,
              size: 70,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: screenWidth * 0.06),
          Text(
            AppStrings.noPasswordHistory.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            AppStrings.generatedPasswordsWillAppear.tr,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: screenWidth * 0.04,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.2),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    PasswordHistoryItem historyItem,
    GeneratorProvider provider,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: historyItem.strengthColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(Icons.security_rounded,
                      size: 16, color: historyItem.strengthColor),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        historyItem.formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '${historyItem.length} ${AppStrings.characters.tr} • ${historyItem.strength}',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        size: 15, color: AppColors.success),
                    onPressed: () =>
                        _copyPassword(context, historyItem.password, provider),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 15, color: AppColors.error),
                    onPressed: () => _removeFromHistory(
                        context, historyItem.password, provider),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                historyItem.password,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Wrap(
              spacing: screenWidth * 0.02,
              runSpacing: screenWidth * 0.02,
              children: historyItem.characterTypes.map((type) {
                Color color;
                switch (type) {
                  case 'A-Z':
                    color = AppColors.error;
                    break;
                  case 'a-z':
                    color = AppColors.warning;
                    break;
                  case '0-9':
                    color = AppColors.success;
                    break;
                  case '!@#':
                    color = AppColors.info;
                    break;
                  default:
                    color = Theme.of(context).colorScheme.secondary;
                }

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _copyPassword(
      BuildContext context, String password, GeneratorProvider provider) {
    provider.copyFromHistory(password);
    HapticFeedback.lightImpact();
    SnackBarHelper.showSuccess(
      context,
      AppStrings.passwordCopied.tr,
      duration: const Duration(seconds: 1),
    );
  }

  void _removeFromHistory(
      BuildContext context, String password, GeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(AppStrings.removePassword.tr),
          ],
        ),
        content: Text(
          AppStrings.removePasswordMessage.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeFromHistory(password);
              HapticFeedback.mediumImpact();
              SnackBarHelper.showSuccess(
                context,
                AppStrings.passwordRemoved.tr,
                duration: const Duration(seconds: 1),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              AppStrings.remove.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(
      BuildContext context, GeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[600], size: 28),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(AppStrings.clearAllHistory.tr),
          ],
        ),
        content: Text(
          AppStrings.clearAllHistoryMessage.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearHistory();
              HapticFeedback.mediumImpact();
              SnackBarHelper.showSuccess(
                context,
                AppStrings.historyCleared.tr,
                duration: const Duration(seconds: 1),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              AppStrings.clearAll.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
