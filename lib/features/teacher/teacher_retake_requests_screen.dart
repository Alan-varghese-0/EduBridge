import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherRetakeRequestsScreen extends StatelessWidget {
  final String teacherId;

  const TeacherRetakeRequestsScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retake requests'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('retakeRequests')
              .where('teacherId', isEqualTo: teacherId)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load retake requests.\nPlease try again later.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            final requests = snapshot.data?.docs ?? [];

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 40,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pending retake requests',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Students can request another attempt when time runs out.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final request = requests[index];

                return FutureBuilder<List<DocumentSnapshot>>(
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
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const ListTile(
                          title: Text('Loading request...'),
                        ),
                      );
                    }

                    if (!snap.hasData || snap.data!.length < 2) {
                      return const SizedBox.shrink();
                    }

                    final studentDoc = snap.data![0];
                    final quizDoc = snap.data![1];

                    final studentName = studentDoc['name'] ?? 'Student';
                    final quizTitle = quizDoc['title'] ?? 'Quiz';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.secondary.withOpacity(0.1),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        title: Text(
                          quizTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Requested by $studentName',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Reject',
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () {
                                rejectRequest(request.id);
                              },
                            ),
                            IconButton(
                              tooltip: 'Approve retake',
                              icon: Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                approveRequest(request);
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
