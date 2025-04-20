
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/recipe.dart';

/// Holds only the latest AI‑generated recipe inside ChatScreen.
/// So that we can navigate back to the chat screen and see the actual correct recipe.. Was not doing that before
final chatRecipeProvider = StateProvider<Recipe?>((ref) => null);
