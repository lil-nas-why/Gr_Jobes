import 'package:gr_jobs/all_pages/models_supabase/skill_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';

class UserSkill {
  final String id;
  final String userId;
  final int skillId;
  final int importanceLevel;
  final DateTime createdAt;

  final User user;
  final Skill skill;

  UserSkill({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.importanceLevel,
    required this.createdAt,
    required this.user,
    required this.skill,
  });

  factory UserSkill.fromJson(Map<String, dynamic> json) {
    try {
      return UserSkill(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        skillId: json['skill_id'] is int ? json['skill_id'] : 0,
        importanceLevel: json['importance_level'] is int ? json['importance_level'] : 0,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        user: json['user'] is Map<String, dynamic> ? User.fromJson(json['user']) : User.empty(),
        skill: json['skill'] is Map<String, dynamic> ? Skill.fromJson(json['skill']) : Skill.empty(),
      );
    } catch (e, stack) {
      print('Ошибка парсинга UserSkill: $e\n$stack');
      return UserSkill.empty();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'skill_id': skillId,
    'importance_level': importanceLevel,
    'created_at': createdAt.toIso8601String(),
    'user': user.toJson(),
    'skill': skill.toJson(),
  };

  static UserSkill empty() {
    return UserSkill(
      id: '',
      userId: '',
      skillId: 0,
      importanceLevel: 0,
      createdAt: DateTime.now(),
      user: User.empty(),
      skill: Skill.empty(),
    );
  }
}