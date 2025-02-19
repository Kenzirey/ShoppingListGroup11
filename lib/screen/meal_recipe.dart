import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe.dart';

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

    // While loading in recipe for visual feedback.
    if (recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title for the recipe
            Text(
              recipe.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 12),

            // Time for recipe and serving size (person)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.totalTime,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.yields,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ingredients Section ⏬
            Column(
              children: [
                ListTileTheme(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 0,
                  child: ExpansionTile(
                    title: const Text(
                      'Ingredients',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    initiallyExpanded: true,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isExpanded = expanded;
                      });
                    },
                    children: [
                      // Wrap the ingredient list + that extra 16px space
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IngredientList(ingredients: recipe.ingredients),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider when ingredients are collapsed (the _ line)
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

            // Instructions
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
                ...recipe.instructions.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        step,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
