import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherRequestsScreen extends StatelessWidget {
  const TeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Student Requests")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('connectionRequests')
            .where('teacherId', isEqualTo: teacherId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return ListTile(
                title: Text("Student ID: ${request['studentId']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () =>
                          approveRequest(request.id, request['studentId']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectRequest(request.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> approveRequest(String requestId, String studentId) async {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('connectionRequests')
        .doc(requestId)
        .update({'status': 'approved'});

    await FirebaseFirestore.instance.collection('users').doc(studentId).update({
      'connectedTeacherId': teacherId,
    });
  }

  Future<void> rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('connectionRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }
}
