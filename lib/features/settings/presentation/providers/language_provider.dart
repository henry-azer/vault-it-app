import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/localization_helper.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en');
  List<LanguageOption> _availableLanguages = [];
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  List<LanguageOption> get availableLanguages => _availableLanguages;
  bool get isLoading => _isLoading;
  
  String get currentLanguageName {
    final currentLang = _availableLanguages.firstWhere(
      (lang) => lang.code == _currentLocale.languageCode,
      orElse: () => LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    );
    return currentLang.name;
  }

  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load available languages from assets
      _availableLanguages = await LocalizationHelper.getAvailableLanguages();
      
      // Load saved language preference
      await _loadSavedLanguage();
      
      // Initialize localization helper
      await LocalizationHelper.initialize(language: _currentLocale.languageCode);
    } catch (e) {
      debugPrint('Error initializing language provider: $e');
      // Set defaults if initialization fails
      _availableLanguages = [
        LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
        LanguageOption(code: 'fr', name: 'Français', nativeName: 'Français'),
      ];
      _currentLocale = const Locale('en');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        // Validate that the saved language is still available
        final isValid = _availableLanguages.any((lang) => lang.code == savedLanguage);
        if (isValid) {
          _currentLocale = Locale(savedLanguage);
        } else {
          // Reset to default if saved language is no longer available
          _currentLocale = const Locale('en');
          await _clearSavedLanguage();
        }
      } else {
        _currentLocale = const Locale('en');
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      _currentLocale = const Locale('en');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;

    try {
      // Validate language code
      final isValid = _availableLanguages.any((lang) => lang.code == languageCode);
      if (!isValid) {
        debugPrint('Invalid language code: $languageCode');
        return;
      }

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      // Update locale
      _currentLocale = Locale(languageCode);
      
      // Update localization helper
      await LocalizationHelper.changeLanguage(languageCode);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  Future<void> _clearSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
    } catch (e) {
      debugPrint('Error clearing saved language: $e');
    }
  }

  /// Get language option by code
  LanguageOption? getLanguageByCode(String code) {
    try {
      return _availableLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Refresh available languages
  Future<void> refreshLanguages() async {
    try {
      _availableLanguages = await LocalizationHelper.getAvailableLanguages();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing languages: $e');
    }
  }

  /// Get text direction for current language
  TextDirection get textDirection => LocalizationHelper.textDirection;

  /// Check if current language is RTL
  bool get isRTL => LocalizationHelper.isRTL;
}
