import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/core/utils/snackbar_helper.dart';
import 'package:vault_it/data/entities/category.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.categories.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return _buildCategoryList(isDark, provider.categories);
                },
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
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.label_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.categories.tr,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              _buildHeaderActions(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isDark) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.add_rounded,
                size: 20, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _showCreateCategoryDialog(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
            ),
            child: Icon(
              Icons.label_off_rounded,
              size: 70,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: screenWidth * 0.06),
          Text(
            AppStrings.noCategories.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            AppStrings.noCategoriesMessage.tr,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: screenWidth * 0.04,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenWidth * 0.1),
          ElevatedButton.icon(
            onPressed: () => _showCreateCategoryDialog(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              AppStrings.createCategory.tr,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(bool isDark, List<Category> categories) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenWidth * 0.03),
      physics: const BouncingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 30)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child:
                    _buildCategoryCard(context, category, isDark, screenWidth),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    bool isDark,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(Icons.label_outline_rounded,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      FutureBuilder<int>(
                        future: _getAccountCount(category.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text(
                            '$count ${count == 1 ? AppStrings.account.tr.toLowerCase() : AppStrings.accounts.tr.toLowerCase()}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontSize: screenWidth * 0.03,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined, size: 15),
                    onPressed: () => _showEditCategoryDialog(category),
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
                    onPressed: () => _showDeleteConfirmation(category, 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getAccountCount(String categoryId) async {
    final provider = context.read<CategoryProvider>();
    final accounts = await provider.getAccountsForCategory(categoryId);
    return accounts.length;
  }

  void _showCreateCategoryDialog() {
    final controller = TextEditingController();
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.createCategory.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.categoryName.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppStrings.categoryExample.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              maxLength: 12,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
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
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                return;
              }

              final categoryProvider = context.read<CategoryProvider>();
              final categoryName = controller.text.trim();

              Category? existingCategory;
              try {
                existingCategory = categoryProvider.categories.firstWhere(
                  (category) =>
                      category.name.toLowerCase() == categoryName.toLowerCase(),
                );
              } catch (e) {}

              if (existingCategory != null) {
                SnackBarHelper.showError(context, AppStrings.categoryAlreadyExists.tr);
                return;
              }

              final newCategory = Category(
                id: categoryProvider.generateCategoryId(),
                name: categoryName,
                createdDate: DateTime.now(),
              );

              final success = await categoryProvider.addCategory(newCategory);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  HapticFeedback.lightImpact();
                  SnackBarHelper.showSuccess(
                      context, AppStrings.categorySavedSuccess.tr);
                } else {
                  SnackBarHelper.showError(
                      context, AppStrings.failedSaveCategory.tr);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppStrings.save.tr),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final controller = TextEditingController(text: category.name);
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.editCategory.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.categoryName.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppStrings.categoryName.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              maxLength: 20,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
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
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                return;
              }

              if (controller.text.trim() == category.name) {
                Navigator.pop(context);
                return;
              }

              final categoryProvider = context.read<CategoryProvider>();
              final updatedCategory =
                  category.copyWith(name: controller.text.trim());

              final success =
                  await categoryProvider.updateCategory(updatedCategory);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  HapticFeedback.lightImpact();
                  SnackBarHelper.showSuccess(
                    context,
                    AppStrings.categoryUpdatedSuccess.tr,
                  );
                } else {
                  SnackBarHelper.showError(
                    context,
                    AppStrings.failedUpdateCategory.tr,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppStrings.update.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Category category, int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded,
                color: Theme.of(context).colorScheme.primary, size: 28),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(AppStrings.deleteCategoryConfirmation.tr),
          ],
        ),
        content: Text(
          AppStrings.deleteCategoryMessage.tr,
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
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category, index);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
            child: Text(
              AppStrings.delete.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category, int index) async {
    final categoryProvider = context.read<CategoryProvider>();

    final success = await categoryProvider.deleteCategory(category.id);
    if (mounted) {
      if (success) {
        HapticFeedback.mediumImpact();
        SnackBarHelper.showSuccess(
          context,
          AppStrings.categoryDeletedSuccess.tr,
          duration: const Duration(seconds: 1),
        );
      } else {
        SnackBarHelper.showError(context, AppStrings.failedDeleteCategory.tr);
      }
    }
  }
}
