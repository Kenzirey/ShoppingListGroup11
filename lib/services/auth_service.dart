import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

// Handles Supabase communication


class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Signup
 Future<AppUser> signUp(String email, String password, {String? userName}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Signup failed: User creation unsuccessful.');
      }

      final insertedData = await _client
          .from('profiles')
          .insert({
            'auth_id': supabaseUser.id,
            'name': userName ?? '',
            'dietary_preferences': [],
          })
          .select()
          .single(); 

      if (insertedData == null) {
        throw Exception('Signup failed: No profile data returned.');
      }

      final newUser = AppUser.fromMap(insertedData, supabaseUser.email ?? '');
      print('Signup successful: ${newUser.email}');
      return newUser;
    } 
    on PostgrestException catch (e) {
      throw Exception('Failed to create profile: ${e.message}');
    } 
    catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Login
  Future<AppUser> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final session = response.session;
      final supabaseUser = response.user;
      if (session == null || supabaseUser == null) {
        throw Exception('Login failed: Invalid session or user.');
      }

      final profileData = await _client
          .from('profiles')
          .select()
          .eq('auth_id', supabaseUser.id)
          .maybeSingle(); 

      if (profileData == null) {
        throw Exception('No profile found for this user.');
      }

      final loggedInUser = AppUser.fromMap(profileData, supabaseUser.email ?? '');
      print('Login successful: ${loggedInUser.email}');
      return loggedInUser;
    } 
    on PostgrestException catch (e) {
      throw Exception('Error fetching profile: ${e.message}');
    } 
    catch (e) {
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

  //modify profile
  Future<AppUser> updateProfile({
  required String authId,
  String? avatarUrl,
  List<String>? dietaryPreferences,
}) async {
  try {
    final updates = <String, dynamic>{};
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (dietaryPreferences != null) updates['dietary_preferences'] = dietaryPreferences;

    if (updates.isEmpty) {
      throw Exception('No fields to update.');
    }

    final updatedData = await _client
        .from('profiles')
        .update(updates)
        .eq('auth_id', authId)
        .select()
        .maybeSingle();

    if (updatedData == null) {
      throw Exception('Profile update failed or no profile found.');
    }

    final supabaseUser = _client.auth.currentUser;
    final email = supabaseUser?.email ?? 'unknown@email';

    return AppUser.fromMap(updatedData, email);
  } 
  on PostgrestException catch (e) {
    throw Exception('Error updating profile: ${e.message}');
  } 
  catch (e) {
    throw Exception('Error updating profile: $e');
  }
}
}

