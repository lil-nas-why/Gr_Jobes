class Agency {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;

  Agency({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
  });

  factory Agency.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Agency(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rating: json['rating'] is num ? json['rating'].toDouble() : 0.0,
      reviewCount: json['review_count'] is int ? json['review_count'] : 0,
    );
  }

  static Agency empty() {
    return Agency(
      id: '',
      name: 'Не указано',
      rating: 0.0,
      reviewCount: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rating': rating,
    'review_count': reviewCount,
  };
}