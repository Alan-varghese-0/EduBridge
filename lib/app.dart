import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mcq_app/features/auth/login_screen.dart';
import 'package:mcq_app/features/students/student_dashboard.dart';
import 'package:mcq_app/features/teacher/teacher_dashboard.dart';
import 'package:mcq_app/provider/auth_provider.dart' as local_auth;
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => local_auth.AuthProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _RootScreen(),
      ),
    );
  }
}

/// Decides whether to show login or go straight to the correct dashboard.
class _RootScreen extends StatelessWidget {
  const _RootScreen();

  Future<Widget> _resolveStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    // Not logged in → go to login
    if (user == null) {
      return const LoginScreen();
    }

    // Logged in → look up role and route to the proper dashboard
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = doc.data()?['role'];

    if (role == 'teacher') {
      return const TeacherDashboard();
    } else if (role == 'student') {
      return const StudentDashboard();
    }

    // Fallback to login if role is missing or unexpected
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong. Please restart the app.'),
            ),
          );
        }

        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}
