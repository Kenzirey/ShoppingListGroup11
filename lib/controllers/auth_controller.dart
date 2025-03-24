import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../providers/current_user_provider.dart';

/// A provider that exposes a single AuthController instance.
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// A controller that handles authentication logic and user state updates.
class AuthController {
  final Ref ref;

  final AuthService _authService = AuthService();

  AuthController(this.ref);

  /// Creates a new user account, stores it in 'profiles', and updates the currentUserProvider.
  Future<AppUser> signUp(
    String email,
    String password, {
    String? userName,
  }) async {
  try {
    final user = await _authService.signUp(email, password, userName: userName);
    
    final profileResponse = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('auth_id', user.authId)
        .maybeSingle();
    String? profileId;
    if (profileResponse != null) {
      profileId = profileResponse['id'] as String;
    }
    
    final updatedUser = user.copyWith(profileId: profileId);
    
    ref.read(currentUserProvider.notifier).state = updatedUser;
    return updatedUser;
  } catch (e) {
    rethrow;
  }
}

  /// Logs in a user via Supabase and updates the currentUserProvider.
Future<AppUser> login(String email, String password) async {
  try {
    final user = await _authService.login(email, password);

    final profileResponse = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('auth_id', user.authId)
        .maybeSingle();
    String? profileId;
    if (profileResponse != null) {
      profileId = profileResponse['id'] as String;
    }

    final updatedUser = user.copyWith(profileId: profileId);

    ref.read(currentUserProvider.notifier).state = updatedUser;
    return updatedUser;
  } catch (e) {
    rethrow;
  }
}




  /// Logs the user in with Google via Supabase, updating the currentUserProvider.
  Future<AppUser> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogleNative();
    final profileResponse = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('auth_id', user.authId)
        .maybeSingle();
    String? profileId;
    if (profileResponse != null) {
      profileId = profileResponse['id'] as String;
    }
    
    final updatedUser = user.copyWith(profileId: profileId);
    ref.read(currentUserProvider.notifier).state = updatedUser;
    return updatedUser;
  } catch (e) {
    rethrow;
  }
}
  /// Logs out the current user clearing their session and setting currentUserProvider to null.
  Future<void> logout() async {
    final currentUser = ref.read(currentUserProvider);
    final bool isGoogle = currentUser?.isGoogleUser ?? false;
    try {
      await _authService.logout(isGoogleUser: isGoogle);
      ref.read(currentUserProvider.notifier).state = null;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the users profile in Supabase.
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

      ref.read(currentUserProvider.notifier).state = updatedUser;
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Changes the users password (for non Google accounts), if they are logged in.
  Future<void> changePassword(String newPassword) async {
    try {
      await _authService.changePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
