import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/datasources/app_local_datasource.dart';

class ThemeProvider with ChangeNotifier {
  late AppLocalDataSource _appLocalDataSource;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _appLocalDataSource = GetIt.instance<AppLocalDataSource>();
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadThemeMode() async {
    try {
      final themeString = await _appLocalDataSource.getThemeMode();
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        default:
          themeString = 'system';
      }
      await _appLocalDataSource.setThemeMode(themeString);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode {
    return _themeMode == ThemeMode.system;
  }
}
