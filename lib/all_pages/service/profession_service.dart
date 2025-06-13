// profession_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';

class ProfessionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Profession>> getMainProfessions() async {
    final response = await _client
        .from('professions')
        .select()
        .is_('parent_id', null)
        .order('name');

    return (response as List)
        .map((json) => Profession.fromJson(json))
        .toList();
  }

  Future<List<Profession>> searchProfessions(String query) async {
    final response = await _client
        .from('professions')
        .select()
        .ilike('name', '%$query%')
        .order('name')
        .limit(50);

    return (response as List).map((json) => Profession.fromJson(json)).toList();
  }

  Future<List<Profession>> getProfessionSpecializations(int parentId) async {
    final response = await _client
        .from('professions')
        .select()
        .eq('parent_id', parentId)
        .order('name');

    return (response as List)
        .map((json) => Profession.fromJson(json))
        .toList();
  }
}