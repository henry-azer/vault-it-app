import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vault_it/data/datasources/category_local_datasource.dart';
import 'package:vault_it/data/entities/category.dart';

class CategoryProvider with ChangeNotifier {
  late CategoryLocalDataSource _categoryLocalDataSource;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _selectedCategoryId;

  CategoryProvider() {
    _categoryLocalDataSource = GetIt.instance<CategoryLocalDataSource>();
    loadCategories();
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;
  int get categoryCount => _categories.length;

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _categoryLocalDataSource.getCategories();
      
      // Initialize sortOrder for categories with default value
      final categoriesWithDefaultOrder = _categories.where((c) => c.sortOrder == 0).toList();
      if (categoriesWithDefaultOrder.isNotEmpty) {
        await _initializeSortOrder();
      }
      
      // Sort categories by sortOrder
      _categories.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _initializeSortOrder() async {
    try {
      _categories.sort((a, b) => a.createdDate.compareTo(b.createdDate));
      for (int i = 0; i < _categories.length; i++) {
        if (_categories[i].sortOrder == 0) {
          final updatedCategory = _categories[i].copyWith(sortOrder: i + 1);
          _categories[i] = updatedCategory;
          await _categoryLocalDataSource.updateCategory(updatedCategory);
        }
      }
    } catch (e) {
      debugPrint('Error initializing category sort order: $e');
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      // Assign sortOrder as the highest value + 1 (newest on top)
      final maxSortOrder = _categories.isEmpty 
          ? 0 
          : _categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
      final categoryWithOrder = category.copyWith(sortOrder: maxSortOrder + 1);
      
      await _categoryLocalDataSource.addCategory(categoryWithOrder);
      _categories.add(categoryWithOrder);
      
      // Sort categories by sortOrder (highest first)
      _categories.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _categoryLocalDataSource.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryLocalDataSource.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      if (_selectedCategoryId == id) {
        _selectedCategoryId = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      return await _categoryLocalDataSource.getCategoryById(id);
    } catch (e) {
      debugPrint('Error getting category by id: $e');
      return null;
    }
  }

  Future<List<Category>> getCategoriesForAccount(String accountId) async {
    try {
      return await _categoryLocalDataSource.getCategoriesForAccount(accountId);
    } catch (e) {
      debugPrint('Error getting categories for account: $e');
      return [];
    }
  }

  Future<List<String>> getAccountsForCategory(String categoryId) async {
    try {
      return await _categoryLocalDataSource.getAccountsForCategory(categoryId);
    } catch (e) {
      debugPrint('Error getting accounts for category: $e');
      return [];
    }
  }

  Future<bool> updateAccountCategories(
      String accountId, List<String> categoryIds) async {
    try {
      await _categoryLocalDataSource.updateAccountCategories(
          accountId, categoryIds);
      return true;
    } catch (e) {
      debugPrint('Error updating account categories: $e');
      return false;
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategoryId = null;
    notifyListeners();
  }

  bool categoryExists(String name) {
    return _categories
        .any((c) => c.name.toLowerCase() == name.toLowerCase());
  }

  String generateCategoryId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> reorderCategories(int oldIndex, int newIndex, List<Category> currentList) async {
    try {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = currentList.removeAt(oldIndex);
      currentList.insert(newIndex, item);

      // Update sortOrder for all categories based on new positions
      for (int i = 0; i < currentList.length; i++) {
        final sortOrderValue = currentList.length - i;
        final updatedCategory = currentList[i].copyWith(sortOrder: sortOrderValue);
        currentList[i] = updatedCategory;
        await _categoryLocalDataSource.updateCategory(updatedCategory);

        // Update the main categories list immediately to avoid visual glitches
        final mainIndex = _categories.indexWhere((c) => c.id == updatedCategory.id);
        if (mainIndex != -1) {
          _categories[mainIndex] = updatedCategory;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error reordering categories: $e');
      return false;
    }
  }

  // Predefined category colors
  static const List<String> defaultColors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#FFA07A', // Light Salmon
    '#98D8C8', // Mint
    '#F7DC6F', // Yellow
    '#BB8FCE', // Purple
    '#85C1E2', // Sky Blue
    '#F8B88B', // Peach
    '#52BE80', // Green
  ];

  // Predefined category icons
  static const List<IconData> defaultIcons = [
    Icons.work_outline,
    Icons.shopping_bag_outlined,
    Icons.account_balance_outlined,
    Icons.school_outlined,
    Icons.favorite_border,
    Icons.sports_esports_outlined,
    Icons.flight_outlined,
    Icons.restaurant_outlined,
    Icons.local_hospital_outlined,
    Icons.home_outlined,
  ];
}
