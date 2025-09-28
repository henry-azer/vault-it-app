import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationHelper {
  static Map<String, dynamic> _localizedStrings = {};
  static String _currentLanguage = 'en';

  /// Initialize localization with default language
  static Future<void> initialize({String language = 'en'}) async {
    _currentLanguage = language;
    await _loadLanguage(language);
  }

  /// Load language file from assets
  static Future<void> _loadLanguage(String language) async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$language.json');
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading language $language: $e');
      // Fallback to English if language file not found
      if (language != 'en') {
        await _loadLanguage('en');
      }
    }
  }

  /// Change current language
  static Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await _loadLanguage(language);
    }
  }

  /// Get current language code
  static String get currentLanguage => _currentLanguage;

  /// Get localized string by key
  static String tr(String key, [Map<String, String>? params]) {
    String result = _getNestedValue(_localizedStrings, key) ?? key;
    
    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{{$paramKey}}', paramValue);
      });
    }
    
    return result;
  }

  /// Get nested value from JSON structure (e.g., 'languages.en')
  static String? _getNestedValue(Map<String, dynamic> map, String key) {
    List<String> keys = key.split('.');
    dynamic current = map;
    
    for (String k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }
    
    return current?.toString();
  }

  /// Get available languages from assets
  static Future<List<LanguageOption>> getAvailableLanguages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final List<LanguageOption> languages = [];
      
      for (String key in manifestMap.keys) {
        if (key.startsWith('assets/lang/') && key.endsWith('.json')) {
          final String languageCode = key
              .replaceAll('assets/lang/', '')
              .replaceAll('.json', '');
          
          // Load the language file to get the display name
          try {
            String jsonString = await rootBundle.loadString(key);
            Map<String, dynamic> langData = json.decode(jsonString);
            String displayName = langData['languages']?[languageCode] ?? languageCode.toUpperCase();
            
            languages.add(LanguageOption(
              code: languageCode,
              name: displayName,
              nativeName: displayName,
            ));
          } catch (e) {
            debugPrint('Error loading language $languageCode: $e');
          }
        }
      }
      
      // Sort languages alphabetically
      languages.sort((a, b) => a.name.compareTo(b.name));
      
      return languages;
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      // Return default languages if asset manifest fails
      return [
        LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
        LanguageOption(code: 'fr', name: 'Français', nativeName: 'Français'),
      ];
    }
  }

  /// Check if key exists in current localization
  static bool hasKey(String key) {
    return _getNestedValue(_localizedStrings, key) != null;
  }

  /// Get all keys (for debugging)
  static List<String> getAllKeys() {
    List<String> keys = [];
    _getAllKeysRecursive(_localizedStrings, '', keys);
    return keys;
  }

  static void _getAllKeysRecursive(Map<String, dynamic> map, String prefix, List<String> keys) {
    map.forEach((key, value) {
      String fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _getAllKeysRecursive(value, fullKey, keys);
      } else {
        keys.add(fullKey);
      }
    });
  }

  /// Format number with current locale
  static String formatNumber(num number) {
    // Simple number formatting - can be enhanced with proper locale formatting
    return number.toString();
  }

  /// Format date with current locale
  static String formatDate(DateTime date) {
    // Simple date formatting - can be enhanced with proper locale formatting
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get direction for current language (for RTL support)
  static TextDirection get textDirection {
    // Add RTL languages here if needed
    final rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(_currentLanguage) 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }

  /// Check if current language is RTL
  static bool get isRTL {
    return textDirection == TextDirection.rtl;
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LanguageOption(code: $code, name: $name)';
}

/// Extension for easier access to localization
extension LocalizationExtension on String {
  String get tr => LocalizationHelper.tr(this);
  String trParams(Map<String, String> params) => LocalizationHelper.tr(this, params);
}
