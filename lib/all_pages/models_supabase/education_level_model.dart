class EducationLevel {
  final int id;
  final String levelName;
  final int? sortOrder;

  EducationLevel({
    required this.id,
    required this.levelName,
    this.sortOrder,
  });

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    return EducationLevel(
      id: json['id'],
      levelName: json['level_name'],
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'level_name': levelName,
    'sort_order': sortOrder,
  };
}