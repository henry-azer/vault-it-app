class User {
  final String id;
  final String username;
  final String masterPassword;
  final bool isAuthenticated;
  final bool isOnboardingCompleted;
  final DateTime createdDate;

  const User({
    required this.id,
    required this.username,
    required this.masterPassword,
    required this.isAuthenticated,
    required this.isOnboardingCompleted,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'masterPassword': masterPassword,
      'isAuthenticated': isAuthenticated,
      'isOnboardingCompleted': isOnboardingCompleted,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      masterPassword: map['masterPassword'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      isOnboardingCompleted: map['isOnboardingCompleted'] ?? false,
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? masterPassword,
    bool? isAuthenticated,
    bool? isOnboardingCompleted,
    DateTime? createdDate,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      masterPassword: masterPassword ?? this.masterPassword,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
