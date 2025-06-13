import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_page.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/guest_vacancy_page.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import '../../features/vacancy/pages/filtered_vacancies_page.dart';
import '../../models_supabase/vacancy_model.dart';
import '../../service/vacancy_provider.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isAuthenticated = false;
  String? _searchTerm;
  List<Vacancy>? _filteredVacancies;
  Map<String, dynamic>? _filters;

  int get currentIndex => _currentIndex;
  bool get isAuthenticated => _isAuthenticated;
  String? get searchTerm => _searchTerm;
  List<Vacancy>? get filteredVacancies => _filteredVacancies;
  Map<String, dynamic>? get filters => _filters;

  void initializePages(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _searchTerm = null;
    _filteredVacancies = null;
    _filters = null;
    notifyListeners();
  }

  void setSearchTerm(String term, BuildContext context) {
    final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);
    _searchTerm = term;
    _filters = {'searchQuery': term};
    _filteredVacancies = vacancyProvider.getFilteredVacancies(_filters!);
    notifyListeners();
  }

  void pushFilteredVacanciesPage(
      Map<String, dynamic> filters,
      BuildContext context,
      VacancyProvider vacancyProvider,
      )
  {
    _filters = filters;
    _filteredVacancies = vacancyProvider.getFilteredVacancies(filters);
    _searchTerm = filters['searchQuery'];
    notifyListeners();

    // Просто закрываем модальное окно и обновляем состояние
    Navigator.pop(context);
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void clearFilters() {
    _searchTerm = null;
    _filters = null;
    _filteredVacancies = null;
    notifyListeners();
  }

  // Добавляем метод clearSearch для устранения ошибки
  void clearSearch() {
    _searchTerm = null;
    notifyListeners();
  }
}