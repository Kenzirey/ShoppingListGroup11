import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../providers/current_user_provider.dart';

/// A provider that exposes a single AuthController instance.
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref, AuthService());
});

/// A controller that handles authentication logic and user state updates in Riverpod.
class AuthController {
  final Ref ref;
  final AuthService _authService;

  AuthController(this.ref, this._authService);

  /// Creates a new user with email/password and updates the current user state
  Future<AppUser> signUp(
    String email,
    String password, {
    String? userName}) async {
    try {
      final user = await _authService.signUp(email, password, userName: userName);
      ref.read(currentUserProvider.notifier).state = user;
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// logges in existing user with email/password
  Future<AppUser> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      ref.read(currentUserProvider.notifier).state = user;
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logges in user via Google (or creates a profile if it doesnt exist)
  Future<AppUser> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogleNative();
      ref.read(currentUserProvider.notifier).state = user;
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logges out the current logged in user
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

/// Updates profile fields (name, avatar, dietary preferences) without requiring a password.
Future<AppUser> updateProfileWithoutPassword({
  String? newName,
  String? avatarUrl,
  List<String>? dietaryPreferences,
}) async {
  try {
    final updatedUser = await _authService.updateProfileWithoutPassword(
      newName: newName,
      avatarUrl: avatarUrl,
      dietaryPreferences: dietaryPreferences,
    );
    ref.read(currentUserProvider.notifier).state = updatedUser;
    return updatedUser;
  } catch (e) {
    rethrow;
  }
}

/// Changes the users password. (includes password verification.)
Future<void> updatePassword(String newPassword) async {
  try {
    await _authService.updatePassword(newPassword);
  } catch (e) {
    rethrow;
  }
}


  /// Sends reset password mail if the account is not google
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Confirms password reset from superbase url (new password)
  Future<void> verifyPasswordReset(String token, String newPassword) async {
    try {
      await _authService.verifyPasswordReset(token, newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
