import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_schedule_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/experience_option_model.dart';

class VacancyService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Vacancy>> fetchVacancies() async {
    try {

      print('[DEBUG] Начинаем загрузку всех вакансий');

      final response = await _client
          .from('job_vacancies')
          .select('''*,
            agencies(*),
            employment_types(*),
            work_formats(*),
            cities(*, regions(*)),
            vacancy_skills(skill_id)''');

      print('[DEBUG] Ответ от базы данных: $response');

      if (response == null || response.isEmpty) return [];

      return (response as List).map((json) {
        try {
          return Vacancy.fromJson(json);
        } catch (e) {
          print('Ошибка при парсинге вакансии: $e\n${json.toString()}');
          return Vacancy.empty();
        }
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