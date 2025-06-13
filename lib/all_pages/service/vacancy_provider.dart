import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/experience_option_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_schedule_model.dart';

import 'package:gr_jobs/all_pages/service/vacancy_service.dart';

class VacancyProvider with ChangeNotifier {
  List<Vacancy> _vacancies = [];
  bool _isLoading = false;

  // Поля для фильтров
  List<ExperienceOption> _experienceOptions = [];
  List<WorkFormat> _workFormats = [];
  List<WorkSchedule> _workSchedules = [];
  List<City> _cities = [];

  List<Vacancy> get vacancies => _vacancies;
  bool get isLoading => _isLoading;

  // Геттеры для данных фильтров
  List<ExperienceOption> get experienceOptions => _experienceOptions;
  List<WorkFormat> get workFormats => _workFormats;
  List<WorkSchedule> get workSchedules => _workSchedules;
  List<City> get cities => _cities;


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
      } else {
        _vacancies = vacancies.map((v) => v.copyWith(isFavorite: false)).toList();
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
}