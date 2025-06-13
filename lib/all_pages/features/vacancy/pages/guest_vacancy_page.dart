import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal.dart';

class GuestVacancyPage extends StatelessWidget {
  const GuestVacancyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Вакансии'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Убираем тень
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/guest_vacancy_placeholder.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 24),
            Text(
              'Авторизуйтесь, чтобы просматривать вакансии',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Чтобы просматривать вакансии,\nвойдите или зарегистрируйтесь',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => showAuthModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.6),
                foregroundColor: Colors.white,
                minimumSize: Size(300, 48),
              ),
              child: Text('Войти / Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}