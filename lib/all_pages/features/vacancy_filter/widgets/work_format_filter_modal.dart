import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/filtered_vacancies_page.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/navigation_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/work_format_model.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:provider/provider.dart';

class PartTimeWorkModal extends StatefulWidget {
  const PartTimeWorkModal({super.key});

  @override
  State<PartTimeWorkModal> createState() => _PartTimeWorkModalState();
}

class _PartTimeWorkModalState extends State<PartTimeWorkModal> {
  List<WorkFormat> _workFormats = [];
  List<String> _selectedFormats = [];
  bool _isLoading = true;
  final List<int> _allowedFormatIds = [3, 4, 6]; // IDs for Проектная работа, Стажировка, Подработка

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkFormats();
    });
  }

  Future<void> _loadWorkFormats() async {
    try {
      final provider = Provider.of<VacancyProvider>(context, listen: false);
      _workFormats = provider.workFormats;

      if (_workFormats.isEmpty) {
        await provider.loadFilterData();
        _workFormats = provider.workFormats;
      }

      // Filter to only show allowed formats
      _workFormats = _workFormats.where((format) => _allowedFormatIds.contains(format.id)).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading work formats: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleFormatSelection(String formatName) {
    setState(() {
      if (_selectedFormats.contains(formatName)) {
        _selectedFormats.remove(formatName);
      } else {
        _selectedFormats.add(formatName);
      }
    });
  }

  void _resetFilters() {
    setState(() => _selectedFormats.clear());
  }

  void _applyFilters(BuildContext context) {
    final filters = {
      'workFormats': _selectedFormats,
      'searchQuery': '', // Добавляем пустой поисковый запрос
    };

    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);

    // Закрываем модальное окно
    Navigator.pop(context);

    // После закрытия выполняем навигацию
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilteredVacanciesPage(
            searchTerm: '',
            vacancies: vacancyProvider.getFilteredVacancies(filters),
            onBack: () {
              SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
              ));

              Navigator.pop(context);
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Подработка и временная работа',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Выберите подходящие варианты',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Column(
                            children: _workFormats.map((format) {
                              final isSelected = _selectedFormats.contains(format.formatName);
                              return GestureDetector(
                                onTap: () => _toggleFormatSelection(format.formatName),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        format.formatName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected ? Colors.green : Colors.grey,
                                            width: 2,
                                          ),
                                          color: isSelected ? Colors.green : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider and fixed buttons at bottom
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Сбросить',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _applyFilters(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Найти',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}