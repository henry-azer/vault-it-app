class Category {
  final String id;
  final String name;
  final String? color;
  final String? icon;
  final DateTime createdDate;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.createdDate,
    this.color,
    this.icon,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'createdDate': createdDate.toIso8601String(),
      'sortOrder': sortOrder,
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
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    DateTime? createdDate,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdDate: createdDate ?? this.createdDate,
      sortOrder: sortOrder ?? this.sortOrder,
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
