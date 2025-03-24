import 'package:shopping_list_g11/models/recipe.dart';

/// Model for the saved recipe which connects a recipe with a user.
class SavedRecipe {
  final Recipe recipe;
  final String userId;
  final String recipeId;

  SavedRecipe({
    required this.recipe,
    required this.userId,
    required this.recipeId,
  });
}