import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_list_g11/controllers/auth_controller.dart';
import 'package:shopping_list_g11/models/app_user.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

final editAccountDetailsProvider =
    StateNotifierProvider<EditAccountDetailsNotifier, AsyncValue<void>>(
  (ref) => EditAccountDetailsNotifier(ref),
);

class EditAccountDetailsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EditAccountDetailsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> saveChanges({
    required String newName,
    required String currentPassword,
    required String newPassword,
    required List<String> selectedDiets,
    required AppUser currentUser,
  }) async {
    state = const AsyncValue.loading();

    final authController = ref.read(authControllerProvider);

    // If not a Google account and password fields are provided validate and change password.
    if (!currentUser.isGoogleUser &&
        currentPassword.isNotEmpty &&
        newPassword.isNotEmpty) {
      if (newPassword.length < 8) {
        throw Exception('Password must be at least 8 characters long.');
      }

      // Validate the current password by logging in.
      await authController.login(currentUser.email, currentPassword);

      // Then change the password
      await authController.changePassword(newPassword);
    }

    // Update dietary preferences if changed.
    final shouldUpdateProfile =
        selectedDiets.toString() != currentUser.dietaryPreferences.toString();
    if (shouldUpdateProfile) {
      await authController.updateProfile(
        avatarUrl: currentUser.avatarUrl,
        dietaryPreferences: selectedDiets,
      );
    }

    // Update name if changed.
    if (newName.isNotEmpty && newName != currentUser.name) {
      final updatedData = await Supabase.instance.client
          .from('profiles')
          .update({'name': newName})
          .eq('auth_id', currentUser.authId)
          .select()
          .maybeSingle();

      if (updatedData != null) {
        final updatedUser = AppUser.fromMap(updatedData, currentUser.email);
        ref.read(currentUserProvider.notifier).state = updatedUser;
      }
    }

    // Reset state to data after completeion
    state = const AsyncValue.data(null);
  }
}
