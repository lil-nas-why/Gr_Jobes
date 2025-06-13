import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/recommendation_card.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/vacancy_ya_map_page.dart';
import 'package:gr_jobs/all_pages/models_data/recommendation_models_data.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:provider/provider.dart';

// --- Локальные импорты ---
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/vacancy_card.dart';

import 'package:gr_jobs/all_pages/features/vacancy_filter/pages/vacancy_filter_page.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/search_vacancies_modal.dart';

class VacancyPage extends StatefulWidget {
  const VacancyPage({super.key});

  @override
  State<VacancyPage> createState() => _VacancyPageState();
}

class _VacancyPageState extends State<VacancyPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Метод для загрузки вакансий
      void loadVacanciesWithUser() {
        if (authProvider.isAuthenticated && authProvider.appUser != null) {
          print('Начинаем загрузку вакансий для пользователя: ${authProvider.appUser!.id}');
          vacancyProvider.loadVacancies(currentUserId: authProvider.appUser!.id);
        } else {
          print('Пользователь не авторизован или appUser == null');
          vacancyProvider.loadVacancies();
        }
      }

      // Подписываемся на изменения AuthProvider
      late final void Function() listener;
      listener = () {
        if (!mounted) return;
        loadVacanciesWithUser();
      };

      // Вызываем один раз при старте
      loadVacanciesWithUser();

      // Добавляем подписку
      authProvider.addListener(listener);

      // Сохраняем для dispose
      _authListener = listener;
    });
  }

  @override
  void dispose() {
    if (_authListener != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_authListener!);
    }
    _scrollController.dispose();
    super.dispose();
  }

  VoidCallback? _authListener;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Поиск
                  _buildMainSearchBar(context),
                  const SizedBox(height: 16),

                  // Карточки рекомендаций
                  const Text('Рекомендуем попробовать',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150, // Увеличил высоту для лучшего отображения
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation = recommendations[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RecommendationCard(
                            recommendation: recommendation,
                            onTap: () {

                              print('Нажата рекомендация: ${recommendation.title}');

                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Список вакансий
                  const Text('Вакансии для вас',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Получаем список вакансий через Provider
                  Consumer<VacancyProvider>(
                    builder: (context, vacancyProvider, _) {
                      if (vacancyProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final vacancies = vacancyProvider.vacancies;
                      if (vacancies.isEmpty) {
                        return const Center(child: Text('Нет вакансий'));
                      }
                      return Column(
                        children: vacancies.map((vacancy) {
                          return StatefulBuilder(
                            builder: (context, setModalState) {
                              return VacancyCard(
                                vacancy: vacancy,
                                onFavoriteToggled: (isFavorite) async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);

                                  if (authProvider.isAuthenticated && authProvider.appUser != null) {
                                    try {
                                      await vacancyProvider.toggleFavoriteVacancy(
                                        authProvider.appUser!.id,
                                        vacancy.id,
                                        !isFavorite,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Ошибка: ${e.toString()}')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Войдите, чтобы добавлять в избранное')),
                                    );
                                  }
                                },
                                onTap: () {},
                                onMapTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                        vacancyTitle: vacancy.title,
                                        address:
                                        '${vacancy.cityName}, ${vacancy.address}',
                                        latitude: vacancy.latitude,
                                        longitude: vacancy.longitude,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Кнопка "Наверх"
        Positioned(
          right: 16,
          bottom: 70,
          child: ListenableBuilder(
            listenable: _scrollController,
            builder: (context, _) {
              return AnimatedOpacity(
                opacity: _scrollController.hasClients &&
                    _scrollController.offset > 100
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton(
                  mini: true,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainSearchBar(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                readOnly: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const SearchModal(),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Должность, ключевые слова...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FiltersModal(),
                  ),
                );
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.rectangle_grid_2x2,
                    color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
