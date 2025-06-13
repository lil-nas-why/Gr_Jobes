import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class Education {
  final int id;
  final String name;

  const Education({required this.id, required this.name});

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}