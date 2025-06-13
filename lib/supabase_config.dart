import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final client = Supabase.instance.client;

  static initialize() {
    Supabase.initialize(
      url: 'https://haysyhfsmizbxkdjmfvo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheXN5aGZzbWl6YnhrZGptZnZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTcwNDMsImV4cCI6MjA2MzMzMzA0M30.Wjg9SWlrNcrCdvxKGZn5g3luPXAAz0F2iMDYZaqffFI',
    );
  }
}