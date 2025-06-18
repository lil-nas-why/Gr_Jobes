import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_detail_page.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:intl/intl.dart';

class FavoriteVacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback onRemove;

  const FavoriteVacancyCard({
    Key? key,
    required this.vacancy,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VacancyDetailsPage(vacancy: vacancy),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Уменьшили отступы по бокам
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12), // Оставили такой же cornerRadius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vacancy.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (vacancy.minSalary != null || vacancy.maxSalary != null)
                          Text(
                            '${vacancy.minSalary?.toString() ?? ''} – ${vacancy.maxSalary?.toString() ?? ''} ₽ за месяц'
                                .replaceAll(' – ', '–')
                                .replaceAll('– ', ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (vacancy.locationCity != null)
                          Text(
                            '${vacancy.locationCity!.name} (${vacancy.locationCity!.region?.name ?? ''})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (vacancy.agencyName.isNotEmpty)
                          Row(
                            children: [
                              Text(
                                vacancy.agencyName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Опубликовано ${DateFormat('dd MMMM', 'ru_RU').format(vacancy.publishedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero, // Убираем внутренние отступы у кнопки
                    constraints: const BoxConstraints(), // Убираем ограничения
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}