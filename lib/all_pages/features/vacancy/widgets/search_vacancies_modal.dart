// search_vacancy_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import '../../../widgets/navigations/navigation_provider.dart';
import '../pages/filtered_vacancies_page.dart';

class SearchModal extends StatefulWidget {
  final Function(String searchTerm)? onSearch;

  const SearchModal({super.key, this.onSearch});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Vacancy> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));
  }


  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
    ));
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final provider = Provider.of<VacancyProvider>(context, listen: false);
    final allVacancies = provider.vacancies;

    // Фильтрация по названию вакансии
    final filtered = allVacancies.where((vacancy) =>
        vacancy.title.toLowerCase().contains(query.toLowerCase())).toList();

    setState(() {
      _suggestions = filtered;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопками
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text('Поиск', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Поле ввода
            SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Должность, ключевые слова...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.green.shade600, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 12),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 16, height: 1.0),
                onChanged: _performSearch,
              ),
            ),

            const SizedBox(height: 16),

            // Результаты или история поиска
            Expanded(
              child: ListView(
                children: [
                  if (_isSearching)
                    const Center(child: CircularProgressIndicator())
                  else
                    if (_suggestions.isNotEmpty)
                      ..._suggestions.map((vacancy) =>
                          ListTile(
                            title: Text(vacancy.title),
                            onTap: () {
                              final navProvider = Provider.of<NavigationProvider>(
                                  context,
                                  listen: false
                              );
                              navProvider.setSearchTerm(vacancy.title, context);
                              Navigator.pop(context);
                            },
                          ))
                    else
                      if (_searchController.text.isNotEmpty && !_isSearching)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Ничего не найдено'),
                        )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}