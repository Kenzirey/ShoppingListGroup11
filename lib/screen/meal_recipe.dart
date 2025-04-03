import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/saved_recipe.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/saved_recipe_controller.dart';
import '../models/recipe.dart';
import '../providers/current_user_provider.dart';
import '../providers/saved_recipe_provider.dart';

/// Screen for showing the recipe details for a meal.
/// with both ingredients and instructions.
class MealRecipeScreen extends ConsumerStatefulWidget {
  const MealRecipeScreen({super.key});

  @override
  ConsumerState<MealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends ConsumerState<MealRecipeScreen> {
  bool _isExpanded = true; // Track expansion state, initially expanded

  @override
  void initState() {
    super.initState();
    // If no recipe is present (none from chat bot, or from clicking a meal etc, fetch one from Supa. Temporary!)
    if (ref.read(recipeProvider) == null) {
      RecipeController(ref: ref).loadRecipeFromSupabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe? recipe = ref.watch(recipeProvider);

    // Show a progress indicator while the recipe is loading.
    if (recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final savedRecipes = ref.watch(savedRecipesProvider);
    // Check if the current recipe is already saved (comparing by recipe name for now).
    final isSaved = savedRecipes.any((sr) => sr.recipe.name == recipe.name);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title row with the recipe name and heart icon (for saving/unsaving recipe).
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  onPressed: () async {
                    final currentRecipe = ref.read(recipeProvider);
                    final currentUser = ref.read(currentUserProvider);
                    if (currentRecipe == null) return;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You must be logged in to save a recipe.'),
                        ),
                      );
                      return;
                    }
                    final savedRecipesController =
                        ref.read(savedRecipesControllerProvider);
                    if (isSaved) {
                      // Try to find the corresponding saved recipe.
                      SavedRecipe? savedRecipe;
                      try {
                        savedRecipe = savedRecipes.firstWhere(
                          (sr) => sr.recipe.name == currentRecipe.name,
                        );
                      } catch (e) {
                        savedRecipe = null;
                      }
                      if (savedRecipe != null) {
                        await savedRecipesController.removeRecipeByAuthId(
                          currentUser.authId,
                          savedRecipe,
                        );
                        // Need to set up a reusable scaffoldmessenger to reuse.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${currentRecipe.name} removed from saved recipes.',
                            ),
                          ),
                        );
                      }
                    } else {
                      await savedRecipesController.addRecipeByAuthId(
                        currentUser.authId,
                        currentRecipe,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('${currentRecipe.name} saved to your recipes.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row displaying prep time, cook time, and yields.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Prep time.
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.prepTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                // Cook time.
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.cookTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                // Yields (servings).
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.yields,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Ingredients Section with ExpansionTile.
            Column(
              children: [
                ListTileTheme(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 0,
                  child: ExpansionTile(
                    // Set a tilePadding with right padding to add extra space.
                    tilePadding: const EdgeInsets.only(left: 0, right: 12),
                    collapsedIconColor: Theme.of(context).colorScheme.tertiary,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: const Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isExpanded = expanded;
                      });
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          IngredientList(ingredients: recipe.ingredients),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider when ingredients are collapsed.
                Visibility(
                  visible: !_isExpanded,
                  child: Divider(
                    color: Theme.of(context).colorScheme.tertiary,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Instructions Section.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.instructions.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      step,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
