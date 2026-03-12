import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionScreen extends StatefulWidget {
  final String quizId;

  const AddQuestionScreen({super.key, required this.quizId});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();

  String correctAnswer = "A";

  Future<void> addQuestion() async {
    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .add({
          'question': questionController.text.trim(),
          'optionA': optionAController.text.trim(),
          'optionB': optionBController.text.trim(),
          'optionC': optionCController.text.trim(),
          'optionD': optionDController.text.trim(),
          'correctAnswer': correctAnswer,
          'marks': 1,
        });

    questionController.clear();
    optionAController.clear();
    optionBController.clear();
    optionCController.clear();
    optionDController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Question Added")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add MCQ Question"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("finish"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: "Question",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: optionAController,
              decoration: const InputDecoration(
                labelText: "Option A",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: optionBController,
              decoration: const InputDecoration(
                labelText: "Option B",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: optionCController,
              decoration: const InputDecoration(
                labelText: "Option C",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: optionDController,
              decoration: const InputDecoration(
                labelText: "Option D",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Select Correct Answer"),

            DropdownButton<String>(
              value: correctAnswer,
              items: const [
                DropdownMenuItem(value: "A", child: Text("A")),
                DropdownMenuItem(value: "B", child: Text("B")),
                DropdownMenuItem(value: "C", child: Text("C")),
                DropdownMenuItem(value: "D", child: Text("D")),
              ],
              onChanged: (value) {
                setState(() {
                  correctAnswer = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addQuestion,
              child: const Text("Add Question"),
            ),
          ],
        ),
      ),
    );
  }
}
