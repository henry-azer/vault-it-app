import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vault_it/config/localization/app_localization.dart';
import 'package:vault_it/core/utils/app_colors.dart';
import 'package:vault_it/core/utils/app_strings.dart';
import 'package:vault_it/data/entities/category.dart';
import 'package:vault_it/features/vault/presentation/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryDropdownSelector extends StatefulWidget {
  final Set<String> selectedCategoryIds;
  final Function(Set<String>) onCategoriesChanged;
  final bool isDark;

  const CategoryDropdownSelector({
    super.key,
    required this.selectedCategoryIds,
    required this.onCategoriesChanged,
    required this.isDark,
  });

  @override
  State<CategoryDropdownSelector> createState() =>
      _CategoryDropdownSelectorState();
}

class _CategoryDropdownSelectorState extends State<CategoryDropdownSelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _selectCategory(String categoryId) {
    final newSet = Set<String>.from(widget.selectedCategoryIds);
    newSet.add(categoryId);
    widget.onCategoriesChanged(newSet);
    _searchController.clear();
  }

  void _removeCategory(String categoryId) {
    final newSet = Set<String>.from(widget.selectedCategoryIds);
    newSet.remove(categoryId);
    widget.onCategoriesChanged(newSet);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final selectedCategories = categoryProvider.categories
            .where((cat) => widget.selectedCategoryIds.contains(cat.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.darkCardBorder
                      : AppColors.lightCardBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  RawAutocomplete<Category>(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final searchQuery =
                          textEditingValue.text.trim().toLowerCase();
                      final unselectedCategories = categoryProvider.categories
                          .where((cat) =>
                              !widget.selectedCategoryIds.contains(cat.id))
                          .toList();

                      if (searchQuery.isEmpty) {
                        return unselectedCategories;
                      }

                      return unselectedCategories
                          .where((cat) =>
                              cat.name.toLowerCase().contains(searchQuery))
                          .toList();
                    },
                    onSelected: (Category selection) {
                      _selectCategory(selection.id);
                      HapticFeedback.lightImpact();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppStrings.categoriesOptional.tr,
                          hintText: AppStrings.searchCategories.tr,
                          prefixIcon: Container(
                            margin: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.025),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.label_outline_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      controller.clear();
                                    });
                                    focusNode.unfocus();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: widget.isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.04,
                            vertical:
                                MediaQuery.of(context).size.height * 0.018,
                          ),
                          labelStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                          hintStyle: TextStyle(
                            color: widget.isDark
                                ? AppColors.darkTextDisabled
                                : AppColors.lightTextDisabled,
                            fontSize: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AppColors.darkCardBackground
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView(
                              padding: const EdgeInsets.all(8),
                              shrinkWrap: true,
                              children: [
                                if (options.isNotEmpty)
                                  ...options.map((category) {
                                    return InkWell(
                                      onTap: () => onSelected(category),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.012,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.label_outline_rounded,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            Expanded(
                                              child: Text(
                                                category.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (selectedCategories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedCategories.map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.15),
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.label_outlined,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _removeCategory(category.id);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
