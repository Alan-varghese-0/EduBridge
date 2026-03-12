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

  Map<String, dynamic>? teacherData;
  String? teacherId;

  /// FIND TEACHER
  Future<void> findTeacher() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('referralCode', isEqualTo: codecontroller.text.trim())
        .get();

    if (result.docs.isEmpty) {
      setState(() {
        teacherData = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Teacher not found")));
      return;
    }

    setState(() {
      teacherData = result.docs.first.data();
      teacherId = result.docs.first.id;
    });
  }

  /// SEND REQUEST
  Future<void> sendRequest() async {
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
      appBar: AppBar(title: const Text("Teacher Connection")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Referral Code Input
            TextField(
              controller: codecontroller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter teacher referral code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// FIND BUTTON
            ElevatedButton(onPressed: findTeacher, child: const Text("Find")),

            const SizedBox(height: 30),

            /// SHOW TEACHER CARD
            if (teacherData != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person, size: 60),

                    const SizedBox(height: 10),

                    Text(
                      teacherData!['name'] ?? "Teacher",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(teacherData!['email'] ?? ""),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: sendRequest,
                      child: const Text("Send Request"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
