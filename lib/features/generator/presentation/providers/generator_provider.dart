import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vault_it/core/enums/vault_enums.dart';

class GeneratorProvider with ChangeNotifier {
  int _passwordLength = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _excludeCharacters = '';
  String _generatedPassword = '';
  bool _isGenerating = false;
  
  List<PasswordHistoryItem> _passwordHistory = [];
  static const int _maxHistorySize = 50;
  static const String _historyKey = 'password_history';

  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  int get passwordLength => _passwordLength;
  bool get includeUppercase => _includeUppercase;
  bool get includeLowercase => _includeLowercase;
  bool get includeNumbers => _includeNumbers;
  bool get includeSymbols => _includeSymbols;
  String get excludeCharacters => _excludeCharacters;
  String get generatedPassword => _generatedPassword;
  bool get isGenerating => _isGenerating;
  List<PasswordHistoryItem> get passwordHistory => List.unmodifiable(_passwordHistory);
  bool get hasHistory => _passwordHistory.isNotEmpty;

  GeneratorProvider() {
    _loadPasswordHistory();
    generatePassword();
  }

  void setPasswordLength(int length) {
    if (length >= 4 && length <= 22) {
      _passwordLength = length;
      notifyListeners();
      generatePassword();
    }
  }

  void setIncludeUppercase(bool value) {
    _includeUppercase = value;
    _validateSettings();
    generatePassword();
  }

  void setIncludeLowercase(bool value) {
    _includeLowercase = value;
    _validateSettings();
    generatePassword();
  }

  void setIncludeNumbers(bool value) {
    _includeNumbers = value;
    _validateSettings();
    generatePassword();
  }

  void setIncludeSymbols(bool value) {
    _includeSymbols = value;
    _validateSettings();
    generatePassword();
  }

  void setExcludeCharacters(String characters) {
    _excludeCharacters = characters;
    generatePassword();
  }

  void _validateSettings() {
    if (!_includeUppercase && !_includeLowercase && !_includeNumbers && !_includeSymbols) {
      _includeLowercase = true;
    }
    notifyListeners();
  }

