import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mcq_app/core/utility/app_gradients.dart';
import 'package:mcq_app/core/utility/page_trasition.dart';
import 'package:mcq_app/features/auth/login_screen.dart';
import 'package:mcq_app/features/students/connect_teacher_screen.dart';
import 'package:mcq_app/features/students/student_quiz_list_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Student Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                AppTransitions.fadeTransition(const LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Welcome text
                const Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                /// Total Questions Card
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('submissions')
                      .where('studentId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    int totalQuestions = 0;

                    for (var doc in docs) {
                      final answers = doc['answers'] as Map<String, dynamic>;
                      totalQuestions += answers.length;
                    }

                    return Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(.1),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.teal.withOpacity(.1),

                            child: const Icon(
                              Icons.question_answer,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Questions Answered",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "$totalQuestions Questions",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                /// View Quizzes Button
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.quiz),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    label: const Text(
                      "View Quizzes",
                      style: TextStyle(fontSize: 16),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        AppTransitions.fadeTransition(
                          const StudentQuizListScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                /// Connect Teacher Button
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),

                    label: const Text(
                      "Connect Teacher",
                      style: TextStyle(fontSize: 16),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        AppTransitions.fadeTransition(
                          const ConnectTeacherScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Quiz History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                /// Quiz History
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('submissions')
                        .where('studentId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "No quizzes taken yet",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          final quizTitle = data['quizTitle'] ?? "Quiz";
                          final score = data['score'] ?? 0;
                          final totalMarks = data['totalMarks'] ?? 0;

                          final answers =
                              data['answers'] as Map<String, dynamic>? ?? {};
                          final questionCount = answers.length;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(.08),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.teal.withOpacity(.1),
                                  child: const Icon(
                                    Icons.quiz_outlined,
                                    color: Colors.teal,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quizTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "Score: $score / $totalMarks",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),

                                      Text(
                                        "Questions: $questionCount",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Text(
                                    "$score",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
