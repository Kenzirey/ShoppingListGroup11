import '../services/auth_service.dart';
import '../models/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Manages logic between views and services


final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final AuthService _authService = AuthService();

  Future<AppUser> signUp(WidgetRef ref, String email, String password, {String? userName}) async {
    try {
      final user = await _authService.signUp(email, password, userName: userName);

      ref.read(currentUserProvider.notifier).state = user;

      return user;
    } catch (e) {
      rethrow;
    }
  }

  
  Future<AppUser> login(WidgetRef ref, String email, String password) async {
    try {
      final user = await _authService.login(email, password);


      ref.read(currentUserProvider.notifier).state = user;

      return user;
    } catch (e) {
      rethrow;
    }
  }

 Future<void> logout(WidgetRef ref) async {
  
  final currentUser = ref.read(currentUserProvider);
  final bool isGoogle = currentUser?.isGoogleUser ?? false;
  
  try {
    await _authService.logout(isGoogleUser: isGoogle);
    ref.read(currentUserProvider.notifier).state = null;
  } catch (e) {
    rethrow;
  }
}



 
  Future<AppUser> updateProfile({
    required WidgetRef ref,
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

      ref.read(currentUserProvider.notifier).state = updatedUser;
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }


  Future<AppUser> signInWithGoogle(WidgetRef ref) async {
    try {
      final user = await _authService.signInWithGoogleNative();
      ref.read(currentUserProvider.notifier).state = user;
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(WidgetRef ref, String newPassword) async {
    try {
      await _authService.changePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

}
