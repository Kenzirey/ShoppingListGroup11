import '../services/auth_service.dart';
import '../models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Manages logic between views and services

class AuthController {
  final AuthService _authService = AuthService();

  Future<AppUser> signUp(String email, String password, {String? userName}) async {
    try {
      final user = await _authService.signUp(email, password, userName: userName);
      print('Signup successful: ${user.email}');
      return user;
    } catch (e) {
      print('Signup failed: $e');
      rethrow;
    }
  }

  
  Future<AppUser> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      print('Login successful: ${user.email}');
      return user;
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

  Future<AppUser> updateProfile({
  String? avatarUrl,
  List<String>? dietaryPreferences,
}) async {
  try {
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser == null) {
      throw Exception('No logged-in user found.');
    }

    final updatedUser = await _authService.updateProfile(
      authId: supabaseUser.id,
      avatarUrl: avatarUrl,
      dietaryPreferences: dietaryPreferences,
    );

    print('Profile updated: ${updatedUser.email}');
    return updatedUser;
  } catch (e) {
    print('Profile update failed: $e');
    rethrow;
  }
}
}
