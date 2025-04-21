import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;


    final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:       '235387261747-j5fhreodgr19sfb6hb18n4hv9o4u1mui.apps.googleusercontent.com',
    serverClientId: '235387261747-4j0m8os04p7pdkcg9romdamosko3av1o.apps.googleusercontent.com',
    scopes:         ['email', 'profile'],
  );

  /// Creates a new user in Supabase and a profile in 'profiles'
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
            'providers': ['email'], 
            'email': supabaseUser.email,

          })
          .select()
          .single();

      final newUser = AppUser.fromMap(insertedData, supabaseUser.email ?? '');
      return newUser;

    } on PostgrestException catch (e) {
      throw Exception('Failed to create profile: ${e.message}');
    } catch (e) {
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

      final supabaseUser = response.user;
      if (supabaseUser == null) {
        throw Exception('Login failed: Invalid user.');
      }

      final profileData = await _client
          .from('profiles')
          .select()
          .eq('auth_id', supabaseUser.id)
          .maybeSingle(); 

      if (profileData == null) {
        throw Exception('No profile found for this user.');
      }

      return AppUser.fromMap(profileData, supabaseUser.email ?? '');
    } on PostgrestException catch (e) {
      throw Exception('Error fetching profile: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Signs in (or up) via Google and appends 'google' to providers[] if not present
  Future<AppUser> signInWithGoogleNative() async {

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign‑In canceled');
    }
    final auth = await googleUser.authentication;
    if (auth.idToken == null || auth.accessToken == null) {
      throw Exception('Missing Google tokens');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken!,
    );
    final supabaseUser = _client.auth.currentUser!;
    
    Map<String, dynamic>? profile = await _client
        .from('profiles')
        .select('*, providers')
        .eq('auth_id', supabaseUser.id)
        .maybeSingle();

    if (profile == null) {
      profile = await _client
          .from('profiles')
          .insert({
            'auth_id': supabaseUser.id,
            'email': supabaseUser.email,
            'name': googleUser.displayName ?? '',
            'providers': ['google'],
            'avatar_url': googleUser.photoUrl,
            'google_avatar_url': googleUser.photoUrl,
            'dietary_preferences': <String>[],
          })
          .select()
          .single();
    } else {

      final List<dynamic> existing = profile['providers'] as List<dynamic>;
      if (!existing.contains('google')) {
        existing.add('google');
        profile = await _client
            .from('profiles')
            .update({'providers': existing})
            .eq('auth_id', supabaseUser.id)
            .select()
            .single();
      }

      if ((profile['google_avatar_url'] as String?)?.isEmpty ?? true) {
        profile = await _client
            .from('profiles')
            .update({'google_avatar_url': googleUser.photoUrl})
            .eq('auth_id', supabaseUser.id)
            .select()
            .single();
      }
    }

    return AppUser.fromMap(profile, supabaseUser.email!);
  }

  /// Logs out
  Future<void> logout() async {

    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
    }

    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Supabase signOut failed: $e');
    }
  }


  /// Updates profile fields that do not require password confirmation,
  /// such as user name, avatar URL, and dietary preferences.
  Future<AppUser> updateProfileWithoutPassword({
    String? newName,
    String? avatarUrl,
    List<String>? dietaryPreferences,
  }) async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) {
      throw Exception('No user is currently logged in.');
    }

    final updates = <String, dynamic>{};
    if (newName != null) updates['name'] = newName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (dietaryPreferences != null) updates['dietary_preferences'] = dietaryPreferences;

    if (updates.isEmpty) {
      throw Exception('No fields to update.');
    }

    final updatedData = await _client
        .from('profiles')
        .update(updates)
        .eq('auth_id', supabaseUser.id)
        .select()
        .maybeSingle();

    if (updatedData == null) {
      throw Exception('Profile update failed or no profile found.');
    }

    final email = supabaseUser.email ?? 'unknown@email';
    return AppUser.fromMap(updatedData, email);
  }

  /// Changes the password for a non Google user.
  Future<void> updatePassword(String newPassword) async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) {
      throw Exception('No user logged in.');
    }

    // Fetch the profile to check if the user is a Google user
    final profileData = await _client
        .from('profiles')
        .select('providers')
        .eq('auth_id', supabaseUser.id)
        .maybeSingle();

    if (profileData == null) {
      throw Exception('No profile found for this user.');
    }
    final List<String> provs = List<String>.from(
      (profileData['providers'] as List<dynamic>?) ?? <String>[]
      );
      if (provs.contains('google')) {
        throw Exception('Cannot change password for Google accounts.');
      }

    // Update the users password
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Sends a password reset email if the user is not a Google user
  Future<void> resetPassword(String email) async {
    final isGoogle = await isGoogleUserByEmail(email);
    if (isGoogle) {
      throw Exception('Password reset is not available for Google accounts.');
    }
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Verifies password reset using a Supabase link.
  Future<void> verifyPasswordReset(String token, String newPassword) async {
    try {
      final updateResponse = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (updateResponse.user == null) {
        throw Exception('Failed to update password.');
      }
    } catch (e) {
      throw Exception('Password reset verification failed: $e');
    }
  }

  /// Checks whether a given email is associated with Google sign-in
  Future<bool> isGoogleUserByEmail(String email) async {
  final response = await _client
      .from('profiles')
      .select('providers')
      .eq('email', email)
      .maybeSingle();

  if (response == null) return false;

  final List<String> provs = List<String>.from(
    (response['providers'] as List<dynamic>?) ?? <String>[]
  );
  return provs.contains('google');

  }
}
