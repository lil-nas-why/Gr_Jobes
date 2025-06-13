class ExperienceOption {
  final int id;
  final int minYears;
  final int? maxYears;
  final String name;
  final DateTime createdAt;

  ExperienceOption({
    required this.id,
    required this.minYears,
    this.maxYears,
    required this.name,
    required this.createdAt,
  });

  factory ExperienceOption.fromJson(Map<String, dynamic> json) {
    return ExperienceOption(
      id: json['id'] as int,
      minYears: json['min_years'] as int,
      maxYears: json['max_years'] as int?,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'min_years': minYears,
    'max_years': maxYears,
    'name': name,
    'created_at': createdAt.toIso8601String(),
  };
}