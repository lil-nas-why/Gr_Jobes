import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/delete_resume_modal.dart';
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';
import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ResumeCard extends StatefulWidget {
  final Resume resume;
  final VoidCallback onResumeDeleted;

  const ResumeCard({
    super.key,
    required this.resume,
    required this.onResumeDeleted,
  });

  @override
  State<ResumeCard> createState() => _ResumeCardState();
}

class _ResumeCardState extends State<ResumeCard> {
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
              // --- Верхняя часть с двумя колонками ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Левая колонка (название и дата)
                    Expanded(
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.resume.title ?? 'Без названия',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Обновлено ${_formatDateTime(widget.resume.updatedAt)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Правая колонка (иконка и кнопки)
                    SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          // Горизонтальный ряд кнопок
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Кнопка удаления
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 25,
                                    color: Colors.red),
                                onPressed: () => _deleteResume(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Статистика ---
              _buildStatsContainer(widget.resume),

              // --- Кнопка улучшения ---
              _buildImproveButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _editResume(BuildContext context) {
    // Логика редактирования резюме
  }

  void _deleteResume(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeleteResumeModal(
        onDelete: () async {
          try {
            // Получаем провайдер пользователя
            final userProvider = AppProvider.user(context);

            // Удаляем резюме через API Supabase
            await supabase.Supabase.instance.client
                .from('resumes')
                .delete()
                .eq('id', widget.resume.id);

            if (mounted) {
              await userProvider.fetchUser(userProvider.user!.id);
              widget.onResumeDeleted(); // Вызываем callback после успешного удаления

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Резюме успешно удалено'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ошибка при удалении: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // Форматирование даты
  String _formatDateTime(DateTime date) {
    final monthNames = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    final time = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    return "${date.day} ${monthNames[date.month - 1]} ${date.year}, $time";
  }

  // Остальные методы без изменений
  Widget _buildStatsContainer(Resume resume) {
    final stats = resume.weeklyStats;
    if (stats == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8),
          child: Text(
            'Статистика за неделю',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
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
              const VerticalDivider(width: 1, thickness: 1),
              _buildStatItem("Просмотры", stats.impressions.toString()),
              const VerticalDivider(width: 1, thickness: 1),
              _buildStatItem("Приглашения", stats.invitations.toString()),
            ],
          ),
        ),
      ],
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

  Widget _buildImproveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text("Поднять в поиске"),
      ),
    );
  }
}