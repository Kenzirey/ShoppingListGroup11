/// Represents the user model.
class AppUser {
  // String userId; Guessing this will just be in Supabase.
  final String userName;
  final String email;
  final List<String> dietaryPreferences;
  //final String image; //path to the image (since we plan on letting them choose from pre-set images)

  AppUser(
      {required this.userName,
      required this.email,
      required this.dietaryPreferences,
});

factory AppUser.fromMap(Map<String, dynamic> map, String email) {
    return AppUser(
      userName: map['name'] ?? '',
      email: email,
      dietaryPreferences: map['dietary_preferences'] == null
          ? []
          : List<String>.from(map['dietary_preferences']),
    );
  }
}