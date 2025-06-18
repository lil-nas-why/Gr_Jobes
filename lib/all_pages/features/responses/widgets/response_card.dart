import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_detail_page.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:intl/intl.dart';

class ApplicationCard extends StatelessWidget {
  final Vacancy vacancy;
  final String status;
  final VoidCallback onWithdraw;
  final VoidCallback onContact;

  const ApplicationCard({
    Key? key,
    required this.vacancy,
    required this.status,
    required this.onWithdraw,
    required this.onContact,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'reviewing': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'hired': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending': return 'На рассмотрении';
      case 'reviewing': return 'Просмотрено работодателем';
      case 'rejected': return 'Отклонено';
      case 'hired': return 'Принято';
      default: return status;
    }
  }

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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vacancy title
                  Text(
                    vacancy.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Agency name (вместо зарплаты)
                  if (vacancy.agency != null && vacancy.agency!.name.isNotEmpty)
                    Text(
                      vacancy.agency!.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Location
                  if (vacancy.locationCity != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${vacancy.locationCity!.name}'
                              '${vacancy.locationCity!.region?.name != null ? ' (${vacancy.locationCity!.region!.name})' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  if (vacancy.agency != null && vacancy.agency!.name.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          vacancy.agency!.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Дата публикации
                  Text(
                    'Опубликовано ${DateFormat('dd MMMM yyyy', 'ru_RU').format(vacancy.publishedAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Buttons (обновленные как в VacancyCard)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onContact,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400!),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Контакты'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onWithdraw,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Отказаться'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}