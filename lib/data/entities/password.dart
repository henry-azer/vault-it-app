import 'package:intl/intl.dart';

class Password {
  final String id;
  final String title;
  final String? url;
  final String username;
  final String password;
  final String? notes;
  final DateTime addedDate;

  const Password({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.addedDate,
    this.url,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'username': username,
      'password': password,
      'notes': notes,
      'addeddate': DateFormat.yMd().format(addedDate).toString(),
    };
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      notes: map['notes'],
      addedDate: DateFormat.yMd().parse(map['addeddate']),
    );
  }

  Password copyWith({
    String? id,
    String? title,
    String? url,
    String? username,
    String? password,
    String? notes,
    DateTime? addedDate,
  }) {
    return Password(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
