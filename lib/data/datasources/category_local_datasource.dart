import 'package:vault_it/core/managers/database-manager/i_database_manager.dart';
import 'package:vault_it/core/utils/app_local_storage_strings.dart';
import 'package:vault_it/data/entities/category.dart';

abstract class CategoryLocalDataSource {
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getCategoriesForAccount(String accountId);
  Future<void> linkAccountToCategory(String accountId, String categoryId);
  Future<void> unlinkAccountFromCategory(String accountId, String categoryId);
  Future<void> updateAccountCategories(String accountId, List<String> categoryIds);
  Future<List<String>> getAccountsForCategory(String categoryId);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final IDatabaseManager databaseManager;

  CategoryLocalDataSourceImpl({required this.databaseManager});

  @override
  Future<List<Category>> getCategories() async {
    final List<Map<String, dynamic>> maps =
        await databaseManager.query(AppLocalStorageKeys.categoriesTable);
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final List<Map<String, dynamic>> maps = await databaseManager.query(
      AppLocalStorageKeys.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> addCategory(Category category) async {
    await databaseManager.insert(
        AppLocalStorageKeys.categoriesTable, category.toMap());
  }

  @override
  Future<void> updateCategory(Category category) async {
    await databaseManager.update(
      AppLocalStorageKeys.categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    // First remove all account-category links
    await databaseManager.delete(
      AppLocalStorageKeys.accountCategoriesTable,
      where: 'categoryId = ?',
      whereArgs: [id],
    );
    
    // Then delete the category
    await databaseManager.delete(
      AppLocalStorageKeys.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Category>> getCategoriesForAccount(String accountId) async {
    // First get all category IDs for this account
    final List<Map<String, dynamic>> linkMaps = await databaseManager.query(
      AppLocalStorageKeys.accountCategoriesTable,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );

    if (linkMaps.isEmpty) {
      return [];
    }

    // Then fetch each category
    final List<Category> categories = [];
    for (final linkMap in linkMaps) {
      final categoryId = linkMap['categoryId'];
      final category = await getCategoryById(categoryId);
      if (category != null) {
        categories.add(category);
      }
    }

    return categories;
  }

  @override
  Future<void> linkAccountToCategory(String accountId, String categoryId) async {
    await databaseManager.insert(
      AppLocalStorageKeys.accountCategoriesTable,
      {
        'accountId': accountId,
        'categoryId': categoryId,
      },
    );
  }

  @override
  Future<void> unlinkAccountFromCategory(String accountId, String categoryId) async {
    await databaseManager.delete(
      AppLocalStorageKeys.accountCategoriesTable,
      where: 'accountId = ? AND categoryId = ?',
      whereArgs: [accountId, categoryId],
    );
  }

  @override
  Future<void> updateAccountCategories(String accountId, List<String> categoryIds) async {
    // Remove all existing links for this account
    await databaseManager.delete(
      AppLocalStorageKeys.accountCategoriesTable,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );

    // Add new links
    for (final categoryId in categoryIds) {
      await linkAccountToCategory(accountId, categoryId);
    }
  }

  @override
  Future<List<String>> getAccountsForCategory(String categoryId) async {
    final List<Map<String, dynamic>> linkMaps = await databaseManager.query(
      AppLocalStorageKeys.accountCategoriesTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return linkMaps.map((map) => map['accountId'] as String).toList();
  }
}
