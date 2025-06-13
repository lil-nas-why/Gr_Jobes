import 'package:flutter/material.dart';

class ResponsesPage extends StatelessWidget {
  const ResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(),
      body: const Center(
        child: Text(
          'Ваши отклики',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}