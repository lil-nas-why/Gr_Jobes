import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/profile_card.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/status_card.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/resume_card.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/create_resume_button.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/widgets/go_to_create_modal.dart';
import 'package:gr_jobs/all_pages/features/additional_options/pages/additional_options_page.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/placeholders/loading_placeholder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Задержка выполнения, чтобы избежать обновления во время build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final auth = AppProvider.auth(context);
      final userProvider = AppProvider.user(context);

      if (auth.isAuthenticated && auth.authUser != null) {
        await userProvider.fetchUser(auth.authUser!.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppProvider.auth(context);
    final userProvider = AppProvider.user(context);
    final User? user = userProvider.user;

    if (!auth.isAuthenticated) {
      return const Center(child: Text('Пожалуйста, войдите в систему'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Не удалось загрузить профиль'),
            TextButton(
              onPressed: _loadUserData,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdditionalOptionsPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(user: user),
              const SizedBox(height: 10),
              StatusCard(
                user: user,
                onStatusChanged: (newStatus) async {
                  await AppProvider.user(context).updateUser({'job_search_status': newStatus});
                },
              ),
              const SizedBox(height: 10),
              if (user.resumes.isNotEmpty)
                Column(
                  children: [
                    for (var resume in user.resumes) ...[
                      ResumeCard(resume: resume),
                      if (resume != user.resumes.last)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
              const SizedBox(height: 16),
              CreateResumeButton(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (context) => ResumeCreationModal(),
                  ).then((_) => _loadUserData()); // Обновляем данные после закрытия модалки
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}