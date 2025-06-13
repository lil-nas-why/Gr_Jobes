import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../widgets/navigations/navigation_provider.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'vacancy_provider.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeSupabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final client = supabase.Supabase.instance.client;
          final initialSession = client.auth.currentSession;
          final userProvider = UserProvider();

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthProvider(initialSession, userProvider),
              ),
              ChangeNotifierProvider(
                create: (_) => userProvider,
              ),
              ChangeNotifierProvider(
                create: (_) => VacancyProvider(),
              ),
              ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ],
            child: child,
          );
        }
        return MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Future<void> _initializeSupabase() async {
    await supabase.Supabase.initialize(
      url: 'https://haysyhfsmizbxkdjmfvo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheXN5aGZzbWl6YnhrZGptZnZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTcwNDMsImV4cCI6MjA2MzMzMzA0M30.Wjg9SWlrNcrCdvxKGZn5g3luPXAAz0F2iMDYZaqffFI',
    );
  }

  static AuthProvider auth(BuildContext context) =>
      Provider.of<AuthProvider>(context, listen: false);

  static UserProvider user(BuildContext context) =>
      Provider.of<UserProvider>(context, listen: false);

  static VacancyProvider vacancy(BuildContext context) =>
      Provider.of<VacancyProvider>(context, listen: false);
}