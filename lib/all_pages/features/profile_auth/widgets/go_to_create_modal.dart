import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/create_resume/pages/create_resume_steps_page.dart';

class ResumeCreationModal extends StatelessWidget {
  const ResumeCreationModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.22,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.create, size: 24),
                title: Text(
                  'Создать резюме с нуля',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumeCreationPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.content_copy, size: 24),
                title: Text(
                  'Дублировать существующее',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}