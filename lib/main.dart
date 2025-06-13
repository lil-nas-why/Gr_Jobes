import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/navigation_bar.dart';
import 'package:gr_jobs/all_pages/features/additional_options/pages/additional_options_page.dart';
import 'package:gr_jobs/all_pages/features/additional_options/pages/settings_pages/settings_page.dart';
import 'package:gr_jobs/supabase_config.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7), // вместо green.shade900
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  await SupabaseConfig.initialize();

  final client = supabase.Supabase.instance.client;

  final initialSession = client.auth.currentSession;

  runApp(
    AppProvider(

      child: MainApp(),
    ),
  );

}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context).isAuthenticated;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Navigation(auth: auth),
        '/additional_options': (context) => AdditionalOptionsPage(),
        '/settings': (context) => SettingsPage(),
        // '/notifications': (context) => NotificationsPage(),
        // '/services': (context) => ServicesPage(),
        // '/articles': (context) => ArticlesPage(),
        // '/my_reviews': (context) => MyReviewsPage(),
        // '/about_app': (context) => AboutAppPage(),
        // '/help': (context) => HelpPage(),
        '/vacancies': (context) => VacancyPage(),
      },
    );
  }
}