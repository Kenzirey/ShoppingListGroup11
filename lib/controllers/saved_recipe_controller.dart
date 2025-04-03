// controllers/saved_recipes_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_recipe.dart';
import '../providers/saved_recipe_provider.dart';
import '../models/recipe.dart';
import 'package:shopping_list_g11/main.dart';
import 'package:flutter/material.dart';



/// Controller for handle interaction of from riverpod with (supabase).
class SavedRecipesController {
   final Ref ref;
  SavedRecipesController({required this.ref});

  Future<void> fetchSavedRecipes(String userId) async {
    try {
      final List<dynamic> data = await supabase
          .from('saved_recipe')
          .select('saved_at, recipe_id, user_id, recipes(*)')
          .eq('user_id', userId);

      final newList = data.map((item) {
        final recipeData = item['recipes'];

        final recipe = Recipe(
          name: recipeData['name'] ?? '',
          summary: recipeData['summary'] ?? '',
          yields: recipeData['yields'] ?? '',
          prepTime: recipeData['prep_time'] ?? '',
          cookTime: recipeData['cook_time'] ?? '',
          totalTime: recipeData['total_time'] ?? '',
          ingredients: List<String>.from(recipeData['ingredients'] ?? []),
          instructions: List<String>.from(recipeData['instructions'] ?? []),
        );

        return SavedRecipe(
          recipe: recipe,
          userId: userId,
          recipeId: recipeData['id'] as String,
        );
      }).toList();

      ref.read(savedRecipesProvider.notifier).state = newList;
    } catch (e) {
    }
  }



 Future<void> addRecipeByAuthId(String authId, Recipe recipe) async {
    try {
      final profileResponse = await supabase
          .from('profiles')
          .select('id')
          .eq('auth_id', authId)
          .single();
      final profileId = profileResponse['id'] as String;

      await addRecipe(profileId, recipe);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addRecipe(String userId, Recipe recipe) async {
    try {
      final List existingList = await supabase
          .from('recipes')
          .select('id, name')
          .ilike('name', recipe.name);

      String recipeId;

      if (existingList.isEmpty) {
        final inserted = await supabase.from('recipes').insert({
          'user_id': userId,
          'name': recipe.name,
          'summary': recipe.summary,
          'yields': recipe.yields,
          'prep_time': recipe.prepTime,
          'cook_time': recipe.cookTime,
          'total_time': recipe.totalTime,
          'ingredients': recipe.ingredients,
          'instructions': recipe.instructions,
        }).select().single();

        recipeId = inserted['id'] as String;
      } else {
        recipeId = existingList.first['id'] as String;
      }

      await supabase.from('saved_recipe').upsert({
        'user_id': userId,
        'recipe_id': recipeId,
      });

      final currentList = ref.read(savedRecipesProvider);
      final alreadySaved = currentList.any((sr) => sr.recipeId == recipeId);

      if (!alreadySaved) {
        final newSaved = SavedRecipe(
          recipe: recipe,
          userId: userId,
          recipeId: recipeId,
        );
        ref.read(savedRecipesProvider.notifier).state = [
          ...currentList,
          newSaved,
        ];
      }
    } catch (e, st) {
      debugPrint('Feil i addRecipe: $e\n$st');
    }
  }

  Future<void> removeRecipe(String userId, SavedRecipe savedRecipe) async {
    try {
      await supabase
          .from('saved_recipe')
          .delete()
          .match({
            'user_id': userId,
            'recipe_id': savedRecipe.recipeId,
          });

      final currentList = ref.read(savedRecipesProvider);
      final newList = currentList
          .where((r) => r.recipeId != savedRecipe.recipeId)
          .toList();
      ref.read(savedRecipesProvider.notifier).state = newList;
    } catch (e, st) {
      debugPrint('Feil i removeRecipe: $e\n$st');
    }
  }

  /// Removes a recipe from the saved recipes list by using the auth ID.
  Future<void> removeRecipeByAuthId(String authId, SavedRecipe savedRecipe) async {
  try {
    final profileResponse = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_id', authId)
        .single();
    final profileId = profileResponse['id'] as String;
    await removeRecipe(profileId, savedRecipe);
  } catch (e, st) {
    debugPrint('Error in removeRecipeByAuthId: $e\n$st');
  }
}

}

final savedRecipesControllerProvider = Provider<SavedRecipesController>((ref) {
  return SavedRecipesController(ref: ref);
});