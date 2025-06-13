class EmploymentType {
  final int id;
  final String typeName;
  final String codeName;

  EmploymentType({
    required this.id,
    required this.typeName,
    required this.codeName,
  });

  factory EmploymentType.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return EmploymentType(
      id: json['id'] is int ? json['id'] : 0,
      typeName: json['type_name']?.toString() ?? 'Не указано',
      codeName: json['code_name']?.toString() ?? '',
    );
  }

  static EmploymentType empty() {
    return EmploymentType(
      id: 0,
      typeName: 'Не указано',
      codeName: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type_name': typeName,
    'code_name': codeName,
  };
}