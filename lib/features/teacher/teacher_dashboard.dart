import 'package:flutter/material.dart';
import 'package:mcq_app/features/teacher/create_qiuz_screen.dart';
import 'package:mcq_app/features/teacher/teacher_request_screen.dart';
import 'package:mcq_app/features/teacher/teacher_studemts_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherRequestsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQiuzScreen()),
                );
              },
              child: Text('create quiz'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherStudentsScreen(),
                  ),
                );
              },
              child: const Text("View Students"),
            ),
          ),
        ],
      ),
    );
  }
}
