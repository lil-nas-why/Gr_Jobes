import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/weeklyStats.dart';

class Resume {
  final String id;
  final String userId; // Переименовано из seekerId для согласованности с БД
  final int professionId;
  final int salaryExpectation;
  final int experienceYears;
  final String about;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? autoRaiseDate;
  final WeeklyStats weeklyStats;
  final String recommendation;
  final String title;
  final Profession profession;

  Resume({
    required this.id,
    required this.userId,
    required this.professionId,
    required this.salaryExpectation,
    required this.experienceYears,
    required this.about,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.profession,
    required this.title,
    this.autoRaiseDate,
    required this.weeklyStats,
    required this.recommendation,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    try {
      return Resume(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        professionId: json['profession_id'] is int ? json['profession_id'] : 0,
        salaryExpectation: (json['salary_expectation'] as num?)?.toInt() ?? 0,
        experienceYears: json['experience_years'] is int ? json['experience_years'] : 0,
        about: json['about']?.toString() ?? '',
        isPublished: json['is_published'] is bool ? json['is_published'] : false,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
        profession: json['profession'] is Map<String, dynamic>
            ? Profession.fromJson(json['profession'])
            : Profession.empty(),
        title: json['title']?.toString() ?? 'Без названия',
        weeklyStats: json['weekly_stats'] is Map<String, dynamic>
            ? WeeklyStats.fromJson(json['weekly_stats'])
            : WeeklyStats.empty(),
        recommendation: json['recommendation']?.toString() ?? '',
      );
    } catch (e, stack) {
      print('Ошибка парсинга резюме: $e\n$stack');
      return Resume.empty();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'profession_id': professionId,
    'salary_expectation': salaryExpectation,
    'experience_years': experienceYears,
    'about': about,
    'is_published': isPublished,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'title': title,
    if (autoRaiseDate != null) 'auto_raise_date': autoRaiseDate!.toIso8601String(),
    'weekly_stats': weeklyStats.toJson(),
    'recommendation': recommendation,
    'profession': profession.toJson(),
  };

  static Resume empty() {
    return Resume(
      id: '',
      userId: '',
      professionId: 0,
      salaryExpectation: 0,
      experienceYears: 0,
      about: '',
      isPublished: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profession: Profession.empty(),
      title: 'Без названия',
      weeklyStats: WeeklyStats.empty(),
      recommendation: '',
    );
  }
}