import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_detail_page.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/application_modal.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';
import 'package:provider/provider.dart';

class VacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback onTap;
  final VoidCallback onMapTap;
  final Function(bool) onFavoriteToggled;

  const VacancyCard({
    super.key,
    required this.vacancy,
    required this.onTap,
    required this.onMapTap,
    required this.onFavoriteToggled
  });

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserProvider>(context).user;
    final hasApplied = user?.applications.any((a) => a.vacancyId == vacancy.id) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VacancyDetailsPage(vacancy: vacancy),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vacancy.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: vacancy.isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: IconButton(
                            iconSize: 30,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              onFavoriteToggled(!vacancy.isFavorite);
                            },
                            icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                vacancy.isFavorite ? Icons.favorite : Icons.favorite_outline,
                                key: ValueKey(vacancy.isFavorite),
                                color: vacancy.isFavorite ? Colors.red : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(Icons.map_outlined),
                          onPressed: onMapTap,
                        ),
                      ],
                    ),
                  ],
                ),

                if (vacancy.minSalary != null || vacancy.maxSalary != null)
                  Text(
                    '${vacancy.minSalary?.toString() ?? 'Не указана'}–${vacancy.maxSalary?.toString() ?? ''} ₽',
                    style: const TextStyle(fontSize: 16),
                  ),

                const SizedBox(height: 8),

                // Рейтинг и отзывы
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${vacancy.rating.toStringAsFixed(1)} · ${vacancy.reviewCount} ${_getReviewsWord(vacancy.reviewCount)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Город
                Text(
                  vacancy.cityName,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                // Опыт, тип занятости, формат работы
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(vacancy.experienceName),
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (vacancy.employmentTypeName.isNotEmpty)
                      Chip(
                        label: Text(vacancy.employmentTypeName),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    if (vacancy.workFormatName.isNotEmpty)
                      Chip(
                        label: Text(vacancy.workFormatName),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Агентство
                if (vacancy.agencyName.isNotEmpty)
                  Chip(
                    label: Text('Агентство: ${vacancy.agencyName}'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),

                const SizedBox(height: 8),

                // Дата публикации
                Text(
                  'Опубликовано ${vacancy.publishedAt.day} ${_getMonthName(vacancy.publishedAt.month)}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Контакты / Откликнуться
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400!),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Контакты'),
                      ),
                    ),
                    const SizedBox(width: 8),// В классе VacancyCard обновим кнопку отклика:
                    // В классе VacancyCard обновим кнопку отклика:
                    Expanded(
                      child: ElevatedButton(
                        onPressed: hasApplied
    ? null: () {
                          final userProvider = Provider.of<AuthProvider>(context, listen: false);
                          if (!userProvider.isAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Войдите, чтобы откликнуться на вакансию'),
                              ),
                            );
                            return;
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ApplicationModal(vacancy: vacancy),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Откликнуться'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  String _getMonthName(int month) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _getExperienceName(int? experienceId) {
    switch (experienceId) {
      case 1:
        return 'Нет опыта';
      case 2:
        return 'От 1 года до 3 лет';
      case 3:
        return 'От 3 до 6 лет';
      case 4:
        return 'Более 6 лет';
      default:
        return 'Не указано';
    }
  }

  String _getReviewsWord(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'отзывов';
    switch (count % 10) {
      case 1:
        return 'отзыв';
      case 2:
      case 3:
      case 4:
        return 'отзыва';
      default:
        return 'отзывов';
    }
  }
}