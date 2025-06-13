import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal.dart';
import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/pages/profile_page.dart';
import 'package:gr_jobs/main.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/nav_bar.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';

class GuestReviewsPage extends StatelessWidget {
  const GuestReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final auth = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text('Мои отзывы',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment, size: 64, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Авторизуйтесь, чтобы увидеть ваши отзывы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Зарегистрируйтесь или войдите в аккаунт, чтобы просматривать свои отзывы.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                authProvider.additionalLogin();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MainApp()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.6),
                foregroundColor: Colors.white,
                minimumSize: Size(300, 48),
              ),
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
