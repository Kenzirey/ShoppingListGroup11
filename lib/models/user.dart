/// Represents the user model.
class User {
  // String userId; Guessing this will just be in Supabase.
  final String userName;
  final String email;
  final List<String> dietaryPreferences;
  //final String image; //path to the image (since we plan on letting them choose from pre-set images)

  User(
      {required this.userName,
      required this.email,
      required this.dietaryPreferences});
}
