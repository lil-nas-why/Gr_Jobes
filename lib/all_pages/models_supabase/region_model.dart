class Region {
  final int id;
  final String name;
  final String country;
  final int? population;
  final DateTime? createdAt;

  Region({
    required this.id,
    required this.name,
    required this.country,
    this.population,
    this.createdAt,
  });

  factory Region.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return Region(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Не указано',
      country: json['country'] as String? ?? '',
      population: json['population'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static Region empty() {
    return Region(
      id: 0,
      name: 'Не указано',
      country: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    if (population != null) 'population': population,
    if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
  };
}