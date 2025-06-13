class Profession {
  final int id;
  final int? parentId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final Profession? parent;

  Profession({
    required this.id,
    this.parentId,
    required this.name,
    this.description,
    required this.createdAt,
    this.parent,
  });

  factory Profession.fromJson(Map<String, dynamic> json) {
    return Profession(
      id: json['id'] is int ? json['id'] : 0,
      parentId: json['parent_id'] is int ? json['parent_id'] : null,
      name: json['name']?.toString() ?? 'Не указано',
      description: json['description']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      parent: json['parent'] is Map<String, dynamic> ? Profession.fromJson(json['parent']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (parentId != null) 'parent_id': parentId,
    'name': name,
    if (description != null) 'description': description,
    'created_at': createdAt.toIso8601String(),
    if (parent != null) 'parent': parent?.toJson(),
  };

  static Profession empty() {
    return Profession(
      id: 0,
      name: 'Не указано',
      createdAt: DateTime.now(),
    );
  }
}