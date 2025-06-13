import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_data/profile_page_model.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/nav_bar.dart';
import 'package:gr_jobs/main.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final auth = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки',
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Пользователь'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/user_profile');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/notifications');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Звонки'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/calls');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.grid_view),
            title: Text('Сервисы для соискателя'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/services_for_job_seeker');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Скрытые вакансии и компании'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/hidden_vacancies');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('Страна поиска'),
            subtitle: Text('Россия'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/search_country');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Язык'),
            subtitle: Text('Светлая'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/language_settings');
              }
            },
          ),
          SizedBox(height: 80), // Добавляем отступ для кнопки "Выйти"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainApp()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red[400],
                  elevation: 0,
                  side: BorderSide(color: Colors.red[400]!), // Прозрачная граница
                ),
                child: Text('Выйти из приложения'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}