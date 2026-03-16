import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherRequestsScreen extends StatelessWidget {
  const TeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student connection requests'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('connectionRequests')
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
                  'Something went wrong.\nPlease try again later.',
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
                      Icons.inbox_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pending requests',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You’ll see student connection requests here.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
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
                final studentId = request['studentId'] as String? ?? '';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Student ID: $studentId',
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Wants to connect with you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                          onPressed: () => rejectRequest(request.id),
                        ),
                        IconButton(
                          tooltip: 'Accept',
                          icon: Icon(
                            Icons.check_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () =>
                              approveRequest(request.id, studentId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
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
