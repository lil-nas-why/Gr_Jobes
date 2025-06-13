import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';

class Skill {
  final int id;
  final int categoryId;
  final String name;
  final int importanceLevel;
  final DateTime createdAt;

  final Profession category;

  Skill({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.importanceLevel,
    required this.createdAt,
    required this.category,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    try {
      return Skill(
        id: json['id'] is int ? json['id'] : 0,
        categoryId: json['category_id'] is int ? json['category_id'] : 0,
        name: json['name']?.toString() ?? 'Не указано',
        importanceLevel: json['importance_level'] is int ? json['importance_level'] : 0,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        category: json['category'] is Map<String, dynamic>
            ? Profession.fromJson(json['category'])
            : Profession.empty(),
      );
    } catch (e, stack) {
      print('Ошибка парсинга Skill: $e\n$stack');
      return Skill.empty();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'importance_level': importanceLevel,
    'created_at': createdAt.toIso8601String(),
    'category': category.toJson(),
  };

  static Skill empty() {
    return Skill(
      id: 0,
      categoryId: 0,
      name: 'Не указано',
      importanceLevel: 0,
      createdAt: DateTime.now(),
      category: Profession.empty(),
    );
  }
}