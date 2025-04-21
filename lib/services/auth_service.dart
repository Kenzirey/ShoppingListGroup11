import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'package:shopping_list_g11/utils/error_utils.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '235387261747-j5fhreodgr19sfb6hb18n4hv9o4u1mui.apps.googleusercontent.com',
    serverClientId: '235387261747-4j0m8os04p7pdkcg9romdamosko3av1o.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// fetches the providers array from the profiles
  /// table for the given Supabase user ID.
  Future<List<String>> _loadProvidersForAuthId(String authId) async {
    try {
      final row = await _client
        .from('profiles')
        .select('providers')
        .eq('auth_id', authId)
        .maybeSingle();
      return List<String>.from(
        (row?['providers'] as List<dynamic>? ?? <String>[])
      );
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  Future<bool> _hasProvider(String authId, String provider) async {
    try {
      final provs = await _loadProvidersForAuthId(authId);
      return provs.contains(provider);
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

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
      return AppUser.fromMap(insertedData, supabaseUser.email ?? '');
    } on PostgrestException catch (e) {
      throw Exception(getUserFriendlyErrorMessage(Exception('Failed to create profile: ${e.message}')));
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
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
        throw Exception(getUserFriendlyErrorMessage(Exception('No profile found for this user.')));
      }
      return AppUser.fromMap(profileData, supabaseUser.email ?? '');
    } on PostgrestException catch (e) {
      throw Exception(getUserFriendlyErrorMessage(Exception('Error fetching profile: ${e.message}')));
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Signs in (or up) via Google and appends 'google' to providers[] if not present
  Future<AppUser> signInWithGoogleNative() async {
    try {
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
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Logs out
  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      await _client.auth.signOut();
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Updates profile fields that do not require password confirmation,
  /// such as user name, avatar URL, and dietary preferences.
  Future<AppUser> updateProfileWithoutPassword({
    String? newName,
    String? avatarUrl,
    List<String>? dietaryPreferences,
  }) async {
    try {
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
      return AppUser.fromMap(updatedData, supabaseUser.email ?? '');
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Changes the password for an account _that has an email/password identity_.
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in.');
      }
      final provs = await _loadProvidersForAuthId(user.id);
      if (!provs.contains('email')) {
        throw Exception('Cannot change password for Google‑only accounts.');
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Sends a password reset email if the account has an email/password identity.
  Future<void> resetPassword(String email) async {
    try {
      final row = await _client
        .from('profiles')
        .select('auth_id, providers')
        .eq('email', email)
        .maybeSingle();
      if (row == null) {
        throw Exception('No such user with email $email');
      }
      final rawProviders = row['providers'] as List<dynamic>? ?? [];
      final provs = rawProviders.map((p) => p.toString()).toList();
      if (!provs.contains('email')) {
        throw Exception('Password reset is not available for Google‑only accounts.');
      }
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Verifies password reset using a Supabase link.
  Future<void> verifyPasswordReset(String token, String newPassword) async {
    try {
      final updateResponse = await _client.auth.updateUser(UserAttributes(password: newPassword));
      if (updateResponse.user == null) {
        throw Exception('Failed to update password.');
      }
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }

  /// Checks whether a given email is associated with Google sign-in
  Future<bool> isGoogleUserByEmail(String email) async {
    try {
      final row = await _client.from('profiles').select('auth_id').eq('email', email).maybeSingle();
      if (row == null) return false;
      return await _hasProvider(row['auth_id'], 'google');
    } catch (e) {
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }
}

