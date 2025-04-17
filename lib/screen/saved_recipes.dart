import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../controllers/saved_recipe_controller.dart';
import '../providers/recipe_provider.dart';
import '../providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

/// Screen that shows recipes that users have chosen to save for later.
/// Allows user to see how many portions recipe is for, as well as dietary information (lactose, vegan).
/// Also allows user to remove recipes from their saved list.
///
/// The screen is a [ConsumerStatefulWidget] that uses Riverpod for state management.
class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  ConsumerState<SavedRecipesScreen> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends ConsumerState<SavedRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null && currentUser.profileId != null) {
        await ref
            .read(savedRecipesControllerProvider)
            .fetchSavedRecipes(currentUser.profileId!);
      }
    });
  }

  void _showDeleteSnackBar({
    required BuildContext context,
    required dynamic user,
    required dynamic removedRecipe,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.zero, // edge-to edge here
      padding: EdgeInsets.zero,
      elevation: 0, // no shadow 😎
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 4),
      content: CustomSnackbar(
        title: 'Deleted!',
        message: 'The recipe has been removed.',
        actionText: 'UNDO',
        onAction: () {
          ref
              .read(savedRecipesControllerProvider)
              .addRecipe(user.profileId!, removedRecipe.recipe);
        },
        innerPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final savedRecipes = ref.watch(savedRecipesProvider);
    // Extract recipe names for the search bar suggestions.
    final recipeNames = savedRecipes.map((sr) => sr.recipe.name).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reusable search bar.
            CustomSearchBarWidget(
              suggestions: recipeNames,
              hintText: 'Search for recipes to add...',
              onSuggestionSelected: (selected) {
                debugPrint('Selected: $selected');
              },
            ),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final savedRecipe = savedRecipes[index];
                  final recipe = savedRecipe.recipe;
                  // Convert yields to an integer. so "4 servings" to only 4.
                  final yieldsDigits =
                      recipe.yields.replaceAll(RegExp(r'[^\d]'), '');
                  final servings = int.tryParse(yieldsDigits) ?? 1;

                  return Dismissible(
                    key: Key(recipe.name),
                    // Swipe from right-to-left.
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      final user = ref.read(currentUserProvider);
                      if (user == null) return;

                      final removedRecipe = savedRecipe;
                      // Remove the recipe.
                      ref
                          .read(savedRecipesControllerProvider)
                          .removeRecipe(user.profileId!, removedRecipe);

                      // Show the custom full‑width snackbar with inline UNDO.
                      _showDeleteSnackBar(
                        context: context,
                        user: user,
                        removedRecipe: removedRecipe,
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        final router = GoRouter.of(context);
                        ref.read(recipeProvider.notifier).state = recipe;
                        if (!mounted) return;
                        router.goNamed('recipe');
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              servings > 1 ? Icons.people : Icons.person,
                              size: 20,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$servings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                recipe.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // A delete icon button as an alternative.
                            IconButton(
                              iconSize: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              onPressed: () {
                                final user = ref.read(currentUserProvider);
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'You must be logged in to remove a recipe!'),
                                    ),
                                  );
                                  return;
                                }
                                ref
                                    .read(savedRecipesControllerProvider)
                                    .removeRecipe(user.profileId!, savedRecipe);
                                _showDeleteSnackBar(
                                  context: context,
                                  user: user,
                                  removedRecipe: savedRecipe,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
