import 'package:gr_jobs/all_pages/models_supabase/agency_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/employment_type_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/skill_model.dart';

class Vacancy {
  final String id;
  final String title;
  final int? agencyId;
  final int? minSalary;
  final int? maxSalary;
  final int? experienceId;
  final String? paymentFrequency;
  final int? locationCityId;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final int views;
  final bool isActive;
  final DateTime publishedAt;

  final Agency? agency;
  final EmploymentType? employmentType;
  final WorkFormat? workFormat;
  final City? locationCity;
  final List<Skill> skills;

  final int skillMatchPercentage;
  bool isFavorite;


  // Геттеры для удобного доступа
  String get agencyName => agency?.name ?? 'Не указано';
  String get cityName => locationCity?.name ?? 'Не указано';
  String get employmentTypeName => employmentType?.typeName ?? 'Не указано';
  String get workFormatName => workFormat?.formatName ?? 'Не указано';
  double get rating => agency?.rating ?? 0.0;
  int get reviewCount => agency?.reviewCount ?? 0;
  String get experienceName => getExperienceName(experienceId ?? 0);

  Vacancy({
    required this.id,
    required this.title,
    this.agencyId,
    this.minSalary,
    this.maxSalary,
    this.experienceId,
    this.paymentFrequency,
    this.locationCityId,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.views = 0,
    this.isActive = true,
    required this.publishedAt,
    this.agency,
    this.employmentType,
    this.workFormat,
    this.locationCity,
    this.skills = const [],
    this.skillMatchPercentage = 0,
    this.isFavorite = false,
  });

  factory Vacancy.fromJson(Map<String, dynamic> json) {
    try {
      return Vacancy(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Без названия',
        agencyId: _parseInt(json['agency_id']),
        minSalary: _parseInt(json['salary_from']),
        maxSalary: _parseInt(json['salary_to']),
        experienceId: _parseInt(json['experience_id']),
        paymentFrequency: json['payment_frequency']?.toString(),
        locationCityId: _parseInt(json['location_city_id']),
        description: json['description']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: _parseDouble(json['latitude']),
        longitude: _parseDouble(json['longitude']),
        views: _parseInt(json['views']) ?? 0,
        isActive: json['is_active'] is bool ? json['is_active'] : true,
        publishedAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        agency: json['agencies'] is Map ? Agency.fromJson(json['agencies']) : null,
        employmentType: json['employment_types'] is Map ? EmploymentType.fromJson(json['employment_types']) : null,
        workFormat: json['work_formats'] is Map ? WorkFormat.fromJson(json['work_formats']) : null,
        locationCity: json['cities'] is Map ? City.fromJson(json['cities']) : null,
        skills: _parseSkills(json),
        skillMatchPercentage: _parseInt(json['skill_match_percentage']) ?? 0,
        isFavorite: json['is_favorite'] ?? false,
      );
    } catch (e, stack) {
      print('Ошибка при парсинге вакансии: $e\n$stack');
      return Vacancy.empty();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return null;
  }

  static List<Skill> _parseSkills(Map<String, dynamic> json) {
    final List<Skill> skills = [];
    try {
      final List<dynamic>? vacancySkills = json['vacancy_skills'] is List ? json['vacancy_skills'] : null;
      final List<dynamic>? allSkills = json['skills'] is List ? json['skills'] : null;

      if (vacancySkills != null && allSkills != null) {
        for (final vs in vacancySkills) {
          final skillId = vs['skill_id'] is int ? vs['skill_id'] as int : null;
          if (skillId != null) {
            final skillJson = allSkills.firstWhere(
                  (s) => s['id'] == skillId,
              orElse: () => null,
            );
            if (skillJson != null) {
              skills.add(Skill.fromJson(skillJson));
            }
          }
        }
      }
    } catch (e) {
      print('Ошибка при парсинге навыков: $e');
    }
    return skills;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'agency_id': agencyId,
      'salary_from': minSalary,
      'salary_to': maxSalary,
      'experience_id': experienceId,
      'payment_frequency': paymentFrequency,
      'location_city_id': locationCityId,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'views': views,
      'is_active': isActive,
      'created_at': publishedAt.toIso8601String(),
      'agencies': agency?.toJson(),
      'employment_types': employmentType?.toJson(),
      'work_formats': workFormat?.toJson(),
      'cities': locationCity?.toJson(),
      'skills': skills.map((s) => s.toJson()).toList(),
      'skill_match_percentage': skillMatchPercentage,
      'is_favorite': isFavorite,
    };
  }

  Vacancy copyWith({bool? isFavorite}) {
    return Vacancy(
      id: id,
      title: title,
      agencyId: agencyId,
      minSalary: minSalary,
      maxSalary: maxSalary,
      experienceId: experienceId,
      paymentFrequency: paymentFrequency,
      locationCityId: locationCityId,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      views: views,
      isActive: isActive,
      publishedAt: publishedAt,
      agency: agency,
      employmentType: employmentType,
      workFormat: workFormat,
      locationCity: locationCity,
      skills: skills,
      skillMatchPercentage: skillMatchPercentage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String getExperienceName(int experienceId) {
    switch (experienceId) {
      case 1: return 'Без опыта';
      case 2: return '1-3 года';
      case 3: return '3-6 лет';
      case 4: return 'Более 6 лет';
      default: return 'Не указано';
    }
  }

  static Vacancy empty() {
    return Vacancy(
      id: '',
      title: 'Не указано',
      description: '',
      address: '',
      publishedAt: DateTime.now(),
      agency: Agency.empty(),
      employmentType: EmploymentType.empty(),
      workFormat: WorkFormat.empty(),
      locationCity: City.empty(),
      skills: [],
    );
  }
}