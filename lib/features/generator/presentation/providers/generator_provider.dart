import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GeneratorProvider with ChangeNotifier {
  // Password generation settings
  int _passwordLength = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _excludeCharacters = '';
  String _generatedPassword = '';
  bool _isGenerating = false;
  
  // Password history
  List<PasswordHistoryItem> _passwordHistory = [];
  static const int _maxHistorySize = 50;
  static const String _historyKey = 'password_history';

  // Character sets
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  // Getters
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
    if (length >= 4 && length <= 128) {
      _passwordLength = length;
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
    // Ensure at least one character type is selected
    if (!_includeUppercase && !_includeLowercase && !_includeNumbers && !_includeSymbols) {
      _includeLowercase = true; // Default to lowercase if nothing is selected
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

      // Remove excluded characters
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

      // Ensure at least one character from each selected type
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

      // Fill the rest of the password length
      while (password.length < _passwordLength) {
        password.write(characterSet[random.nextInt(characterSet.length)]);
      }

      // Shuffle the password to avoid predictable patterns
      final passwordList = password.toString().split('');
      passwordList.shuffle(random);
      
      _generatedPassword = passwordList.take(_passwordLength).join('');
      
      // Add to history if it's a valid password and different from the last one
      if (_generatedPassword.isNotEmpty && 
          _generatedPassword != 'Error generating password' &&
          (_passwordHistory.isEmpty || _passwordHistory.first.password != _generatedPassword)) {
        _addToHistory(_generatedPassword);
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
    }
  }

  // Calculate password strength
  int calculatePasswordStrength() {
    if (_generatedPassword.isEmpty || _generatedPassword.startsWith('Error')) {
      return 0;
    }

    int score = 0;
    
    // Length score (0-40 points)
    score += (_passwordLength * 2).clamp(0, 40);
    
    // Character variety score (0-40 points)
    int varieties = 0;
    if (_includeUppercase) varieties++;
    if (_includeLowercase) varieties++;
    if (_includeNumbers) varieties++;
    if (_includeSymbols) varieties++;
    
    score += (varieties * 10);
    
    // Bonus for longer passwords
    if (_passwordLength >= 12) score += 10;
    if (_passwordLength >= 16) score += 10;
    
    return score.clamp(0, 100);
  }

  String getPasswordStrengthLabel() {
    final strength = calculatePasswordStrength();
    if (strength >= 80) return 'Very Strong';
    if (strength >= 60) return 'Strong';
    if (strength >= 40) return 'Medium';
    if (strength >= 20) return 'Weak';
    return 'Very Weak';
  }

  Color getPasswordStrengthColor() {
    final strength = calculatePasswordStrength();
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  // Reset to default settings
  void resetToDefaults() {
    _passwordLength = 16;
    _includeUppercase = true;
    _includeLowercase = true;
    _includeNumbers = true;
    _includeSymbols = true;
    _excludeCharacters = '';
    generatePassword();
  }

  // Get character set preview
  String getCharacterSetPreview() {
    String preview = '';
    if (_includeUppercase) preview += 'ABC...';
    if (_includeLowercase) preview += (preview.isNotEmpty ? ', ' : '') + 'abc...';
    if (_includeNumbers) preview += (preview.isNotEmpty ? ', ' : '') + '123...';
    if (_includeSymbols) preview += (preview.isNotEmpty ? ', ' : '') + '!@#...';
    
    return preview.isEmpty ? 'No characters selected' : preview;
  }

  // Generate multiple passwords
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
  
  // Password History Methods
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
    
    // Remove duplicate if exists
    _passwordHistory.removeWhere((item) => item.password == password);
    
    // Add to beginning
    _passwordHistory.insert(0, historyItem);
    
    // Limit history size
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
