import 'package:gr_jobs/all_pages/models_supabase/agency_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/employment_type_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_schedule_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/experience_option_model.dart';

class VacancyService {
  final SupabaseClient _client = Supabase.instance.client;

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

  Future<List<Vacancy>> fetchVacancies() async {
    try {
      print('[DEBUG] Начинаем загрузку вакансий с расширенными данными');

      final response = await _client
          .from('job_vacancies')
          .select('''
          id, 
          title, 
          salary_from, 
          salary_to, 
          experience_id, 
          description,
          address,
          latitude,
          longitude,
          is_active,
          created_at,
          agencies(id, name, rating, review_count),
          employment_types(id, type_name),
          work_formats(id, format_name),
          cities(id, name, regions(name)),
          favorite_vacancies(vacancy_id)
        ''');

      print('[DEBUG] Расширенный ответ от базы данных: $response');

      if (response == null || response.isEmpty) return [];

      return (response as List).map((json) {
        return Vacancy(
          id: json['id']?.toString() ?? '',
          title: json['title']?.toString() ?? 'Без названия',
          minSalary: _parseInt(json['salary_from']),
          maxSalary: _parseInt(json['salary_to']),
          experienceId: _parseInt(json['experience_id']),
          description: json['description']?.toString() ?? '',
          address: json['address']?.toString() ?? '',
          latitude: _parseDouble(json['latitude']),
          longitude: _parseDouble(json['longitude']),
          isActive: json['is_active'] is bool ? json['is_active'] : true,
          publishedAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
          agency: json['agencies'] is Map ? Agency.fromJson(json['agencies']) : null,
          employmentType: json['employment_types'] is Map ? EmploymentType.fromJson(json['employment_types']) : null,
          workFormat: json['work_formats'] is Map ? WorkFormat.fromJson(json['work_formats']) : null,
          locationCity: json['cities'] is Map ? City.fromJson(json['cities']) : null,
          isFavorite: json['favorite_vacancies'] != null && (json['favorite_vacancies'] as List).isNotEmpty,
        );
      }).where((v) => v.id.isNotEmpty).toList();
    } catch (e) {
      print('Ошибка при загрузке вакансий: $e');
      rethrow;
    }
  }

  // Новые методы для загрузки данных фильтров
  Future<List<ExperienceOption>> fetchExperienceOptions() async {
    try {
      final response = await _client.from('experience_options').select();
      return (response as List).map((e) => ExperienceOption.fromJson(e)).toList();
    } catch (e) {
      print('Ошибка при загрузке опций опыта: $e');
      return [];
    }
  }

  Future<List<WorkFormat>> fetchWorkFormats() async {
    try {
      final response = await _client.from('work_formats').select();
      return (response as List).map((e) => WorkFormat.fromJson(e)).toList();
    } catch (e) {
      print('Ошибка при загрузке форматов работы: $e');
      return [];
    }
  }

  Future<List<WorkSchedule>> fetchWorkSchedules() async {
    try {
      final response = await _client.from('work_schedules').select();
      return (response as List).map((e) => WorkSchedule.fromJson(e)).toList();
    } catch (e) {
      print('Ошибка при загрузке графиков работы: $e');
      return [];
    }
  }

  Future<List<City>> fetchCities() async {
    try {
      final response = await _client.from('cities').select('*, regions(*)');
      return (response as List).map((e) => City.fromJson(e)).toList();
    } catch (e) {
      print('Ошибка при загрузке городов: $e');
      return [];
    }
  }
}