class EducationalInstitution {
  final int id;
  final String name;
  final int cityId;
  final bool accreditationStatus;

  EducationalInstitution({
    required this.id,
    required this.name,
    required this.cityId,
    required this.accreditationStatus,
  });

  factory EducationalInstitution.fromJson(Map<String, dynamic> json) {
    return EducationalInstitution(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
      accreditationStatus: json['accreditation_status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city_id': cityId,
    'accreditation_status': accreditationStatus,
  };
}