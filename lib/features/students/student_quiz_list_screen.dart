import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_screen.dart';

class StudentQuizListScreen extends StatefulWidget {
  const StudentQuizListScreen({super.key});

  @override
  State<StudentQuizListScreen> createState() => _StudentQuizListScreenState();
}

class _StudentQuizListScreenState extends State<StudentQuizListScreen> {
  String? teacherId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacher();
  }

  Future<void> fetchTeacher() async {
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();

    setState(() {
      teacherId = doc['connectedTeacherId'];
      isLoading = false;
    });
  }

  Future<void> sendRetakeRequest(String quizId) async {
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    final existingRequest = await FirebaseFirestore.instance
        .collection('retakeRequests')
        .where('quizId', isEqualTo: quizId)
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Request already sent")));
      return;
    }

    await FirebaseFirestore.instance.collection('retakeRequests').add({
      'quizId': quizId,
      'studentId': studentId,
      'teacherId': teacherId,
      'status': 'pending',
      'requestedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Your request has been sent')));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (teacherId == null) {
      return const Scaffold(
        body: Center(child: Text("Waiting for teacher approval")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Available Quizzes")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('teacherId', isEqualTo: teacherId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No quizzes available"));
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(quiz['title']),
                  onTap: () async {
                    final studentId = FirebaseAuth.instance.currentUser!.uid;

                    final takenDoc = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(studentId)
                        .collection('takenQuizzes')
                        .doc(quiz.id)
                        .get();

                    final retakeDoc = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(studentId)
                        .collection('retakeAllowed')
                        .doc(quiz.id)
                        .get();

                    // First attempt
                    if (!takenDoc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(quizId: quiz.id),
                        ),
                      );
                    }
                    // Retake approved
                    else if (retakeDoc.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(quizId: quiz.id),
                        ),
                      );
                    }
                    // Already taken but no approval
                    else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Test already taken'),
                          content: const Text(
                            'Do you wish to request a retake?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await sendRetakeRequest(quiz.id);
                              },
                              child: const Text("Request Retake"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
