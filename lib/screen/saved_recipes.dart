import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/saved_recipe_controller.dart';
import '../providers/recipe_provider.dart';
import '../providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

/// Screen that shows recipes that users have chosen to save for later.
/// Allows user to see how many portions recipe is for, as well as dietary information (lactose, vegan).
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

  @override
  Widget build(BuildContext context) {

    final savedRecipes = ref.watch(savedRecipesProvider);

    // For the search bar suggestions, need to update to get it from supabase.
    final recipeNames = savedRecipes.map((sr) => sr.recipe.name).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reusable search bar
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
                  final yieldsDigits = recipe.yields.replaceAll(RegExp(r'[^\d]'), '');
                  final servings = int.tryParse(yieldsDigits) ?? 1;

                  return InkWell(
                    onTap: () {
                      final router = GoRouter.of(context);
                      ref.read(recipeProvider.notifier).state = recipe;

                      if (!mounted) return;
                      router.goNamed('recipe');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // servings section here
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
                                  const SnackBar(content: Text('You must be logged in to remove a recipe!')),
                                );
                                return;
                              }

                              final savedRecipesController = ref.read(savedRecipesControllerProvider);
                              savedRecipesController.removeRecipe(user.profileId!, savedRecipe);
                            },
                          ),
                        ],
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
