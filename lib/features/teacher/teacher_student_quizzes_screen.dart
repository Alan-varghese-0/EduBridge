import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'teacher_submission_detail_screen.dart';

class TeacherStudentQuizzesScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const TeacherStudentQuizzesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$studentName · Attempts'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('submissions')
              .where('studentId', isEqualTo: studentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load attempts.\nPlease try again later.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            final submissions = snapshot.data?.docs ?? [];

            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No attempts yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Once $studentName attempts quizzes, they will appear here.',
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
              itemCount: submissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final submission = submissions[index];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(submission['quizId'])
                      .get(),
                  builder: (context, quizSnapshot) {
                    if (quizSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const ListTile(
                          title: Text('Loading quiz...'),
                        ),
                      );
                    }

                    if (!quizSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final quizData = quizSnapshot.data!;
                    final quizTitle = quizData['title'] ?? 'Quiz';
                    final score = submission['score'] ?? 0;
                    final total = submission['totalMarks'] ?? 0;

                    final doublePercent =
                        total == 0 ? 0.0 : (score as num) / (total as num);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.quiz_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          quizTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Score: $score / $total',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: doublePercent.clamp(0.0, 1.0).toDouble(),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              color: theme.colorScheme.primary,
                              minHeight: 4,
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherSubmissionDetailScreen(
                                quizId: submission['quizId'],
                                answers: Map<String, dynamic>.from(
                                  submission['answers'],
                                ),
                              ),
                            ),
                          );
                        },
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
}
