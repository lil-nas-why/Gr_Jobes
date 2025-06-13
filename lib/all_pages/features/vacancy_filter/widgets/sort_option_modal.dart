import 'package:flutter/material.dart';

class SortModal extends StatelessWidget {
  final String currentSort;
  final void Function(String) onSortSelected;

  const SortModal({
    Key? key,
    required this.currentSort,
    required this.onSortSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.33,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            // Список опций сортировки
            Expanded(
              child: ListView(
                children: [
                  _buildSortOption(
                    title: 'По дате',
                    icon: Icons.calendar_today_rounded,
                    isSelected: currentSort == 'date',
                    onTap: () => onSortSelected('date'),
                  ),
                  _buildSortOption(
                    title: 'По возрастанию дохода',
                    icon: Icons.keyboard_arrow_up,
                    isSelected: currentSort == 'salary_asc',
                    onTap: () => onSortSelected('salary_asc'),
                  ),
                  _buildSortOption(
                    title: 'По убыванию дохода',
                    icon: Icons.keyboard_arrow_down,
                    isSelected: currentSort == 'salary_desc',
                    onTap: () => onSortSelected('salary_desc'),
                  ),
                  _buildSortOption(
                    title: 'По соответствию',
                    icon: Icons.check_circle_outline,
                    isSelected: currentSort == 'relevance',
                    onTap: () => onSortSelected('relevance'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        icon,
        color: isSelected ? Colors.green : Colors.black, // Иконка черная, если не выбрано
      ),
      onTap: onTap,
    );
  }
}