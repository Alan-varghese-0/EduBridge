import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConnectTeacherScreen extends StatefulWidget {
  const ConnectTeacherScreen({super.key});

  @override
  State<ConnectTeacherScreen> createState() => _ConnectTeacherScreenState();
}

class _ConnectTeacherScreenState extends State<ConnectTeacherScreen> {
  final codecontroller = TextEditingController();
  Future<void> sendRequest() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('referralCode', isEqualTo: codecontroller.text.trim())
        .get();

    if (result.docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Teacher not found")));
      return;
    }

    final teacherId = result.docs.first.id;
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('connectionRequests').add({
      'studentId': studentId,
      'teacherId': teacherId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request Sent")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextField(controller: codecontroller),
            ElevatedButton(
              onPressed: sendRequest,
              child: const Text('connect'),
            ),
          ],
        ),
      ),
    );
  }
}