  void generatePassword() {
    _isGenerating = true;
    notifyListeners();

    try {
      String characterSet = '';
      
      if (_includeUppercase) characterSet += _uppercase;
      if (_includeLowercase) characterSet += _lowercase;
      if (_includeNumbers) characterSet += _numbers;
      if (_includeSymbols) characterSet += _symbols;

      if (_excludeCharacters.isNotEmpty) {
        for (String char in _excludeCharacters.split('')) {
          characterSet = characterSet.replaceAll(char, '');
        }
      }

      if (characterSet.isEmpty) {
        _generatedPassword = 'Error: No valid characters';
        return;
      }

      final random = Random.secure();
      final password = StringBuffer();

      if (_includeUppercase && _uppercase.isNotEmpty) {
        final validUppercase = _uppercase.split('').where((c) => !_excludeCharacters.contains(c)).toList();
        if (validUppercase.isNotEmpty) {
          password.write(validUppercase[random.nextInt(validUppercase.length)]);
        }
      }

      if (_includeLowercase && _lowercase.isNotEmpty) {
        final validLowercase = _lowercase.split('').where((c) => !_excludeCharacters.contains(c)).toList();
        if (validLowercase.isNotEmpty) {
          password.write(validLowercase[random.nextInt(validLowercase.length)]);
        }
      }

      if (_includeNumbers && _numbers.isNotEmpty) {
        final validNumbers = _numbers.split('').where((c) => !_excludeCharacters.contains(c)).toList();
        if (validNumbers.isNotEmpty) {
          password.write(validNumbers[random.nextInt(validNumbers.length)]);
        }
      }

      if (_includeSymbols && _symbols.isNotEmpty) {
        final validSymbols = _symbols.split('').where((c) => !_excludeCharacters.contains(c)).toList();
        if (validSymbols.isNotEmpty) {
          password.write(validSymbols[random.nextInt(validSymbols.length)]);
        }
      }

      while (password.length < _passwordLength) {
        password.write(characterSet[random.nextInt(characterSet.length)]);
      }

      final passwordList = password.toString().split('');
      passwordList.shuffle(random);
      
      _generatedPassword = passwordList.take(_passwordLength).join('');
      
      if (_generatedPassword.isNotEmpty &&
          _generatedPassword != 'Error generating password' &&
          (_passwordHistory.isEmpty || _passwordHistory.first.password != _generatedPassword)) {
      }
    } catch (e) {
      _generatedPassword = 'Error generating password';
      debugPrint('Password generation error: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> copyToClipboard() async {
    if (_generatedPassword.isNotEmpty && _generatedPassword != 'Error generating password') {
      await Clipboard.setData(ClipboardData(text: _generatedPassword));
      _addToHistory(_generatedPassword);
    }
  }

  double calculatePasswordStrength() {
    if (_generatedPassword.isEmpty || _generatedPassword.startsWith('Error')) {
      return 0.0;
    }

    double strength = 0.0;

    if (_generatedPassword.length >= 8) strength += 0.2;
    if (_generatedPassword.length >= 12) strength += 0.2;

    if (_generatedPassword.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (_generatedPassword.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (_generatedPassword.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (_generatedPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  String getPasswordStrengthLabel() {
    final strengthValue = calculatePasswordStrength();
    final strength = PasswordStrength.fromValue(strengthValue);
    
    switch (strength) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color getPasswordStrengthColor() {
    final strengthValue = calculatePasswordStrength();
    final strength = PasswordStrength.fromValue(strengthValue);
    
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red[700]!;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow[700]!;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  void resetToDefaults() {
    _passwordLength = 16;
    _includeUppercase = true;
    _includeLowercase = true;
    _includeNumbers = true;
    _includeSymbols = true;
    _excludeCharacters = '';
    generatePassword();
  }

  String getCharacterSetPreview() {
    String preview = '';
    if (_includeUppercase) preview += 'ABC...';
    if (_includeLowercase) preview += '${preview.isNotEmpty ? ', ' : ''}abc...';
    if (_includeNumbers) preview += '${preview.isNotEmpty ? ', ' : ''}123...';
    if (_includeSymbols) preview += '${preview.isNotEmpty ? ', ' : ''}!@#...';
    
    return preview.isEmpty ? 'No characters selected' : preview;
  }

  List<String> generateMultiplePasswords(int count) {
    final passwords = <String>[];
    final originalPassword = _generatedPassword;
    
    for (int i = 0; i < count; i++) {
      generatePassword();
      passwords.add(_generatedPassword);
    }
    
    _generatedPassword = originalPassword;
    notifyListeners();
    
    return passwords;
  }
  
  void _addToHistory(String password) {
    final historyItem = PasswordHistoryItem(
      password: password,
      timestamp: DateTime.now(),
      length: password.length,
      hasUppercase: _includeUppercase,
      hasLowercase: _includeLowercase,
      hasNumbers: _includeNumbers,
      hasSymbols: _includeSymbols,
      strength: getPasswordStrengthLabel(),
    );
    
    _passwordHistory.removeWhere((item) => item.password == password);
    
    _passwordHistory.insert(0, historyItem);
    
    if (_passwordHistory.length > _maxHistorySize) {
      _passwordHistory = _passwordHistory.take(_maxHistorySize).toList();
    }
    
    _savePasswordHistory();
  }
  
  Future<void> _loadPasswordHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _passwordHistory = historyList
            .map((item) => PasswordHistoryItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading password history: $e');
      _passwordHistory = [];
    }
  }
  
  Future<void> _savePasswordHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _passwordHistory.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving password history: $e');
    }
  }
  
  Future<void> clearHistory() async {
    _passwordHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }
  
  void removeFromHistory(String password) {
    _passwordHistory.removeWhere((item) => item.password == password);
    _savePasswordHistory();
    notifyListeners();
  }
  
  Future<void> copyFromHistory(String password) async {
    await Clipboard.setData(ClipboardData(text: password));
  }
}

class PasswordHistoryItem {
  final String password;
  final DateTime timestamp;
  final int length;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSymbols;
  final String strength;
  
  PasswordHistoryItem({
    required this.password,
    required this.timestamp,
    required this.length,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumbers,
    required this.hasSymbols,
    required this.strength,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'timestamp': timestamp.toIso8601String(),
      'length': length,
      'hasUppercase': hasUppercase,
      'hasLowercase': hasLowercase,
      'hasNumbers': hasNumbers,
      'hasSymbols': hasSymbols,
      'strength': strength,
    };
  }
  
  factory PasswordHistoryItem.fromJson(Map<String, dynamic> json) {
    return PasswordHistoryItem(
      password: json['password'],
      timestamp: DateTime.parse(json['timestamp']),
      length: json['length'],
      hasUppercase: json['hasUppercase'],
      hasLowercase: json['hasLowercase'],
      hasNumbers: json['hasNumbers'],
      hasSymbols: json['hasSymbols'],
      strength: json['strength'],
    );
  }
  
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  Color get strengthColor {
    switch (strength) {
      case 'Very Strong':
        return Colors.green;
      case 'Strong':
        return Colors.lightGreen;
      case 'Medium':
        return Colors.orange;
      case 'Weak':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
  
  List<String> get characterTypes {
    final types = <String>[];
    if (hasUppercase) types.add('A-Z');
    if (hasLowercase) types.add('a-z');
    if (hasNumbers) types.add('0-9');
    if (hasSymbols) types.add('!@#');
    return types;
  }
}
