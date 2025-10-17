class Category {
  final String id;
  final String name;
  final String? color;
  final String? icon;
  final DateTime createdDate;

  const Category({
    required this.id,
    required this.name,
    required this.createdDate,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'],
      icon: map['icon'],
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    DateTime? createdDate,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
