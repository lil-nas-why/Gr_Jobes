import 'package:gr_jobs/all_pages/models_supabase/education_institution_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/education_level_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';

class UserEducation {
  final int id;
  final String userId;
  final int institutionId;
  final int levelId;
  final String faculty;
  final int startYear;
  final int endYear;
  final bool isCurrent;
  final DateTime createdAt;

  final User user;
  final EducationalInstitution institution;
  final EducationLevel educationLevel;

  UserEducation({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.levelId,
    required this.faculty,
    required this.startYear,
    required this.endYear,
    required this.isCurrent,
    required this.createdAt,
    required this.user,
    required this.institution,
    required this.educationLevel,
  });

  factory UserEducation.fromJson(Map<String, dynamic> json) {
    return UserEducation(
      id: json['id'],
      userId: json['user_id'],
      institutionId: json['institution_id'],
      levelId: json['level_id'],
      faculty: json['faculty'],
      startYear: json['start_year'],
      endYear: json['end_year'],
      isCurrent: json['is_current'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      institution: EducationalInstitution.fromJson(json['institution']),
      educationLevel: EducationLevel.fromJson(json['education_level']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'institution_id': institutionId,
    'level_id': levelId,
    'faculty': faculty,
    'start_year': startYear,
    'end_year': endYear,
    'is_current': isCurrent,
    'created_at': createdAt.toIso8601String(),
  };
}