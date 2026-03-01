import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mcq_app/features/teacher/add_question_screen.dart';
import 'package:mcq_app/services/firestore_services.dart';

class CreateQiuzScreen extends StatefulWidget {
  const CreateQiuzScreen({super.key});

  @override
  State<CreateQiuzScreen> createState() => _CreateQiuzScreenState();
}

class _CreateQiuzScreenState extends State<CreateQiuzScreen> {
  final titlecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('what is the title of quiz')),
      body: Center(
        child: Column(
          children: [
            TextField(controller: titlecontroller),
            ElevatedButton(
              onPressed: () async {
                final quizId = await FirestoreServices().createQuiz(
                  FirebaseAuth.instance.currentUser!.uid,
                  titlecontroller.text.trim(),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddQuestionScreen(quizId: quizId),
                  ),
                );
              },
              child: Text('Create Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
