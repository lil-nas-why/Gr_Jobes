import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/responses/widgets/response_card.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({Key? key}) : super(key: key);

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);

    if (userProvider.user != null) {
      // Используем Future.microtask для отложенного выполнения
      Future.microtask(() {
        vacancyProvider.fetchUserApplications(userProvider.user!.id, forceRefresh: true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Добавляем проверку mounted перед загрузкой данных
    if (mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text(
                'Мои отклики',
                style: TextStyle(color: Colors.black),
              ),
              floating: true,
              pinned: true,
              snap: false,
              forceElevated: innerBoxIsScrolled,
            ),
          ];
        },
        body: Consumer2<VacancyProvider, UserProvider>(
          builder: (context, vacancyProvider, userProvider, _) {
            if (vacancyProvider.isLoading && vacancyProvider.userApplications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vacancyProvider.userApplications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      const Text(
                        'У вас пока нет откликов',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Отправляйте отклики на понравившиеся вакансии',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (userProvider.user != null) {
                  await vacancyProvider.fetchUserApplications(
                    userProvider.user!.id,
                    forceRefresh: true,
                  );
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: vacancyProvider.userApplications.length,
                itemBuilder: (context, index) {
                  final application = vacancyProvider.userApplications[index];
                  return ApplicationCard(
                    vacancy: application.vacancy,
                    status: application.status,
                    onWithdraw: () => _withdrawApplication(
                      userProvider.user!.id,
                      application.id,
                      vacancyProvider,
                    ),
                    onContact: () => _contactEmployer(application.vacancy),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _withdrawApplication(
      String userId,
      String applicationId,
      VacancyProvider vacancyProvider,
      ) async {
    try {
      await vacancyProvider.withdrawApplication(userId, applicationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Отклик успешно отозван')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отзыве отклика: $e')),
      );
    }
  }

  void _contactEmployer(Vacancy vacancy) {
    // TODO: Реализовать функционал связи
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция связи будет реализована позже')),
    );
  }
}