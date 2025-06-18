import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/application_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/experience_option_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_schedule_model.dart';

import 'package:gr_jobs/all_pages/service/vacancy_service.dart';

class VacancyProvider with ChangeNotifier {
  List<Vacancy> _vacancies = [];
  List<Vacancy> _favoriteVacancies = [];
  bool _isLoading = false;
  String? _error;

  // Поля для фильтров
  List<ExperienceOption> _experienceOptions = [];
  List<WorkFormat> _workFormats = [];
  List<WorkSchedule> _workSchedules = [];
  List<City> _cities = [];

  List<Vacancy> get vacancies => _vacancies;
  List<Vacancy> get favoriteVacancies => _favoriteVacancies;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Геттеры для данных фильтров
  List<ExperienceOption> get experienceOptions => _experienceOptions;
  List<WorkFormat> get workFormats => _workFormats;
  List<WorkSchedule> get workSchedules => _workSchedules;
  List<City> get cities => _cities;

  //Для откликов
  List<Application> _userApplications = [];
  List<Application> get userApplications => _userApplications;

  Future<void> loadCities() async {
    if (_cities.isNotEmpty) return;

    try {
      final response = await supabase.Supabase.instance.client
          .from('cities')
          .select('*, regions(*)')
          .order('name', ascending: true);

      _cities = (response as List)
          .map((json) => City.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading cities: $e');
    }
  }

  Future<void> loadVacancies({String? currentUserId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final service = VacancyService();
      final List<Vacancy> vacancies = await service.fetchVacancies();

      if (currentUserId != null && currentUserId.isNotEmpty) {
        final favoriteIds = await _fetchFavoriteVacancyIds(currentUserId);
        print('[DEBUG] Loaded favorite IDs: $favoriteIds');

        _vacancies = vacancies.map((v) {
          final isFavorite = favoriteIds.contains(v.id);
          print('Vacancy ${v.id} isFavorite: $isFavorite');
          return v.copyWith(isFavorite: isFavorite);
        }).toList();

        // Обновляем список избранных вакансий
        _favoriteVacancies = _vacancies.where((v) => v.isFavorite).toList();
      } else {
        _vacancies = vacancies.map((v) => v.copyWith(isFavorite: false)).toList();
        _favoriteVacancies = [];
      }

      print('[DEBUG] Вакансии загружены: ${_vacancies.length} шт.');
    } catch (e, stackTrace) {
      print('Ошибка при загрузке вакансий: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFilterData() async {

    try {
      final service = VacancyService();

      // Загружаем данные для фильтров
      final results = await Future.wait([
        service.fetchExperienceOptions(),
        service.fetchWorkFormats(),
        service.fetchWorkSchedules(),
        service.fetchCities(),
      ]);

      _experienceOptions = results[0] as List<ExperienceOption>;
      _workFormats = results[1] as List<WorkFormat>;
      _workSchedules = results[2] as List<WorkSchedule>;
      _cities = results[3] as List<City>;

      notifyListeners();
    } catch (e) {
      print('Ошибка при загрузке данных фильтров: $e');
    }
  }

  Future<List<String>> _fetchFavoriteVacancyIds(String userId) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('favorite_vacancies')
          .select('vacancy_id')
          .eq('seeker_id', userId);

      if (response == null || response.isEmpty) return [];

      // Явное приведение типов
      return (response as List<dynamic>)
          .map((json) => json['vacancy_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error fetching favorite ids: $e');
      return [];
    }
  }

  Future<void> fetchFavoriteVacancies(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase.Supabase.instance.client
          .from('favorite_vacancies')
          .select('vacancy_id(*)')
          .eq('seeker_id', userId);

      if (response != null && response.isNotEmpty) {
        _favoriteVacancies = (response as List)
            .map((json) => Vacancy.fromJson(json['vacancy_id']))
            .toList();
      } else {
        _favoriteVacancies = [];
      }
    } catch (e) {
      _error = 'Ошибка при получении избранных вакансий: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unfavoriteVacancy(String userId, String vacancyId) async {
    try {
      await supabase.Supabase.instance.client
          .from('favorite_vacancies')
          .delete()
          .eq('vacancy_id', vacancyId)
          .eq('seeker_id', userId);

      // Remove from local list
      _favoriteVacancies.removeWhere((vacancy) => vacancy.id == vacancyId);
      notifyListeners();
    } catch (e) {
      print('Ошибка при удалении из избранного: $e');
    }
  }

  List<Vacancy> getFilteredVacancies(Map<String, dynamic> filters) {
    List<Vacancy> result = _vacancies;



    if (filters['searchQuery'] != null && filters['searchQuery'].isNotEmpty) {
      final query = filters['searchQuery'].toLowerCase().split(' ');
      result = result.where((v) {
        final titleWords = v.title.toLowerCase().split(' ');
        return query.any((q) => titleWords.any((word) => word.contains(q)));
      }).toList();
    }

    if (filters['salaryFrom'] != null) {
      result = result.where((v) =>
      v.minSalary != null && v.minSalary! >= filters['salaryFrom']
      ).toList();
    }

    if (filters['experienceLevel'] != null) {
      result = result.where((v) =>
      v.experienceId != null &&
          v.getExperienceName(v.experienceId!) == filters['experienceLevel']
      ).toList();
    }

    if (filters['employmentTypes'] != null && filters['employmentTypes'].isNotEmpty) {
      result = result.where((v) =>
      v.employmentType != null &&
          filters['employmentTypes'].contains(v.employmentType!.typeName)
      ).toList();
    }

    if (filters['workFormats'] != null && filters['workFormats'].isNotEmpty) {
      result = result.where((v) =>
      v.workFormat != null &&
          filters['workFormats'].contains(v.workFormat!.formatName)
      ).toList();
    }

    if (filters['workSchedules'] != null && filters['workSchedules'].isNotEmpty) {
      result = result.where((v) =>
      v.workFormat != null &&
          filters['workSchedules'].contains(v.workFormat!.formatName)
      ).toList();
    }

    if (filters['location'] != null && filters['location'] != 'Все города') {
      result = result.where((v) =>
      v.locationCity != null &&
          '${v.locationCity!.name} (${v.locationCity!.region?.name ?? ''})'
              .toLowerCase()
              .contains(filters['location'].toLowerCase().replaceAll(' (все города)', ''))
      ).toList();
    }

    return result;
  }



  Future<void> toggleFavoriteVacancy(
      String userId, String vacancyId, bool isCurrentlyFavorite) async {
    try {
      final client = supabase.Supabase.instance.client;

      if (isCurrentlyFavorite) {
        // Удаление
        await client
            .from('favorite_vacancies')
            .delete()
            .eq('seeker_id', userId)
            .eq('vacancy_id', vacancyId);
      } else {
        // Проверяем, нет ли уже такой записи
        final existing = await client
            .from('favorite_vacancies')
            .select()
            .eq('seeker_id', userId)
            .eq('vacancy_id', vacancyId)
            .maybeSingle();

        if (existing == null) {
          await client
              .from('favorite_vacancies')
              .insert({'seeker_id': userId, 'vacancy_id': vacancyId});
        } else {
          print('Запись уже существует');
          return;
        }
      }

      // Обновляем UI
      final index = _vacancies.indexWhere((v) => v.id == vacancyId);
      if (index != -1) {
        _vacancies[index] = _vacancies[index].copyWith(isFavorite: !isCurrentlyFavorite);
        notifyListeners();
      }

    } catch (e) {
      print('Ошибка при обновлении избранного: $e');
      rethrow;
    }
  }

  Future<bool> hasUserApplied(String userId, String vacancyId) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('applications')
          .select()
          .eq('seeker_id', userId)
          .eq('vacancy_id', vacancyId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking application: $e');
      return false;
    }
  }

  Future<void> fetchUserApplications(String userId, {bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    try {
      final response = await supabase.Supabase.instance.client
          .from('applications')
          .select('''
          *,
          vacancy:vacancy_id(
            *,
            agency:agencies(*),
            employment_type:employment_types(*),
            work_format:work_formats(*),
            location_city:cities(*, regions(*))
          ),
          resume:resume_id(*)
        ''')
          .eq('seeker_id', userId)
          .order('created_at', ascending: false);

      final applications = (response as List)
          .map((json) {
        try {
          return Application.fromJson(json);
        } catch (e, stack) {
          print('Error parsing application: $e\n$stack');
          return null;
        }
      })
          .where((app) => app != null && app.vacancy.id.isNotEmpty)
          .cast<Application>()
          .toList();

      // Обновляем состояние только если список изменился
      if (!listEquals(_userApplications, applications)) {
        _userApplications = applications;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Ошибка при загрузке откликов: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> withdrawApplication(String userId, String applicationId) async {
    try {
      await supabase.Supabase.instance.client
          .from('applications')
          .delete()
          .eq('id', applicationId)
          .eq('seeker_id', userId);

      _userApplications.removeWhere((app) => app.id == applicationId);
      notifyListeners();
    } catch (e) {
      print('Ошибка при отзыве отклика: $e');
      rethrow;
    }
  }
}