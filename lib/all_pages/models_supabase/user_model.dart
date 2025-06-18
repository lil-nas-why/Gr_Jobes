import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_profession_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_skill_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/application_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/review_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/favorite_vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/job_search_status_model.dart';

class User {
  final String id;
  final String? supabase_user_id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime birthDate;
  final String gender;
  final int cityId;
  final String citizenship;
  final String email;
  final String phone;
  final String? avatarUrl;
  final int roleId;
  final bool isVerified;
  final JobSearchStatus? jobSearchStatus; // Changed from String to JobSearchStatus model

  final City city;
  final List<Resume> resumes;
  final List<UserProfession> professions;
  final List<UserSkill> skills;
  final List<Application> applications;
  final List<Review> reviews;
  final List<FavoriteVacancy> favorites;

  User({
    required this.id,
    required this.supabase_user_id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.birthDate,
    required this.gender,
    required this.cityId,
    required this.citizenship,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.roleId,
    required this.isVerified,
    this.jobSearchStatus,
    required this.city,
    required this.resumes,
    required this.professions,
    required this.skills,
    required this.applications,
    required this.reviews,
    required this.favorites,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      supabase_user_id: json['supabase_user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      middleName: json['middle_name']?.toString(),
      birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? '') ?? DateTime.now(),
      gender: json['gender']?.toString() ?? '',
      cityId: json['city_id'] is int ? json['city_id'] : 0,
      citizenship: json['citizenship']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      roleId: json['role_id'] is int ? json['role_id'] : 0,
      isVerified: json['is_verified'] is bool ? json['is_verified'] : false,
      jobSearchStatus: json['user_job_search_status'] is Map
          ? JobSearchStatus.fromJson(json['user_job_search_status']['status_id'])
          : null,
      city: json['city'] is Map ? City.fromJson(json['city']) : City.empty(),
      resumes: json['resumes'] is List
          ? (json['resumes'] as List).map((r) => Resume.fromJson(r)).toList()
          : [],
      professions: json['user_professions'] is List
          ? (json['user_professions'] as List)
          .map((p) => UserProfession.fromJson(p))
          .toList()
          : [],
      skills: json['user_skills'] is List
          ? (json['user_skills'] as List)
          .map((s) => UserSkill.fromJson(s))
          .toList()
          : [],
      applications: json['applications'] is List
          ? (json['applications'] as List).map((a) => Application.fromJson(a)).toList()
          : [],
      reviews: json['reviews'] is List
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : [],
      favorites: json['favorite_vacancies'] is List
          ? (json['favorite_vacancies'] as List)
          .map((f) => FavoriteVacancy.fromJson(f))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'supabase_user_id': supabase_user_id,
    'first_name': firstName,
    'last_name': lastName,
    'middle_name': middleName,
    'birth_date': birthDate.toIso8601String(),
    'gender': gender,
    'city_id': cityId,
    'citizenship': citizenship,
    'email': email,
    'phone': phone,
    'avatar_url': avatarUrl,
    'role_id': roleId,
    'is_verified': isVerified,
  };

  static User empty() {
    return User(
      id: '',
      supabase_user_id: '',
      firstName: 'Не указано',
      lastName: 'Не указано',
      birthDate: DateTime.now(),
      gender: 'Не указано',
      cityId: 0,
      citizenship: 'Не указано',
      email: '',
      phone: '',
      roleId: 0,
      isVerified: false,
      jobSearchStatus: null,
      city: City.empty(),
      resumes: [],
      professions: [],
      skills: [],
      applications: [],
      reviews: [],
      favorites: [],
    );
  }

  User copyWith({
    String? id,
    String? supabase_user_id,
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? birthDate,
    String? gender,
    int? cityId,
    String? citizenship,
    String? email,
    String? phone,
    String? avatarUrl,
    int? roleId,
    bool? isVerified,
    JobSearchStatus? jobSearchStatus,
    City? city,
    List<Resume>? resumes,
    List<UserProfession>? professions,
    List<UserSkill>? skills,
    List<Application>? applications,
    List<Review>? reviews,
    List<FavoriteVacancy>? favorites,
  }) {
    return User(
      id: id ?? this.id,
      supabase_user_id: supabase_user_id ?? this.supabase_user_id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      cityId: cityId ?? this.cityId,
      citizenship: citizenship ?? this.citizenship,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleId: roleId ?? this.roleId,
      isVerified: isVerified ?? this.isVerified,
      jobSearchStatus: jobSearchStatus ?? this.jobSearchStatus,
      city: city ?? this.city,
      resumes: resumes ?? this.resumes,
      professions: professions ?? this.professions,
      skills: skills ?? this.skills,
      applications: applications ?? this.applications,
      reviews: reviews ?? this.reviews,
      favorites: favorites ?? this.favorites,
    );
  }
}