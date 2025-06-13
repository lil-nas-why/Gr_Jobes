import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';

class UserProfession {
  final String user_id;
  final int profession_id;
  final bool is_primary;
  final int? years_of_experience;
  final DateTime created_at;

  final User user;
  final Profession profession;

  UserProfession({
    required this.user_id,
    required this.profession_id,
    required this.is_primary,
    this.years_of_experience,
    required this.created_at,
    required this.user,
    required this.profession,
  });

  factory UserProfession.fromJson(Map<String, dynamic> json) {
    return UserProfession(
      user_id: json['user_id'],
      profession_id: json['profession_id'],
      is_primary: json['is_primary'] ?? false,
      years_of_experience: json['years_of_experience'],
      created_at: DateTime.parse(json['created_at']),
      user: User.fromJson(json['user']),
      profession: Profession.fromJson(json['profession']),
    );
  }
}