import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/features/vacancy_filter/widgets/sort_option_modal.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/vacancy_card.dart';

import 'package:gr_jobs/all_pages/features/vacancy_filter/pages/vacancy_filter_page.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/navigation_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/search_vacancies_modal.dart';


class FilteredVacanciesPage extends StatefulWidget {
  final String searchTerm;

  final List<Vacancy> vacancies;
  final VoidCallback onBack;

  const FilteredVacanciesPage({
    super.key,
    required this.searchTerm,
    required this.vacancies,
    required this.onBack,
  });

  @override
  State<FilteredVacanciesPage> createState() => _FilteredVacanciesPageState();
}

class _FilteredVacanciesPageState extends State<FilteredVacanciesPage> {
  late List<Vacancy> _displayedVacancies;
  String _currentSort = 'relevance';

  @override
  void initState() {
    super.initState();
    _displayedVacancies = List.from(widget.vacancies);
    _applySort();
  }

  @override
  void didUpdateWidget(FilteredVacanciesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vacancies != oldWidget.vacancies) {
      _displayedVacancies = List.from(widget.vacancies);
      _applySort(); // Применяем сортировку при обновлении фильтров
    }
  }

  void _applySort() {
    switch (_currentSort) {
      case 'date':
        _displayedVacancies.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case 'salary_desc':
        _displayedVacancies.sort((a, b) {
          final aSalary = b.maxSalary ?? b.minSalary ?? 0;
          final bSalary = a.maxSalary ?? a.minSalary ?? 0;
          return aSalary.compareTo(bSalary);
        });
        break;
      case 'salary_asc':
        _displayedVacancies.sort((a, b) {
          final aSalary = a.minSalary ?? a.maxSalary ?? 0;
          final bSalary = b.minSalary ?? b.maxSalary ?? 0;
          return aSalary.compareTo(bSalary);
        });
        break;
      default: // relevance - оставляем исходный порядок
        _displayedVacancies = List.from(widget.vacancies);
        break;
    }
  }

  void _sortVacancies(String sortOption) {
    setState(() {
      _currentSort = sortOption;
      _applySort(); // Применяем выбранную сортировку
    });
  }

  void _openSortModal(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SortModal(
        currentSort: _currentSort,
        onSortSelected: (sortOption) {
          _sortVacancies(sortOption);

          Navigator.pop(context);

          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
          ));
        },
      ),
    ).then((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
      ));
    });
  }

  String _getSortDisplayName(String sortKey) {
    switch (sortKey) {
      case 'date':
        return 'По дате';
      case 'salary_desc':
        return 'По убыванию дохода';
      case 'salary_asc':
        return 'По возрастанию дохода';
      case 'relevance':
      default:
        return 'По соответствию';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBack,
              ),
              title: const Text(
                'Результаты поиска',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 170,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildSearchRow(context),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.vacancies.length} вакансий',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => _openSortModal(context),
                            child: Row(
                              children: [
                                Text(
                                  _getSortDisplayName(_currentSort),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  CupertinoIcons.sort_down_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _displayedVacancies.length,
          itemBuilder: (context, index) {
            final vacancy = _displayedVacancies[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: VacancyCard(
                vacancy: vacancy,
                onFavoriteToggled: (isFavorite) {
                  // Логика добавления в избранное
                },
                onTap: () {
                  // Логика нажатия на карточку
                },
                onMapTap: () {
                  // Логика открытия карты
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: widget.searchTerm),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FiltersModal(
                      initialFilters: Provider.of<NavigationProvider>(context,
                              listen: false)
                          .filters,
                    ),
                  ),
                );
              },
              decoration: InputDecoration(
                hintText: 'Должность, ключевые слова...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 48,
          width: 48,
          child: InkWell(
            onTap: () {
              SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  systemNavigationBarColor: Colors.white));

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FiltersModal(
                    initialFilters:
                        Provider.of<NavigationProvider>(context, listen: false)
                            .filters,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(CupertinoIcons.rectangle_grid_2x2,
                  color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
