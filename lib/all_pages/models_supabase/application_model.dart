import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/resume_model.dart';

class Application {
  final String id;
  final String seekerId;
  final String vacancyId;
  final String resumeId;
  final String status;
  final String? coverLetter;
  final bool viewedByEmployer;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User seeker;
  final Vacancy vacancy;
  final Resume resume;

  Application({
    required this.id,
    required this.seekerId,
    required this.vacancyId,
    required this.resumeId,
    required this.status,
    this.coverLetter,
    required this.viewedByEmployer,
    required this.createdAt,
    required this.updatedAt,
    required this.seeker,
    required this.vacancy,
    required this.resume,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      seekerId: json['seeker_id'],
      vacancyId: json['vacancy_id'],
      resumeId: json['resume_id'],
      status: json['status'],
      coverLetter: json['cover_letter'],
      viewedByEmployer: json['viewed_by_employer'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      seeker: User.fromJson(json['seeker']),
      vacancy: Vacancy.fromJson(json['vacancy']),
      resume: Resume.fromJson(json['resume']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'seeker_id': seekerId,
    'vacancy_id': vacancyId,
    'resume_id': resumeId,
    'status': status,
    'cover_letter': coverLetter,
    'viewed_by_employer': viewedByEmployer,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}