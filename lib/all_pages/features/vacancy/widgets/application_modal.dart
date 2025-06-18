// application_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';

class ApplicationModal extends StatefulWidget {
  final Vacancy vacancy;

  const ApplicationModal({super.key, required this.vacancy});

  @override
  State<ApplicationModal> createState() => _ApplicationModalState();
}

class _ApplicationModalState extends State<ApplicationModal> {
  Resume? _selectedResume;
  bool _isSubmitting = false;

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
    final userProvider = Provider.of<UserProvider>(context);
    final resumes = userProvider.user?.resumes ?? [];
    final hasResumes = resumes.isNotEmpty;

    return FractionallySizedBox(
      heightFactor: 0.5,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Container(), // Убираем стандартную кнопку назад
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            elevation: 0,
            automaticallyImplyLeading: false, // Убираем автоматическую кнопку назад
          ),
          body: Column(
            children: [
              // Информация о вакансии
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vacancy.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.vacancy.agencyName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),

              // Выбор резюме
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Выберите резюме',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!hasResumes)
                        const Center(
                          child: Column(
                            children: [
                              Icon(Icons.note_add, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'У вас нет резюме',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Создайте резюме для отклика на вакансии',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: ListView(
                            children: resumes.map((resume) {
                              final isSelected = _selectedResume?.id == resume.id;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedResume = resume),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? Colors.green : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.person, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        resume.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? Colors.green : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          color: isSelected ? Colors.green : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Кнопка отклика
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting || _selectedResume == null || !hasResumes
                        ? null
                        : () => _submitApplication(context),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Откликнуться', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication(BuildContext context) async {
    if (_selectedResume == null) return;

    setState(() => _isSubmitting = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final authUser = supabase.Supabase.instance.client.auth.currentUser;

    if (authUser == null || user.supabase_user_id != authUser.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка аутентификации: несоответствие пользователей'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final response = await supabase.Supabase.instance.client
          .from('applications')
          .insert({
        'seeker_id': user.id,
        'vacancy_id': widget.vacancy.id,
        'resume_id': _selectedResume!.id,
        'status': 'pending',
        'cover_letter': null,
      }).select().single();

      await userProvider.refreshUser();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Отклик успешно отправлен!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on supabase.PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отправке отклика: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неизвестная ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}