import 'package:gr_jobs/all_pages/models_supabase/experience_option_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';

class UserExperience {
  final String id;
  final String userId;
  final int experienceOptionId;
  final String position;
  final String company;
  final int startYear;
  final int? endYear;
  final String description;
  final bool isCurrent;
  final DateTime createdAt;

  final User user;
  final ExperienceOption experienceOption;

  UserExperience({
    required this.id,
    required this.userId,
    required this.experienceOptionId,
    required this.position,
    required this.company,
    required this.startYear,
    this.endYear,
    required this.description,
    required this.isCurrent,
    required this.createdAt,
    required this.user,
    required this.experienceOption,
  });

  factory UserExperience.fromJson(Map<String, dynamic> json) {
    return UserExperience(
      id: json['id'],
      userId: json['user_id'],
      experienceOptionId: json['experience_option_id'],
      position: json['position'],
      company: json['company'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      description: json['description'],
      isCurrent: json['is_current'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      experienceOption: ExperienceOption.fromJson(json['experience_option']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'experience_option_id': experienceOptionId,
    'position': position,
    'company': company,
    'start_year': startYear,
    'end_year': endYear,
    'description': description,
    'is_current': isCurrent,
    'created_at': createdAt.toIso8601String(),
  };
}