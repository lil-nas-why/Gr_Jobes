import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/edit_user_info/widgets/edit_user_info_modal.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/status_card.dart';

class UserDetailPage extends StatefulWidget {
  final User user;

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {

  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    });
    super.dispose();
  }

  Future<void> _loadUserData(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (auth.isAuthenticated && auth.authUser != null) {
      try {
        await userProvider.fetchUser(auth.authUser!.id);

        // Получаем обновленные данные пользователя из провайдера
        final updatedUser = userProvider.user;

        if (updatedUser != null && mounted) {
          setState(() {
            _user = updatedUser;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка обновления данных: $e')),
          );
        }
      }
    }
  }

  void _showEditProfileModal() async {
    final provider = Provider.of<VacancyProvider>(context, listen: false);
    await provider.loadCities();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => EditProfileModal(user: _user, cities: provider.cities),
    );

    if (result == true && mounted) {
      await _loadUserData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthProvider>(context);


    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            title: const Text(
              'Профиль',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Divider(
                height: 1.0,
                thickness: 1.0,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Имя, фамилия, город и аватар ===
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user.firstName ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user.lastName ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user.city.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Аватар
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: _user.avatarUrl?.isNotEmpty == true
                              ? DecorationImage(
                            image: NetworkImage(_user.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                              : const DecorationImage(
                            image: AssetImage('assets/images/user.webp'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === Кнопка редактирования ===
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showEditProfileModal,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.grey[100],
                      ),
                      child: const Text(
                        'Редактировать',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // === Статус поиска работы ===
                  StatusCard(
                    user: _user,
                    onStatusChanged: (newStatus) async {
                      await AppProvider.user(context).updateUser({'job_search_status': newStatus});
                    },
                  ),
                  const SizedBox(height: 24),

                  // === Блок "Видео о себе" ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Видео о себе',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Запишите работодателям видео о своём опыте и навыках',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Записать'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === Блок контактов ===
                  const Text(
                    'Контакты',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_user.phone.isNotEmpty)
                        _buildContactItem('Телефон', widget.user.phone),
                      if (_user.email.isNotEmpty)
                        _buildContactItem('Почта', widget.user.email),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}