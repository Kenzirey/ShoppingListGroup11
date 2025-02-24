import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/main.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';

/// Controller responsible for Supabase interaction for recipes.
/// It loads a recipe from Supabase and updates the [recipeProvider].
/// If loading from Supabase fails, defaults to a 'default' recipe.
class RecipeController {
  final WidgetRef ref;

  RecipeController({required this.ref});

  /// Attempts to load one (any) recipe from Supabase.
  /// Primarily for testing right now!
  /// If a recipe is already present (for example, redirected via the chat bot),
  /// no action is taken.
  /// On error, the provider is updated with a default recipe.
  Future<void> loadRecipeFromSupabase() async {
    if (ref.read(recipeProvider) != null) return;

    try {
      // Fetch a single recipe from the 'recipes' table.
      // Temporary setup with limit and single.
      final data = await supabase.from('recipes').select().limit(1).single();

      final fetchedRecipe = Recipe(
        name: data['name'] as String,
        summary: data['summary'] as String,
        prepTime: data['prep_time'] as String,
        cookTime: data['cook_time'] as String,
        totalTime: data['total_time'] as String,
        yields: data['yields'] as String,
        ingredients: List<String>.from(data['ingredients'] as List),
        instructions: List<String>.from(data['instructions'] as List),
      );

      // Update provider with the new recipe
      ref.read(recipeProvider.notifier).state = fetchedRecipe;
    } catch (e) {
      debugPrint(
          "Error fetching recipe from Supabase: $e"); // temporary debugging
      ref.read(recipeProvider.notifier).state = _defaultRecipe();
    }
  }

  /// Adds a recipe to the database, if it doesn't currently exist.
  Future<void> addRecipe(Recipe recipe) async {
    // Query Supabase to check for an existing recipe with the same name (not case sensitive).
    final existing = await supabase
        .from('recipes')
        .select('name')
        .ilike('name', recipe.name);

    try {
      // If no recipe exists, insert the new one.
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

  /// Returns the default recipe (for testing/development stage only).
  Recipe _defaultRecipe() {
    return Recipe(
      name: "Pesto Pasta",
      prepTime: '1 min',
      cookTime: '59 min',

      totalTime: "Over 60 min",
      summary: 'test',
      yields: "4 Personer",
      ingredients: [
        "Tonys salte tårer",
        "Sitronsaft",
        "Hvitløk",
        "Basilikum",
        "Revet parmesan",
        "Flaksalt",
        "Olivenolje",
        "250 g hvetemel gjerne fint pastamel eller durumhvete",
        "0,5 ts salt",
        "2 stk. egg",
        "2 stk. eggeplomme",
      ],
      instructions: [
        "Rist pinjekjerner i en tørr stekepanne til de er lett gylne.",
        "Ha alle ingrediensene i en foodprosessor og kjør til pestoen er jevn.",
        "Kok pasta etter anvisning på pakken.",
        "Bland pastaen med pestoen og server.",
      ],
    );
  }
}
