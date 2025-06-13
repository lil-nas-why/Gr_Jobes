import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';

class FavoriteVacancy {
  final String seekerId;
  final String vacancyId;
  final DateTime addedAt;

  final User user;      // Владелец избранного
  final Vacancy vacancy; // Вакансия

  FavoriteVacancy({
    required this.seekerId,
    required this.vacancyId,
    required this.addedAt,
    required this.user,
    required this.vacancy,
  });

  factory FavoriteVacancy.fromJson(Map<String, dynamic> json) {
    return FavoriteVacancy(
      seekerId: json['seeker_id'],
      vacancyId: json['vacancy_id'],
      addedAt: DateTime.parse(json['added_at']),
      user: User.fromJson(json['user']),
      vacancy: Vacancy.fromJson(json['vacancy']),
    );
  }

  Map<String, dynamic> toJson() => {
    'seeker_id': seekerId,
    'vacancy_id': vacancyId,
    'added_at': addedAt.toIso8601String(),
  };
}