import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gr_jobs/all_pages/models_supabase/education_model.dart';

class EducationStep extends StatelessWidget {
  final int currentEducationLevel;
  final ValueChanged<int> onEducationLevelSelected; // Изменено на ValueChanged<int>

  const EducationStep({
    required this.currentEducationLevel,
    required this.onEducationLevelSelected, // Переименовано для ясности
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Какое у вас образование?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Education>>(
            future: _fetchEducations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Ошибка загрузки данных: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет данных'));
              }

              final educations = snapshot.data!;
              return ListView.builder(
                itemCount: educations.length,
                itemBuilder: (context, index) {
                  final education = educations[index];
                  final isSelected = education.id == currentEducationLevel;
                  return ListTile(
                    title: Text(education.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.green.shade600)
                        : Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () => onEducationLevelSelected(education.id), // Теперь передаем ID
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Education>> _fetchEducations() async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('educations')
          .select()
          .execute();

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => Education.fromJson(json))
            .toList();
      } else {
        throw Exception('Ошибка при получении данных об образовании');
      }
    } catch (e) {
      print('Ошибка при загрузке данных об образовании: $e');
      rethrow;
    }
  }
}