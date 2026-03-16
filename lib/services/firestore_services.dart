import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createuser({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? referralCode,
    String? subject,
    String? organization,
    DateTime? trialStart,
    DateTime? trialEnd,
  }) async {
    await _db.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "role": role,
      "referralCode": referralCode,
      "subject": subject,
      "organization": organization,
      "trialStart": trialStart != null ? Timestamp.fromDate(trialStart) : null,
      "trialEnd": trialEnd != null ? Timestamp.fromDate(trialEnd) : null,
      "connectedTeacherId": null,
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> connectTeacher(String studentId, String teacherId) async {
    await _db.collection("users").doc(studentId).update({
      'connectedTeacherId': teacherId,
    });
  }

  Future<String> createQuiz(String teacherId, String quizTitle) async {
    final doc = await _db.collection("quizzes").add({
      'teacherId': teacherId,
      'title': quizTitle,
      'createdAt': Timestamp.now(),
    });

    return doc.id;
  }
}
