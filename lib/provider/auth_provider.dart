import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcq_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<User?> register(String email, String password) async {
    return await _authService.register(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
