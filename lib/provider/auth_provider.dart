import 'package:flutter/material.dart';
import 'package:mcq_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  Future login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future register(String email, String password) async {
    await _authService.register(email, password);
  }

  Future logout() async {
    await _authService.logout();
  }
}
