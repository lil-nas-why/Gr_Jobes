import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gr_jobs/all_pages/models_data/resume_model_data.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/create_resume/steps_content/profession_step.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../service/provider.dart';
import '../../pages/profile_page.dart';
import '../steps_content/add_info_step.dart';
import '../steps_content/education_step.dart';
import '../steps_content/salary_step.dart';

class ResumeCreationPage extends StatefulWidget {
  const ResumeCreationPage({super.key});

  @override
  State<ResumeCreationPage> createState() => _ResumeCreationPageState();
}

class _ResumeCreationPageState extends State<ResumeCreationPage> {
  int currentStep = 0;
  final ResumeData resumeData = ResumeData();
  Profession? _selectedProfession;
  bool _isSaving = false;

  Future<void> _saveResume() async {
    if (_selectedProfession == null || resumeData.about.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пользователь не авторизован')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Сначала убедимся, что пользователь существует в таблице users
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('supabase_user_id', currentUser.id)
          .maybeSingle();



      if (userResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль пользователя не найден')),
        );
        return;
      }

      // Теперь сохраняем резюме, используя id из таблицы users
      await Supabase.instance.client.from('resumes').upsert({
        'user_id': userResponse['id'], // Используем id из users, а не supabase_user_id
        'profession_id': _selectedProfession!.id,
        'title': _selectedProfession!.name,
        'experience_years': resumeData.experienceYears ?? 0,
        'education_id': resumeData.educationId,
        'salary_expectation': resumeData.salaryExpectation,
        'about': resumeData.about,
        'is_published': false,
      });

      if (mounted) {
        Navigator.of(context).pop();
        final userProvider = AppProvider.user(context);
        await userProvider.updateUser({}); // Пустой Map, если не нужно обновлять конкретные поля
      }

    } catch (e) {
      if (e is supabase.PostgrestException && e.code == '23503') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: Пользователь не найден в системе')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _nextStep() {
    if (currentStep < 4 && mounted) {
      setState(() => currentStep++);
    } else if (currentStep == 4) {
      _saveResume();
    }
  }



  void _previousStep() {
    if (currentStep > 0 && mounted) {
      setState(() => currentStep--);
    }
  }

  Widget buildStepContent(int step) {
    switch (step) {
      case 0:
        return ProfessionStep(
          onProfessionSelected: (profession) {
            setState(() {
              _selectedProfession = profession;
              resumeData.profession = profession;
            });
            _nextStep();
          },
        );
      case 1:
        return EducationStep(
          currentEducationLevel: resumeData.educationId ?? -1,
          onEducationLevelSelected: (levelId) {
            setState(() {
              resumeData.educationId = levelId;
            });
            _nextStep();
          },
        );

      case 2:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSalaryModal(context);
        });
        return SalaryStep(
          currentSalary: resumeData.salaryExpectation,
          currentCurrency: resumeData.currency,
          onNext: () {
            if (resumeData.salaryExpectation > 0) {
              _nextStep();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите уровень зарплаты')),
              );
            }
          },
        );
      case 3:
        return AdditionalInfoStep(
          additionalInfoEntered: (value) {
            setState(() {
              resumeData.about = value;
            });
          },
        );
      default:
        return Container();
    }
  }
  void _showSalaryModal(BuildContext context) {
    final salaryController = TextEditingController(
      text: resumeData.salaryExpectation > 0
          ? resumeData.salaryExpectation.toString()
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Заголовок модалки ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    const Text(
                      'Укажите желаемый\nуровень дохода в месяц',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Поле ввода зарплаты ---
                const Text('Минимальный уровень дохода'),
                const SizedBox(height: 8),
                TextField(
                  controller: salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Например, 50000',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.green.shade600,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value.replaceAll(' ', ''));
                    if (parsed != null) {
                      resumeData.salaryExpectation = parsed;
                    }
                  },
                ),

                const SizedBox(height: 16),

                // --- Выбор валюты ---
                const Text('Выберите валюту'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Рубли', 'Доллары', 'Евро']
                      .map((currency) => FilterChip(
                    label: Text(currency),
                    selected: resumeData.currency == currency,
                    onSelected: (_) {
                      resumeData.currency = currency;
                    },
                  ))
                      .toList(),
                ),

                const SizedBox(height: 24),

                // --- Кнопка "Сохранить и продолжить" ---
                ElevatedButton(
                  onPressed: resumeData.salaryExpectation > 0
                      ? () {
                    Navigator.pop(context);
                    _nextStep();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Сохранить и продолжить'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 42,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            // --- Индикатор прогресса всегда по центру ---
            Align(
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final itemWidth = (availableWidth - 32) / 5;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(4, (index) {
                      return Container(
                        key: ValueKey('step_$index'),
                        width: itemWidth.clamp(20.0, 48.0),
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= currentStep
                              ? Colors.green.shade600
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // --- Кнопка "назад" слева ---
            if (currentStep > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.grey[400],
                    onPressed: _previousStep,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    tooltip: 'Назад',
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: buildStepContent(currentStep),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        onSaveAndContinue: _isSaving ? null : _nextStep,
        currentStep: currentStep,
        isLoading: _isSaving,
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final VoidCallback? onSaveAndContinue;
  final int currentStep;
  final bool isLoading;

  const BottomBar({
    super.key,
    required this.onSaveAndContinue,
    required this.currentStep,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onSaveAndContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(
          currentStep < 3 ? 'Сохранить и продолжить' : 'Завершить',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
