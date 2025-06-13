class JobSearchStatus {
  final int id;
  final String statusName;
  final String description;
  final int sortOrder;

  JobSearchStatus({
    required this.id,
    required this.statusName,
    required this.description,
    required this.sortOrder,
  });

  factory JobSearchStatus.fromJson(Map<String, dynamic> json) {
    return JobSearchStatus(
      id: json['id'] is int ? json['id'] : 0,
      statusName: json['status_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status_name': statusName,
    'description': description,
    'sort_order': sortOrder,
  };

  // Helper method to get display text
  String get displayText {
    switch (statusName) {
      case 'not_looking':
        return 'Не ищу работу';
      case 'actively_looking':
        return 'Активно ищу работу';
      case 'considering_offers':
        return 'Рассматриваю предложения';
      case 'open_to_offers':
        return 'Открыт к предложениям';
      case 'already_hired':
        return 'Уже устроился';
      default:
        return statusName;
    }
  }
}