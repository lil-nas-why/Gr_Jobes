class WorkSchedule {
  final int id;
  final String scheduleName;
  final String codeName;

  WorkSchedule({
    required this.id,
    required this.scheduleName,
    required this.codeName,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id'],
      scheduleName: json['schedule_name'],
      codeName: json['code_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schedule_name': scheduleName,
    'code_name': codeName,
  };
}