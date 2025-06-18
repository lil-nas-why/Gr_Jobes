import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/job_search_status_model.dart';

class StatusCard extends StatefulWidget {
  final User user;
  final Function(String?) onStatusChanged;

  const StatusCard({
    Key? key,
    required this.user,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _StatusCardState createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  late String? _currentStatus;

  @override
  void initState() {
    super.initState();

    _currentStatus = widget.user.jobSearchStatus?.statusName;
  }

  @override
  void didUpdateWidget(StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.jobSearchStatus?.statusName != oldWidget.user.jobSearchStatus?.statusName) {
      setState(() {
        _currentStatus = widget.user.jobSearchStatus?.statusName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: _showStatusModal,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 16, right: 16, bottom: 16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Статус поиска работы',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getStatusLabel(_currentStatus),
                      style: TextStyle(color: _getStatusColor(_currentStatus)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Не указано';
    switch (status) {
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
        return 'Не указано';
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null || status.isEmpty) return Colors.orange;
    switch (status) {
      case 'not_looking':
        return Colors.orange;
      case 'actively_looking':
      case 'considering_offers':
      case 'open_to_offers':
        return Colors.green;
      case 'already_hired':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  void _showStatusModal() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    final allStatuses = [
      JobSearchStatus(id: 1, statusName: 'not_looking', description: '', sortOrder: 1),
      JobSearchStatus(id: 2, statusName: 'actively_looking', description: '', sortOrder: 2),
      JobSearchStatus(id: 3, statusName: 'considering_offers', description: '', sortOrder: 3),
      JobSearchStatus(id: 4, statusName: 'open_to_offers', description: '', sortOrder: 4),
      JobSearchStatus(id: 5, statusName: 'already_hired', description: '', sortOrder: 5),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ваш статус поиска',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: allStatuses.length,
                    itemBuilder: (context, index) {
                      final status = allStatuses[index];
                      final isSelected = status.statusName == _currentStatus;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              width: isSelected ? 2.0 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                _getStatusLabel(status.statusName),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            onTap: () {
                              _updateStatus(context, status.statusName);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    });
  }

  void _updateStatus(BuildContext context, String newStatus) {
    Navigator.pop(context);
    setState(() {
      _currentStatus = newStatus;
    });
    widget.onStatusChanged(newStatus);
  }
}