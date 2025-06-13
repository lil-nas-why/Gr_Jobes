import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:gr_jobs/all_pages/models_supabase/work_schedule_model.dart';

class WorkScheduleModal extends StatefulWidget {
  final List<String> selectedSchedules;

  const WorkScheduleModal({
    Key? key,
    required this.selectedSchedules,
  }) : super(key: key);

  @override
  State<WorkScheduleModal> createState() => _WorkScheduleModalState();
}

class _WorkScheduleModalState extends State<WorkScheduleModal> {
  late List<String> _selectedSchedules;

  @override
  void initState() {
    super.initState();
    _selectedSchedules = List.from(widget.selectedSchedules);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VacancyProvider>(context);
    final workSchedules = provider.workSchedules;

    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Выберите из списка',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[300] ?? Colors.grey),
            Expanded(
              child: workSchedules.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: workSchedules.map((schedule) {
                  final isSelected = _selectedSchedules.contains(schedule.scheduleName);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSchedules.remove(schedule.scheduleName);
                          } else {
                            _selectedSchedules.add(schedule.scheduleName);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300] ?? Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  schedule.scheduleName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(height: 1, color: Colors.grey[300] ?? Colors.grey),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedSchedules);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Применить'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSchedules.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Сбросить'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}