import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal.dart';

class GuestResponsesPage extends StatelessWidget {
  const GuestResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Отклики'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Высота Divider
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
            Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              'Войдите, чтобы увидеть свои отклики',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Авторизуйтесь, чтобы видеть историю ваших откликов на вакансии',
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