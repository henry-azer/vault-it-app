import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pass_vault_it/data/datasources/password_local_datasource.dart';
import 'package:pass_vault_it/data/entities/password.dart';

class PasswordProvider with ChangeNotifier {
  late PasswordLocalDataSource _passwordLocalDataSource;
  List<Password> _passwords = [];
  List<Password> _filteredPasswords = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Password? _selectedPassword;

  PasswordProvider() {
    _passwordLocalDataSource = GetIt.instance<PasswordLocalDataSource>();
    loadPasswords();
  }

  List<Password> get passwords =>
      _filteredPasswords.isEmpty && _searchQuery.isEmpty
          ? _passwords
          : _filteredPasswords;

  List<Password> get filteredPasswords => _filteredPasswords;

  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;

  Password? get selectedPassword => _selectedPassword;

  int get passwordCount => _passwords.length;

  Future<void> loadPasswords() async {
    _setLoading(true);
    try {
      _passwords = await _passwordLocalDataSource.getPasswords();
      _applySearch();
    } catch (e) {
      debugPrint('Error loading passwords: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPassword(Password password) async {
    try {
      await _passwordLocalDataSource.addPassword(password);
      _passwords.add(password);
      _applySearch();
      return true;
    } catch (e) {
      debugPrint('Error adding password: $e');
      return false;
    }
  }

  Future<bool> updatePassword(Password password) async {
    try {
      final updatedPassword = password.copyWith(
        lastModified: DateTime.now(),
      );

      await _passwordLocalDataSource.updatePassword(updatedPassword);
      final index = _passwords.indexWhere((p) => p.id == updatedPassword.id);
      if (index != -1) {
        _passwords[index] = updatedPassword;
        _applySearch();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }

  Future<bool> deletePassword(String id) async {
    try {
      await _passwordLocalDataSource.deletePassword(id);
      _passwords.removeWhere((p) => p.id == id);
      _applySearch();
      return true;
    } catch (e) {
      debugPrint('Error deleting password: $e');
      return false;
    }
  }

  Future<Password?> getPasswordById(String id) async {
    try {
      return await _passwordLocalDataSource.getPasswordById(id);
    } catch (e) {
      debugPrint('Error getting password by id: $e');
      return null;
    }
  }

  Future<bool> passwordExists(String id) async {
    try {
      final password = await _passwordLocalDataSource.getPasswordById(id);
      return password != null;
    } catch (e) {
      debugPrint('Error checking if password exists: $e');
      return false;
    }
  }

  void searchPasswords(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredPasswords = [];
    } else {
      _filteredPasswords = _passwords.where((password) {
        return password.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            password.username
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredPasswords = [];
    notifyListeners();
  }

  void selectPassword(Password password) {
    _selectedPassword = password;
    debugPrint('Password selected: ${password.title}');
    notifyListeners();
  }

  Future<void> deleteAllPasswords() async {
    try {
      await _passwordLocalDataSource.deleteAllPasswords();
      _passwords.clear();
      _filteredPasswords.clear();
      _selectedPassword = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all passwords: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String generatePasswordId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final index = _passwords.indexWhere((p) => p.id == id);
      if (index != -1) {
        final password = _passwords[index];
        final updatedPassword =
            password.copyWith(isFavorite: !password.isFavorite);

        await _passwordLocalDataSource.updatePassword(updatedPassword);
        _passwords[index] = updatedPassword;

        if (_selectedPassword?.id == id) {
          _selectedPassword = updatedPassword;
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
}
