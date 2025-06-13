import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/job_search_status_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userResponse = await supabase.Supabase.instance.client
          .from('users')
          .select('''
          *, 
          city: city_id(*),
          user_job_search_status: user_job_search_status(status_id(*)),
          resumes(*, profession: profession_id(*))
        ''')
          .eq('supabase_user_id', userId) // <-- проверяем по правильному полю
          .maybeSingle();

      if (userResponse == null) {
        _error = 'Пользователь не найден';
        _user = null;
        print('Ошибка: Пользователь с supabase_user_id=$userId не найден');
      } else {
        print('Ответ от базы данных: $userResponse');
        _user = User.fromJson(userResponse as Map<String, dynamic>);
      }
    } catch (e, stackTrace) {
      _error = 'Ошибка загрузки профиля: $e';
      _user = null;
      print('Ошибка в fetchUser:');
      print('Пользователь ID: $userId');
      print('Ошибка: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (data.containsKey('job_search_status')) {
        final statusId = await _getStatusIdByCodeName(data['job_search_status']);
        if (statusId != null) {
          await supabase.Supabase.instance.client
              .from('user_job_search_status')
              .upsert({
            'user_id': _user!.id,
            'status_id': statusId,
            'updated_at': DateTime.now().toIso8601String(),
          });

          final statusResponse = await supabase.Supabase.instance.client
              .from('job_search_statuses')
              .select()
              .eq('id', statusId)
              .single();

          if (statusResponse != null) {
            _user = _user!.copyWith(
              jobSearchStatus: JobSearchStatus.fromJson(statusResponse),
            );
          }
        }
      } else {
        final response = await supabase.Supabase.instance.client
            .from('users')
            .update(data)
            .eq('id', _user!.id)
            .select('*')
            .maybeSingle();

        if (response != null) {
          _user = User.fromJson(response as Map<String, dynamic>);
        }
      }
    } catch (e) {
      _error = 'Ошибка обновления профиля: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> _getStatusIdByCodeName(String codeName) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('job_search_statuses')
          .select('id')
          .eq('status_name', codeName)
          .maybeSingle();

      return response?['id'] as int?;
    } catch (e) {
      print('Ошибка получения ID статуса: $e');
      return null;
    }
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      await fetchUser(_user!.id);
    }
  }
}