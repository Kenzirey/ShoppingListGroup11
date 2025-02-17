import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/src/widget/ingredient_list.dart';

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
  Widget build(BuildContext context) {
    final recipe = ref.watch(recipeProvider);

    if (recipe == null) {
      debugPrint("ERROR: Recipe data is missing.");
      return const Scaffold(
        body: Center(
          child: Text("Error: No recipe data available."),
        ),
      );
    }

    debugPrint("MealRecipeScreen received recipe: ${recipe.name}");

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
                        "• $step",
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
