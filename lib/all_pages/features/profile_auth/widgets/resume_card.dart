import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';

class ResumeCard extends StatelessWidget {
  final Resume resume;

  const ResumeCard({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Заголовок резюме ---
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume.title ?? 'Без названия',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (resume.autoRaiseDate != null)
                          Text(
                            "Поднять вручную можно ${_formatDateTime(resume.autoRaiseDate!)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),
              ),

              // --- Статистика ---
              _buildStatsContainer(resume),

              // --- Рекомендация ---
              _buildRecommendationCard(resume),

              // --- Кнопка улучшения ---
              _buildImproveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContainer(Resume resume) {
    final stats = resume.weeklyStats;
    if (stats == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem("Показы", stats.views.toString()),
          VerticalDivider(width: 1, thickness: 1),
          _buildStatItem("Просмотры", stats.impressions.toString()),
          VerticalDivider(width: 1, thickness: 1),
          _buildStatItem("Приглашения", stats.invitations.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecommendationCard(Resume resume) {
    if (resume.recommendation.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Чего не хватает в вашем резюме?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              resume.recommendation,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImproveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
        ),
        child: const Text("Улучшить резюме"),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final monthNames = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
  }
}