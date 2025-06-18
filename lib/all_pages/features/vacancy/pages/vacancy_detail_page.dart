import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/vacancy_ya_map_page.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/features/vacancy/widgets/application_modal.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';
import 'package:provider/provider.dart';

class VacancyDetailsPage extends StatefulWidget {
  final Vacancy vacancy;

  const VacancyDetailsPage({super.key, required this.vacancy});

  @override
  State<VacancyDetailsPage> createState() => _VacancyDetailsPageState();

  static String _getReviewsWord(int count) {
    if (count % 100 >= 11 && count % 100 <= 19) return 'отзывов';
    switch (count % 10) {
      case 1: return 'отзыв';
      case 2:
      case 3:
      case 4: return 'отзыва';
      default: return 'отзывов';
    }
  }
}

class _VacancyDetailsPageState extends State<VacancyDetailsPage> {

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Убирает тень при прокрутке
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vacancy.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.vacancy.minSalary?.toString() ?? ''} – ${widget.vacancy.maxSalary?.toString() ?? ''} ₽ за месяц',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'на руки',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Опыт работы:', widget.vacancy.getExperienceName(widget.vacancy.experienceId ?? 0)),
                  _buildInfoRow('График:', '5/2'),
                  _buildInfoRow('Рабочие часы:', '12'),
                  _buildInfoRow('Формат работы:', widget.vacancy.workFormatName),
                  const SizedBox(height: 16),

                  // Карточка агентства
                  if (widget.vacancy.agency != null) _buildAgencyCard(),
                  const SizedBox(height: 16),

                  // Описание вакансии
                  Text(
                    widget.vacancy.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Блок с местом работы
                  _buildWorkLocationCard(context),
                  const SizedBox(height: 16),


                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Consumer2<AuthProvider, UserProvider>(
                builder: (context, authProvider, userProvider, _) {
                  final hasApplied = userProvider.user?.applications?.any((a) => a.vacancyId == widget.vacancy.id) ?? false;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasApplied ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: hasApplied ? null : () {
                      if (!authProvider.isAuthenticated) {
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
                        builder: (context) => ApplicationModal(vacancy: widget.vacancy),
                      );
                    },
                    child: Text(
                      hasApplied ? 'Вы уже откликнулись' : 'Откликнуться',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.business, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vacancy.agency?.name ?? 'Агентство',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.vacancy.rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.vacancy.reviewCount} ${VacancyDetailsPage._getReviewsWord(widget.vacancy.reviewCount)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkLocationCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              vacancyTitle: widget.vacancy.title,
              address: '${widget.vacancy.cityName}, ${widget.vacancy.address}',
              latitude: widget.vacancy.latitude,
              longitude: widget.vacancy.longitude,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Где предстоит работать',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.vacancy.cityName,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: AssetImage('assets/images/map_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}