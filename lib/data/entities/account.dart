import 'dart:convert';
import 'package:intl/intl.dart';

class PasswordHistoryItem {
  final String password;
  final DateTime changedDate;

  const PasswordHistoryItem({
    required this.password,
    required this.changedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'changedDate': changedDate.toIso8601String(),
    };
  }

  factory PasswordHistoryItem.fromMap(Map<String, dynamic> map) {
    return PasswordHistoryItem(
      password: map['password'] ?? '',
      changedDate: DateTime.parse(map['changedDate']),
    );
  }
}

class Account {
  final String id;
  final String title;
  final String? url;
  final String username;
  final String password;
  final String? notes;
  final DateTime addedDate;
  final DateTime lastModified;
  final bool isFavorite;
  final List<PasswordHistoryItem> passwordHistory;

  const Account({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.addedDate,
    DateTime? lastModified,
    this.url,
    this.notes,
    this.isFavorite = false,
    this.passwordHistory = const [],
  }) : lastModified = lastModified ?? addedDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'username': username,
      'password': password,
      'notes': notes,
      'addedDate': addedDate.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'passwordHistory': jsonEncode(passwordHistory.map((e) => e.toMap()).toList()),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String dateStr) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        try {
          return DateFormat.yMd().parse(dateStr);
        } catch (e) {
          return DateTime.now();
        }
      }
    }
    
    final addedDate = parseDate(map['addedDate']);
    
    List<PasswordHistoryItem> history = [];
    if (map['passwordHistory'] != null && map['passwordHistory'].toString().isNotEmpty) {
      try {
        final List<dynamic> historyJson = jsonDecode(map['passwordHistory']);
        history = historyJson.map((e) => PasswordHistoryItem.fromMap(e)).toList();
      } catch (e) {
        history = [];
      }
    }
    
    return Account(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'],
      addedDate: addedDate,
      lastModified: map['lastModified'] != null 
          ? parseDate(map['lastModified'])
          : addedDate,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      passwordHistory: history,
    );
  }

  Account copyWith({
    String? id,
    String? title,
    String? url,
    String? username,
    String? password,
    String? notes,
    DateTime? addedDate,
    DateTime? lastModified,
    bool? isFavorite,
    List<PasswordHistoryItem>? passwordHistory,
  }) {
    return Account(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      addedDate: addedDate ?? this.addedDate,
      lastModified: lastModified ?? this.lastModified,
      isFavorite: isFavorite ?? this.isFavorite,
      passwordHistory: passwordHistory ?? this.passwordHistory,
    );
  }
}
