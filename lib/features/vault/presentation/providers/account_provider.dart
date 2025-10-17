import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:vault_it/data/datasources/account_local_datasource.dart';
import 'package:vault_it/data/datasources/category_local_datasource.dart';
import 'package:vault_it/data/entities/account.dart';
import 'package:vault_it/data/entities/category.dart';

class AccountProvider with ChangeNotifier {
  late AccountLocalDataSource _accountLocalDataSource;
  late CategoryLocalDataSource _categoryLocalDataSource;
  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Account? _selectedAccount;
  Map<String, List<Category>> _accountCategories = {};

  AccountProvider() {
    _accountLocalDataSource = GetIt.instance<AccountLocalDataSource>();
    _categoryLocalDataSource = GetIt.instance<CategoryLocalDataSource>();
    loadAccounts();
  }

  List<Account> get accounts =>
      _filteredAccounts.isEmpty && _searchQuery.isEmpty
          ? _accounts
          : _filteredAccounts;

  List<Account> get filteredAccounts => _filteredAccounts;

  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;

  Account? get selectedAccount => _selectedAccount;

  int get accountCount => _accounts.length;

  Map<String, List<Category>> get accountCategories => _accountCategories;

  List<Category> getCategoriesForAccount(String accountId) {
    return _accountCategories[accountId] ?? [];
  }

  Future<void> loadAccounts() async {
    _setLoading(true);
    try {
      _accounts = await _accountLocalDataSource.getAccounts();
      final accountsWithDefaultOrder = _accounts.where((a) => a.sortOrder == 0).toList();
      if (accountsWithDefaultOrder.isNotEmpty) {
        await _initializeSortOrder();
      }

      // Load categories for all accounts
      await _loadAccountCategories();

      _applySearch();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAccountCategories() async {
    _accountCategories.clear();
    for (final account in _accounts) {
      try {
        final categories = await _categoryLocalDataSource.getCategoriesForAccount(account.id);
        _accountCategories[account.id] = categories;
      } catch (e) {
        debugPrint('Error loading categories for account ${account.id}: $e');
        _accountCategories[account.id] = [];
      }
    }
  }

  Future<void> _initializeSortOrder() async {
    try {
      _accounts.sort((a, b) => a.addedDate.compareTo(b.addedDate));
      for (int i = 0; i < _accounts.length; i++) {
        if (_accounts[i].sortOrder == 0) {
          final updatedAccount = _accounts[i].copyWith(sortOrder: i + 1);
          _accounts[i] = updatedAccount;
          await _accountLocalDataSource.updateAccount(updatedAccount);
        }
      }
    } catch (e) {
      debugPrint('Error initializing sort order: $e');
    }
  }

  Future<bool> addAccount(Account account, {List<String> categoryIds = const []}) async {
    try {
      final maxSortOrder = _accounts.isEmpty
          ? 0
          : _accounts.map((a) => a.sortOrder).reduce((a, b) => a > b ? a : b);
      final accountWithOrder = account.copyWith(sortOrder: maxSortOrder + 1);
      await _accountLocalDataSource.addAccount(accountWithOrder);
      
      // Link categories
      if (categoryIds.isNotEmpty) {
        await _categoryLocalDataSource.updateAccountCategories(accountWithOrder.id, categoryIds);
        final categories = await _categoryLocalDataSource.getCategoriesForAccount(accountWithOrder.id);
        _accountCategories[accountWithOrder.id] = categories;
      } else {
        _accountCategories[accountWithOrder.id] = [];
      }
      
      _accounts.add(accountWithOrder);
      _applySearch();
      return true;
    } catch (e) {
      debugPrint('Error adding account: $e');
      return false;
    }
  }

  Future<bool> updateAccount(Account account, {List<String>? categoryIds}) async {
    try {
      final oldAccount = await _accountLocalDataSource.getAccountById(account.id);
      List<PasswordHistoryItem> updatedHistory = List.from(account.passwordHistory);

      if (oldAccount != null && oldAccount.password != account.password) {
        updatedHistory.insert(
          0,
          PasswordHistoryItem(
            password: oldAccount.password,
            changedDate: oldAccount.lastModified,
          ),
        );
      }

      final updatedAccount = account.copyWith(
        lastModified: DateTime.now(),
        passwordHistory: updatedHistory,
      );

      await _accountLocalDataSource.updateAccount(updatedAccount);
      
      // Update categories if provided
      if (categoryIds != null) {
        await _categoryLocalDataSource.updateAccountCategories(updatedAccount.id, categoryIds);
        final categories = await _categoryLocalDataSource.getCategoriesForAccount(updatedAccount.id);
        _accountCategories[updatedAccount.id] = categories;
      }
      
      final index = _accounts.indexWhere((p) => p.id == updatedAccount.id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        _applySearch();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating account: $e');
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    try {
      await _accountLocalDataSource.deleteAccount(id);
      _accounts.removeWhere((p) => p.id == id);
      _accountCategories.remove(id);
      _applySearch();
      return true;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
  }

  Future<Account?> getAccountById(String id) async {
    try {
      return await _accountLocalDataSource.getAccountById(id);
    } catch (e) {
      debugPrint('Error getting account by id: $e');
      return null;
    }
  }

  Future<bool> accountExists(String id) async {
    try {
      final account = await _accountLocalDataSource.getAccountById(id);
      return account != null;
    } catch (e) {
      debugPrint('Error checking if account exists: $e');
      return false;
    }
  }

  void searchAccounts(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredAccounts = [];
    } else {
      _filteredAccounts = _accounts.where((account) {
        return account.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            account.username
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredAccounts = [];
    notifyListeners();
  }

  void selectAccount(Account account) {
    _selectedAccount = account;
    notifyListeners();
  }

  Future<void> deleteAllAccounts() async {
    try {
      await _accountLocalDataSource.deleteAllAccounts();
      _accounts.clear();
      _filteredAccounts.clear();
      _accountCategories.clear();
      _selectedAccount = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all accounts: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String generateAccountId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final index = _accounts.indexWhere((p) => p.id == id);
      if (index != -1) {
        final account = _accounts[index];
        final updatedAccount =
            account.copyWith(isFavorite: !account.isFavorite);

        await _accountLocalDataSource.updateAccount(updatedAccount);
        _accounts[index] = updatedAccount;

        if (_selectedAccount?.id == id) {
          _selectedAccount = updatedAccount;
        }

        _applySearch();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> reorderAccounts(int oldIndex, int newIndex, List<Account> currentList) async {
    try {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = currentList.removeAt(oldIndex);
      currentList.insert(newIndex, item);

      for (int i = 0; i < currentList.length; i++) {
        final sortOrderValue = currentList.length - i;
        final updatedAccount = currentList[i].copyWith(sortOrder: sortOrderValue);
        currentList[i] = updatedAccount;
        await _accountLocalDataSource.updateAccount(updatedAccount);

        final mainIndex = _accounts.indexWhere((a) => a.id == updatedAccount.id);
        if (mainIndex != -1) {
          _accounts[mainIndex] = updatedAccount;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error reordering accounts: $e');
      return false;
    }
  }
}
