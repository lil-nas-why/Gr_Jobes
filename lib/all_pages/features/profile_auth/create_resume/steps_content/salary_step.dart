import 'package:flutter/material.dart';

class SalaryStep extends StatelessWidget {
  final int currentSalary;
  final String currentCurrency;
  final VoidCallback onNext;

  const SalaryStep({
    super.key,
    required this.currentSalary,
    required this.currentCurrency,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Доход',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentSalary > 0 ? '$currentSalary $currentCurrency' : 'Не указано',
                  style: TextStyle(
                    fontSize: 16,
                    color: currentSalary > 0 ? Colors.black : Colors.grey[600],
                  ),
                ),
                Icon(Icons.edit, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}