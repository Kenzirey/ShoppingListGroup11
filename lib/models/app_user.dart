/// Represents the user model.
class AppUser {
  // String userId; Guessing this will just be in Supabase.
  final String userName;
  final String email;
  final List<String> dietaryPreferences;
  final String? avatarUrl;
  final String authId;
  final String provider;
  final String? googleAvatarUrl;

  String get name => userName;

  bool get isGoogleUser => provider.toLowerCase() == 'google';

  AppUser(
      {required this.userName,
      required this.email,
      required this.dietaryPreferences,
      this.avatarUrl,
      required this.authId,
      required this.provider,
      this.googleAvatarUrl,
});

factory AppUser.fromMap(Map<String, dynamic> map, String email) {
    final provider = map['provider']?.toString().toLowerCase() ?? 'email';

    return AppUser(
      authId: map['auth_id'] ?? '',
      userName: map['name'] ?? '',
      email: email,
      dietaryPreferences: map['dietary_preferences'] == null
          ? []
          : List<String>.from(map['dietary_preferences']),
      avatarUrl: map['avatar_url'] ?? '',
      googleAvatarUrl: map['google_avatar_url'] ?? '',
      provider: provider,
    );
}

}