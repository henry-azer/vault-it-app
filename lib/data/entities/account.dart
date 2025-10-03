import 'package:intl/intl.dart';

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
  }) : lastModified = lastModified ?? addedDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'username': username,
      'password': password,
      'notes': notes,
      'addedDate': DateFormat.yMd().format(addedDate).toString(),
      'lastModified': DateFormat.yMd().format(lastModified).toString(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    final addedDate = DateFormat.yMd().parse(map['addedDate']);
    return Account(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'],
      addedDate: addedDate,
      lastModified: map['lastModified'] != null 
          ? DateFormat.yMd().parse(map['lastModified'])
          : addedDate,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
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
    );
  }
}
