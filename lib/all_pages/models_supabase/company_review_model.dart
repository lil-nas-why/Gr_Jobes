import 'package:gr_jobs/all_pages/models_supabase/review_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/agency_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';

class CompanyReview extends Review {
  final int companyId;

  CompanyReview({
    required super.id,
    required this.companyId,
    required super.agencyId,
    required super.userId,
    required super.rating,
    required super.comment,
    required super.isAnonymous,
    required super.createdAt,
    required super.updatedAt,
    required super.agency,
    required super.user,
  });

  factory CompanyReview.fromJson(Map<String, dynamic> json) {
    return CompanyReview(
      id: json['id'],
      companyId: json['company_id'],
      agencyId: json['agency_id'],
      userId: json['user_id'],
      rating: json['rating'],
      comment: json['comment'],
      isAnonymous: json['is_anonymous'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      agency: Agency.fromJson(json['agency']),
      user: User.fromJson(json['user']),
    );
  }
}