import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gr_jobs/all_pages/models_data/profile_page_model.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/features/additional_options/pages/guest_reviews_page.dart';

class AdditionalOptionsPage extends StatefulWidget {
  const AdditionalOptionsPage({super.key});

  @override
  State<AdditionalOptionsPage> createState() => _AdditionalOptionsPageState();
}

class _AdditionalOptionsPageState extends State<AdditionalOptionsPage> {

  @override
  void dispose() {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context).isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: Text('Дополнительно',
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
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(auth ? 'Настройки' : 'Вход и регистрация'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/settings');
              } else {
                showAuthModal(context);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Уведомления'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            // trailing: auth
            //     ? Container(
            //   width: 20,
            //   height: 20,
            //   decoration: BoxDecoration(
            //     color: Colors.red,
            //     shape: BoxShape.circle,
            //   ),
            //   child: Center(
            //     child: Text(
            //       '4',
            //       style: TextStyle(color: Colors.white, fontSize: 12),
            //     ),
            //   ),
            // )
            //     : null,
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/notifications');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.grid_view),
            title: Text('Сервисы'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/services');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Статьи'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/articles');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Мои отзывы'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/my_reviews');
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => GuestReviewsPage()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('О приложении'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/about_app');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Помощь'),
            trailing: Icon(Icons.arrow_forward_ios_outlined),
            onTap: () {
              if (auth) {
                Navigator.pushNamed(context, '/help');
              }
            },
          ),
        ],
      ),
    );
  }
}