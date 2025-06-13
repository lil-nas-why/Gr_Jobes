import 'package:gr_jobs/all_pages/models_supabase/region_model.dart';

class City {
  final int id;
  final int? regionId;
  final String name;
  final int? population;
  final DateTime? createdAt;
  final Region? region;

  City({
    required this.id,
    this.regionId,
    required this.name,
    this.population,
    this.createdAt,
    this.region,
  });

  factory City.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return City(
      id: json['id'] as int? ?? 0,
      regionId: json['region_id'] as int?,
      name: json['name'] as String? ?? 'Не указано',
      population: json['population'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      region: json['regions'] is Map<String, dynamic>
          ? Region.fromJson(json['regions'])
          : null,
    );
  }

  static City empty() => City(
    id: 0,
    name: 'Не указано',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (regionId != null) 'region_id': regionId,
    'name': name,
    if (population != null) 'population': population,
    if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    if (region != null) 'regions': region?.toJson(),
  };
}