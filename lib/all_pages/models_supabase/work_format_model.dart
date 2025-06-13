class WorkFormat {
  final int id;
  final String formatName;
  final String codeName;

  WorkFormat({
    required this.id,
    required this.formatName,
    required this.codeName,
  });

  factory WorkFormat.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return WorkFormat(
      id: json['id'] is int ? json['id'] : 0,
      formatName: json['format_name']?.toString() ?? 'Не указано',
      codeName: json['code_name']?.toString() ?? '',
    );
  }

  static WorkFormat empty() {
    return WorkFormat(
      id: 0,
      formatName: 'Не указано',
      codeName: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'format_name': formatName,
    'code_name': codeName,
  };
}