import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_vault_it/data/entities/LanguageOption.dart';

class AppLocalization {

  static Map<String, dynamic> _localizedStrings = {};
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  static bool get isRTL {
    return textDirection == TextDirection.rtl;
  }

  static TextDirection get textDirection {
    final rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(_currentLanguage)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  static Future<void> initialize({String language = 'en'}) async {
    _currentLanguage = language;
    await _loadLanguage(language);
  }

  static Future<void> _loadLanguage(String language) async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$language.json');
      _localizedStrings = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading language $language: $e');
      if (language != 'en') {
        await _loadLanguage('en');
      }
    }
  }

  static Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await _loadLanguage(language);
    }
  }

  static String tr(String key, [Map<String, String>? params]) {
    String result = _getNestedValue(_localizedStrings, key) ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{{$paramKey}}', paramValue);
      });
    }

    return result;
  }

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

  static Future<List<LanguageOption>> getAvailableLanguages() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<LanguageOption> languages = [];

      for (String key in manifestMap.keys) {
        if (key.startsWith('assets/lang/') && key.endsWith('.json')) {
          final String languageCode =
              key.replaceAll('assets/lang/', '').replaceAll('.json', '');

          try {
            String jsonString = await rootBundle.loadString(key);
            Map<String, dynamic> langData = json.decode(jsonString);
            String displayName = langData['languages']?[languageCode] ??
                languageCode.toUpperCase();

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

      languages.sort((a, b) => a.name.compareTo(b.name));

      return languages;
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      return [
        LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
        LanguageOption(code: 'fr', name: 'Français', nativeName: 'Français'),
      ];
    }
  }

  static bool hasKey(String key) {
    return _getNestedValue(_localizedStrings, key) != null;
  }

  static List<String> getAllKeys() {
    List<String> keys = [];
    _getAllKeysRecursive(_localizedStrings, '', keys);
    return keys;
  }

  static void _getAllKeysRecursive(
      Map<String, dynamic> map, String prefix, List<String> keys) {
    map.forEach((key, value) {
      String fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _getAllKeysRecursive(value, fullKey, keys);
      } else {
        keys.add(fullKey);
      }
    });
  }
}

extension LocalizationExtension on String {
  String get tr => AppLocalization.tr(this);

  String trParams(Map<String, String> params) =>
      AppLocalization.tr(this, params);
}
