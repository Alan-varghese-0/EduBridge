import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher_submission_detail_screen.dart';

class TeacherStudentQuizzesScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const TeacherStudentQuizzesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$studentName - Attempts")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('submissions')
            .where('studentId', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final submissions = snapshot.data!.docs;

          if (submissions.isEmpty) {
            return const Center(child: Text("No attempts yet"));
          }

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('quizzes')
                    .doc(submission['quizId'])
                    .get(),
                builder: (context, quizSnapshot) {
                  if (!quizSnapshot.hasData) {
                    return const ListTile(title: Text("Loading quiz..."));
                  }

                  final quizData = quizSnapshot.data!;
                  final quizTitle = quizData['title'];

                  return ListTile(
                    title: Text(quizTitle),
                    subtitle: Text(
                      "Score: ${submission['score']} / ${submission['totalMarks']}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherSubmissionDetailScreen(
                            quizId: submission['quizId'],
                            answers: Map<String, dynamic>.from(
                              submission['answers'],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
