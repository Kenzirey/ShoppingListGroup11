import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            'provider': 'email',
            
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
 Future<void> logout({bool isGoogleUser = false}) async {
  try {
    if (isGoogleUser) {
      final googleSignIn = GoogleSignIn(
        clientId: '235387261747-j5fhreodgr19sfb6hb18n4hv9o4u1mui.apps.googleusercontent.com',
        scopes: <String>['email', 'profile'],
      );
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
    }
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

  Future<AppUser> signInWithGoogleNative() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '235387261747-j5fhreodgr19sfb6hb18n4hv9o4u1mui.apps.googleusercontent.com',  // iOS Client ID
    serverClientId: '235387261747-4j0m8os04p7pdkcg9romdamosko3av1o.apps.googleusercontent.com', // Web Client ID
    scopes: <String>['email', 'profile'],
  );

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) {
    throw Exception('Google Sign-In canceled');
  }

  final googleAuth = await googleUser.authentication;
  final idToken = googleAuth.idToken;
  final accessToken = googleAuth.accessToken;

  if (idToken == null || accessToken == null) {
    throw Exception('No idToken or accessToken from Google');
  }

  await _client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );

  final supabaseUser = _client.auth.currentUser;
  if (supabaseUser == null) {
    throw Exception('Supabase user is null after Google sign-in');
  }

  Map<String, dynamic>? profileData;
  for (int i = 0; i < 3; i++) {
    profileData = await _client
        .from('profiles')
        .select()
        .eq('auth_id', supabaseUser.id)
        .maybeSingle();

    if (profileData != null) break;
    await Future.delayed(const Duration(seconds: 2));
  }

  profileData ??= await _client.from('profiles').insert({
    'auth_id': supabaseUser.id,
    'name': googleUser.displayName ?? '',
    'avatar_url': googleUser.photoUrl ?? '',
    'dietary_preferences': [],
    'provider': 'google',
  }).select().single();

  final loggedInUser = AppUser.fromMap(profileData, supabaseUser.email ?? '');
  print('Google Sign-In successful: ${loggedInUser.email}');
  return loggedInUser;
}


  Future<void> changePassword(String newPassword) async {
    try {
      final supabaseUser = _client.auth.currentUser;
      if (supabaseUser == null) {
        throw Exception('No user logged in.');
      }

      final profileData = await _client
          .from('profiles')
          .select()
          .eq('auth_id', supabaseUser.id)
          .maybeSingle();

      if (profileData == null) {
        throw Exception('No profile found for this user.');
      }

      if (profileData['provider'] == 'google') {
        throw Exception('Cannot change password for Google accounts.');
      }

      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      print('Password updated successfully.');
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

}

