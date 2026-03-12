import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mcq_app/core/utility/app_gradients.dart';
import 'package:mcq_app/services/auth_service.dart';
import 'package:mcq_app/services/firestore_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final namecontroller = TextEditingController();

  final subjectController = TextEditingController();
  final orgController = TextEditingController();

  bool teacherMode = false;
  bool isLoading = false;

  String generateCode() {
    return (1000000 + Random().nextInt(9000000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add, size: 80, color: Colors.white),
                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// NAME
                  TextField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// EMAIL
                  TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD
                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON TO BECOME TEACHER
                  if (!teacherMode)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          teacherMode = true;
                        });
                      },
                      icon: const Icon(Icons.school),
                      label: const Text("Become Teacher (14-Day Trial)"),
                    ),

                  /// TEACHER FIELDS
                  if (teacherMode) ...[
                    const SizedBox(height: 20),

                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Subject",
                        prefixIcon: const Icon(Icons.menu_book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: orgController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Organization / School",
                        prefixIcon: const Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  /// REGISTER BUTTON
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            final auth = AuthService();
                            final fs = FirestoreServices();

                            final user = await auth.register(
                              emailcontroller.text.trim(),
                              passwordcontroller.text.trim(),
                            );

                            if (user != null) {
                              final now = DateTime.now();
                              final trialEnd = now.add(
                                const Duration(days: 14),
                              );

                              await fs.createuser(
                                uid: user.uid,
                                name: namecontroller.text.trim(),
                                email: emailcontroller.text.trim(),
                                role: teacherMode ? "teacher_trial" : "student",
                                referralCode: teacherMode
                                    ? generateCode()
                                    : null,
                                subject: teacherMode
                                    ? subjectController.text.trim()
                                    : null,
                                organization: teacherMode
                                    ? orgController.text.trim()
                                    : null,
                                trialStart: teacherMode ? now : null,
                                trialEnd: teacherMode ? trialEnd : null,
                              );
                            }

                            setState(() => isLoading = false);

                            Navigator.pop(context);
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
