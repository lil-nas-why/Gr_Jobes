import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/agency_model.dart';

class Review {
  final String id;
  final String agencyId;
  final String userId;
  final int rating;
  final String comment;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;

  final Agency agency;
  final User user;

  Review({
    required this.id,
    required this.agencyId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.agency,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'agency_id': agencyId,
    'user_id': userId,
    'rating': rating,
    'comment': comment,
    'is_anonymous': isAnonymous,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}