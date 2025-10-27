import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/config/routes/app_routes.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/data/entities/category.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final bool isDark;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isDark,
    this.onDelete,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Future<int> _getAccountCount() async {
    final provider = context.read<CategoryProvider>();
    final accounts = await provider.getAccountsForCategory(widget.category.id);
    return accounts.length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed
                ? Theme
                .of(context)
                .colorScheme
                .primary
                : (widget.isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder),
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1)
                  : (widget.isDark
                  ? Colors.black26
                  : Colors.black.withOpacity(0.08)),
              blurRadius: _isPressed ? 4 : 2,
              offset: Offset(0, _isPressed ? 4 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery
                .of(context)
                .size
                .width * 0.04,
            vertical: MediaQuery
                .of(context)
                .size
                .width * 0.04,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.label_outline_rounded,
                  size: 24,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: _getAccountCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          '$count ${count == 1 ? AppStrings.account.tr
                              .toLowerCase() : AppStrings.accounts.tr
                              .toLowerCase()}',
                          style: TextStyle(
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context,
                      Routes.manageCategory,
                      arguments: widget.category,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
