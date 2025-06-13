class WeeklyStats {
  final int views;
  final int impressions;
  final int invitations;

  WeeklyStats({
    required this.views,
    required this.impressions,
    required this.invitations,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      views: json['views'] is int ? json['views'] : 0,
      impressions: json['impressions'] is int ? json['impressions'] : 0,
      invitations: json['invitations'] is int ? json['invitations'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'views': views,
    'impressions': impressions,
    'invitations': invitations,
  };

  static WeeklyStats empty() {
    return WeeklyStats(
      views: 0,
      impressions: 0,
      invitations: 0,
    );
  }
}