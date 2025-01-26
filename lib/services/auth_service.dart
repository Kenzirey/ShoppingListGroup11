import 'package:supabase_flutter/supabase_flutter.dart';

// Handles Supabase communication


class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Signup
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Signup failed: User creation unsuccessful.');
      }

      print('Signup successful: ${response.user?.email}');
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw Exception('Login failed: Invalid session or user.');
      }

      print('Login successful: ${response.user?.email}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      print('Logout successful');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}

