import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/saved_recipe_controller.dart';
import '../providers/recipe_provider.dart';
import '../providers/saved_recipe_provider.dart';

/// Screen that shows recipes that users have chosen to save for later.
/// Allows user to see how many portions recipe is for, as well as dietary information (lactose, vegan).
class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  ConsumerState<SavedRecipesScreen> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends ConsumerState<SavedRecipesScreen> {
  @override
  Widget build(BuildContext context) {
    // Dynamically get saved recipes from the provider.
    final savedRecipes = ref.watch(savedRecipesProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Recipes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64.0),
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final savedRecipe = savedRecipes[index];
                  final recipe = savedRecipe.recipe;
                  /// Inkwell, so that entire "item" is clickable, and adds the recipe
                  return InkWell(
                    onTap: () async {
                      final router = GoRouter.of(context);
                      // This now sets the 'active' recipe to the one clicked on in saved recipe list.
                      ref.read(recipeProvider.notifier).state =
                          savedRecipe.recipe;

                      if (!mounted) return;
                      router.goNamed('recipe');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                // to remove the 'servings' text from the response, as it is not necessary for this screen :)
                                recipe.yields.replaceAll(RegExp(r'[^\d]'), ''),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.people,
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: recipe.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            onPressed: () {
                              // Use the controller to remove the saved recipe.
                              SavedRecipesController(ref: ref)
                                  .removeRecipe(savedRecipe);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Action button placed within the padding at the bottom right.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // should we have this button? search? list?
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.tertiary,
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
