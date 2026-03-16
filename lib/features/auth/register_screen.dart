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
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    subjectController.dispose();
    orgController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (namecontroller.text.isEmpty ||
        emailcontroller.text.isEmpty ||
        passwordcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (teacherMode &&
        (subjectController.text.isEmpty || orgController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete teacher details")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final auth = AuthService();
      final fs = FirestoreServices();

      final user = await auth.register(
        emailcontroller.text.trim(),
        passwordcontroller.text.trim(),
      );

      if (user == null) throw Exception("Registration failed");

      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 14));

      await fs.createuser(
        uid: user.uid,
        name: namecontroller.text.trim(),
        email: emailcontroller.text.trim(),
        role: teacherMode ? "teacher_trial" : "student",
        referralCode: teacherMode ? generateCode() : null,
        subject: teacherMode ? subjectController.text.trim() : null,
        organization: teacherMode ? orgController.text.trim() : null,
        trialStart: teacherMode ? now : null,
        trialEnd: teacherMode ? trialEnd : null,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration inputStyle(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
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

                  TextField(
                    controller: namecontroller,
                    decoration: inputStyle("Name", Icons.person),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailcontroller,
                    decoration: inputStyle("Email", Icons.email),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: inputStyle("Password", Icons.lock),
                  ),

                  const SizedBox(height: 20),

                  if (!teacherMode)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          teacherMode = true;
                        });
                      },
                      icon: const Icon(Icons.school),
                      label: const Text("Become Teacher (14-Day Trial)"),
                    ),

                  if (teacherMode) ...[
                    const SizedBox(height: 20),

                    TextField(
                      controller: subjectController,
                      decoration: inputStyle("Subject", Icons.menu_book),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: orgController,
                      decoration: inputStyle(
                        "Organization / School",
                        Icons.school,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: isLoading ? null : registerUser,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 16),
                          ),
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
