import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRetakeRequestsScreen extends StatelessWidget {
  final String teacherId;

  const TeacherRetakeRequestsScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Retake Requests")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('retakeRequests')
            .where('teacherId', isEqualTo: teacherId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return FutureBuilder(
                future: Future.wait([
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(request['studentId'])
                      .get(),
                  FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(request['quizId'])
                      .get(),
                ]),
                builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snap) {
                  if (!snap.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final studentDoc = snap.data![0];
                  final quizDoc = snap.data![1];

                  final studentName = studentDoc['name'];
                  final quizTitle = quizDoc['title'];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text("Quiz: $quizTitle"),
                      subtitle: Text("Student: $studentName"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              approveRequest(request);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              rejectRequest(request.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> approveRequest(QueryDocumentSnapshot request) async {
    final studentId = request['studentId'];
    final quizId = request['quizId'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .collection('retakeAllowed')
        .doc(quizId)
        .set({'allowed': true, 'approvedAt': Timestamp.now()});

    await FirebaseFirestore.instance
        .collection('retakeRequests')
        .doc(request.id)
        .update({'status': 'approved'});
  }

  Future<void> rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('retakeRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }
}
