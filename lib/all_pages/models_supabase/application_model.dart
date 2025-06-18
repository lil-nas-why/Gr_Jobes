import 'package:gr_jobs/all_pages/models_supabase/agency_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/employment_type_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';

// application_model.dart
class Application {
  final String id;
  final String seekerId;
  final String vacancyId;
  final String resumeId;
  final String status;
  final String? coverLetter;
  final bool viewedByEmployer;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Vacancy vacancy;

  Application({
    required this.id,
    required this.seekerId,
    required this.vacancyId,
    required this.resumeId,
    this.status = 'pending',
    this.coverLetter,
    this.viewedByEmployer = false,
    required this.createdAt,
    required this.updatedAt,

    required this.vacancy,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    // Парсим основную информацию о заявке
    final id = json['id']?.toString() ?? '';
    final seekerId = json['seeker_id']?.toString() ?? '';
    final vacancyId = json['vacancy_id']?.toString() ?? '';
    final resumeId = json['resume_id']?.toString() ?? '';
    final status = json['status']?.toString() ?? 'pending';
    final coverLetter = json['cover_letter']?.toString();
    final viewedByEmployer = json['viewed_by_employer'] as bool? ?? false;

    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now();
    final updatedAt = DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now();

    // Парсим вакансию
    Vacancy vacancy;
    try {
      final vacancyJson = json['vacancy'] is Map ? json['vacancy'] : {};

      vacancy = Vacancy(
        id: vacancyJson['id']?.toString() ?? '',
        title: vacancyJson['title']?.toString() ?? 'Без названия',
        agencyId: _parseInt(vacancyJson['agency_id']),
        minSalary: _parseInt(vacancyJson['salary_from']),
        maxSalary: _parseInt(vacancyJson['salary_to']),
        experienceId: _parseInt(vacancyJson['experience_id']),
        paymentFrequency: vacancyJson['payment_frequency']?.toString(),
        locationCityId: _parseInt(vacancyJson['location_city_id']),
        description: vacancyJson['description']?.toString() ?? '',
        address: vacancyJson['address']?.toString() ?? '',
        latitude: _parseDouble(vacancyJson['latitude']),
        longitude: _parseDouble(vacancyJson['longitude']),
        views: _parseInt(vacancyJson['views']) ?? 0,
        isActive: vacancyJson['is_active'] as bool? ?? true,
        publishedAt: DateTime.tryParse(vacancyJson['created_at']?.toString() ?? '') ?? DateTime.now(),
        agency: vacancyJson['agency'] is Map ? Agency.fromJson(vacancyJson['agency']) : null,
        employmentType: vacancyJson['employment_type'] is Map
            ? EmploymentType.fromJson(vacancyJson['employment_type'])
            : null,
        workFormat: vacancyJson['work_format'] is Map
            ? WorkFormat.fromJson(vacancyJson['work_format'])
            : null,
        locationCity: vacancyJson['location_city'] is Map
            ? City.fromJson(vacancyJson['location_city'])
            : null,
        skills: [],
        skillMatchPercentage: 0,
        isFavorite: false,
      );
    } catch (e, stack) {
      print('Error parsing vacancy: $e\n$stack');
      vacancy = Vacancy.empty();
    }

    return Application(
      id: id,
      seekerId: seekerId,
      vacancyId: vacancyId,
      resumeId: resumeId,
      status: status,
      coverLetter: coverLetter,
      viewedByEmployer: viewedByEmployer,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vacancy: vacancy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seeker_id': seekerId,
      'vacancy_id': vacancyId,
      'resume_id': resumeId,
      'status': status,
      'cover_letter': coverLetter,
      'viewed_by_employer': viewedByEmployer,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'vacancy': vacancy.toJson(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}