// lib/controllers/recipe_controller.dart
import 'package:flutter/material.dart';
import 'package:shopping_list_g11/main.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller responsible for Supabase interaction for recipes.
/// Supports both persisting (add) and fetching recipes.
class RecipeController {
  final WidgetRef ref;

  RecipeController({required this.ref});

  /// Adds a recipe to the database if it doesn't already exist.
  Future<void> addRecipe(Recipe recipe) async {
    final existing = await supabase
        .from('recipes')
        .select('name')
        .ilike('name', recipe.name);

    try {
      if ((existing as List).isEmpty) {
        await supabase.from('recipes').insert({
          'name': recipe.name,
          'summary': recipe.summary,
          'prep_time': recipe.prepTime,
          'cook_time': recipe.cookTime,
          'total_time': recipe.totalTime,
          'yields': recipe.yields,
          'ingredients': recipe.ingredients,
          'instructions': recipe.instructions,
        });
        debugPrint("If you're seeing this, have a good day");
      } else {
        debugPrint("A recipe with the name '${recipe.name}' already exists.");
      }
    } catch (e) {
      debugPrint("Error adding recipe: $e");
    }
  }

  /// Fetches a recipe by name from the database
  /// and updates the [recipeProvider] state.
  Future<void> fetchRecipeByName(String name) async {
    try {
      final data = await supabase
          .from('recipes')
          .select()
          .eq('name', name)
          .single();

      final fetched = Recipe(
        name: data['name'] as String,
        summary: data['summary'] as String,
        prepTime: data['prep_time'] as String,
        cookTime: data['cook_time'] as String,
        totalTime: data['total_time'] as String,
        yields: data['yields'] as String,
        ingredients: List<String>.from(data['ingredients'] as List),
        instructions: List<String>.from(data['instructions'] as List),
      );

      ref.read(recipeProvider.notifier).state = fetched;
    } catch (e) {
      debugPrint("Error fetching recipe '$name': $e"); // will handle this ui-wise instead.
    }
  }
}
