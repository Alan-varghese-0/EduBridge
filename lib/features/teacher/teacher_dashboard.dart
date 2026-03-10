import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mcq_app/features/auth/login_screen.dart';
import 'package:mcq_app/features/teacher/create_qiuz_screen.dart';
import 'package:mcq_app/features/teacher/teacher_request_screen.dart';
import 'package:mcq_app/features/teacher/teacher_retake_requests_screen.dart';
import 'package:mcq_app/features/teacher/teacher_studemts_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TeacherRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateQiuzScreen()),
                );
              },
              child: const Text('Create Quiz'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
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

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeacherRetakeRequestsScreen(teacherId: teacherId),
                  ),
                );
              },
              child: const Text("Student Retake Requests"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
