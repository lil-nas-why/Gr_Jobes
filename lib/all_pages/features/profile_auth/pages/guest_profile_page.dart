import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal.dart';
import 'package:gr_jobs/all_pages/features/additional_options/pages/additional_options_page.dart';


class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdditionalOptionsPage()),
              );
            },
          ),
        ],
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
            Image.asset(
              'assets/images/guest_profile_placeholder.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 24),
            Text(
              'Создайте резюме',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Заполните информацию о себе и своих навыках, так работодатель сможет найти вас быстрее',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => showAuthModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.5),
                foregroundColor: Colors.white,
                minimumSize: Size(300, 48),
              ),
              child: Text('Создать резюме'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => showAuthModal(context),
              style: TextButton.styleFrom(
                minimumSize: Size(300, 48),
              ),
              child: Text(
                'Войти в личный кабинет',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}