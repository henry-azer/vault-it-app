import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/datasources/user_local_datasource.dart';
import '../../../../data/entities/user.dart';

class AuthProvider with ChangeNotifier {
  late UserLocalDataSource _userLocalDataSource;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _masterPassword;
  User? _currentUser;

  AuthProvider() {
    _userLocalDataSource = GetIt.instance<UserLocalDataSource>();
    _loadAuthenticationStatus();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get masterPassword => _masterPassword;
  User? get currentUser => _currentUser;

  void _loadAuthenticationStatus() async {
    try {
      _isAuthenticated = await _userLocalDataSource.isAuthenticated();
      _masterPassword = await _userLocalDataSource.getMasterPassword();
      _currentUser = await _userLocalDataSource.getUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading authentication status: $e');
    }
  }

  Future<bool> login(String password) async {
    _setLoading(true);
    try {
      final storedPassword = await _userLocalDataSource.getMasterPassword();
      
      if (storedPassword == password) {
        await _userLocalDataSource.setAuthenticated(true);
        _isAuthenticated = true;
        _masterPassword = password;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String password) async {
    _setLoading(true);
    try {
      await _userLocalDataSource.setMasterPassword(password);
      await _userLocalDataSource.setAuthenticated(true);
      
      // Create user entity
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        masterPassword: password,
        isAuthenticated: true,
        isOnboardingCompleted: true,
        createdDate: DateTime.now(),
      );
      
      await _userLocalDataSource.setUser(user);
      
      _isAuthenticated = true;
      _masterPassword = password;
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      final storedPassword = await _userLocalDataSource.getMasterPassword();
      
      if (storedPassword != currentPassword) {
        return false;
      }
      
      await _userLocalDataSource.setMasterPassword(newPassword);
      
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(masterPassword: newPassword);
        await _userLocalDataSource.setUser(updatedUser);
        _currentUser = updatedUser;
      }
      
      _masterPassword = newPassword;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _userLocalDataSource.setAuthenticated(false);
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> hasMasterPassword() async {
    try {
      final password = await _userLocalDataSource.getMasterPassword();
      return password != null && password.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking master password: $e');
      return false;
    }
  }

  Future<bool> hasUser() async {
    try {
      final user = await _userLocalDataSource.getUser();
      return user != null;
    } catch (e) {
      debugPrint('Error checking user: $e');
      return false;
    }
  }

  Future<bool> isFirstTimeUser() async {
    try {
      final user = await _userLocalDataSource.getUser();
      final isOnboarded = await _userLocalDataSource.isOnboardingCompleted();
      return user == null && !isOnboarded;
    } catch (e) {
      debugPrint('Error checking first time user: $e');
      return true; // Default to true to show onboarding/registration
    }
  }

  Future<void> clearUserData() async {
    try {
      await _userLocalDataSource.clearUserData();
      _isAuthenticated = false;
      _masterPassword = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
}
