import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, String> selectedAnswers = {};
  bool isSubmitting = false;

  Future<void> submitQuiz(List<QueryDocumentSnapshot> questions) async {
    setState(() => isSubmitting = true);

    int score = 0;
    int totalMarks = 0;

    for (var question in questions) {
      int marks = (question['marks'] as num).toInt();

      totalMarks += marks;

      if (selectedAnswers[question.id] == question['correctAnswer']) {
        score += marks;
      }
    }

    final studentId = FirebaseAuth.instance.currentUser!.uid;

    final studentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();

    final teacherId = studentDoc['connectedTeacherId'];

    await FirebaseFirestore.instance.collection('submissions').add({
      'quizId': widget.quizId,
      'studentId': studentId,
      'teacherId': teacherId,
      'score': score,
      'totalMarks': totalMarks,
      'answers': selectedAnswers, // ✅ IMPORTANT
      'submittedAt': Timestamp.now(),
    });

    setState(() => isSubmitting = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Submitted"),
        content: Text("Your Score: $score / $totalMarks"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to quiz list
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .collection('questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}. ${question['question']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            buildOption(question, "A", question['optionA']),
                            buildOption(question, "B", question['optionB']),
                            buildOption(question, "C", question['optionC']),
                            buildOption(question, "D", question['optionD']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        submitQuiz(questions);
                      },
                      child: const Text("Submit Quiz"),
                    ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget buildOption(
    QueryDocumentSnapshot question,
    String optionKey,
    String optionText,
  ) {
    final questionId = question.id;

    return RadioListTile(
      value: optionKey,
      groupValue: selectedAnswers[questionId],
      onChanged: (value) {
        setState(() {
          selectedAnswers[questionId] = value!;
        });
      },
      title: Text("$optionKey. $optionText"),
    );
  }
}
