import '../services/auth_service.dart';

// Manages logic between views and services

class AuthController {
  final AuthService _authService = AuthService();

  Future<void> signUp(String email, String password) async {
    try {
      await _authService.signUp(email, password);
      print('Signup successful');
    } catch (e) {
      print('Signup failed: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      print('Login successful');
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      print('Logout successful');
    } catch (e) {
      print('Logout failed: $e');
      rethrow;
    }
  }
}
