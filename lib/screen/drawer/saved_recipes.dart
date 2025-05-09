// lib/screens/saved_recipes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/models/saved_recipe.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../controllers/saved_recipe_controller.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/widget/navigation/search_bar.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

/// Screen that shows recipes that users have chosen to save for later.
/// Allows user to see how many portions recipe is for, as well as dietary information (lactose, vegan).
/// Also allows user to remove recipes from their saved list.
///
/// The screen is a [ConsumerStatefulWidget] that uses Riverpod for state management.
class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  ConsumerState<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends ConsumerState<SavedRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.watch(currentUserValueProvider);
      if (user != null && user.profileId != null) {
        await ref
            .read(savedRecipesControllerProvider)
            .fetchSavedRecipes(user.profileId!);
      }
    });
  }

  void _showDeleteSnackBar({
    required BuildContext context,
    required String profileId,
    required SavedRecipe removedRecipe,
    required int removedIndex,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.buildSnackBar(
          title: 'Deleted!',
          message: '${removedRecipe.recipe.name} removed.',
          actionText: 'UNDO',
          onAction: () async {
            // restore locally at original position for instant UI feedback
            final listNotifier = ref.read(savedRecipesProvider.notifier);
            final current = [...listNotifier.state];
            current.insert(removedIndex, removedRecipe);
            listNotifier.state = current;

            // add to database
            await ref
                .read(savedRecipesControllerProvider)
                .addRecipe(profileId, removedRecipe.recipe);

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.buildSnackBar(
                  title: 'Restored!',
                  message: '${removedRecipe.recipe.name} re‑added.',
                  innerPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              );
          },
          innerPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final savedRecipes = ref.watch(savedRecipesProvider);
    final recipeNames = savedRecipes.map((e) => e.recipe.name).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBarWidget(
              suggestions: recipeNames,
              hintText: 'Search for recipes to add...',
              onSuggestionSelected: debugPrint,
            ),
            const SizedBox(height: 16),
            Text(
              'Saved Recipes',
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.tertiary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final savedRecipe = savedRecipes[index];
                  final recipe = savedRecipe.recipe;
                  final servings = int.tryParse(
                          recipe.yields.replaceAll(RegExp(r'[^\d]'), '')) ??
                      1;

                  // the new dismissible so that it is actually the same size as item.
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Dismissible(
                        key: Key(recipe.name),
                        direction: DismissDirection.endToStart,
                        background: const SizedBox.shrink(),
                        secondaryBackground: Container(
                          height: 56, // same as pantry tile etc
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          final user = ref.read(currentUserValueProvider);
                          if (user == null || user.profileId == null) return;

                          ref
                              .read(savedRecipesControllerProvider)
                              .removeRecipe(user.profileId!, savedRecipe);

                          _showDeleteSnackBar(
                            context: context,
                            profileId: user.profileId!,
                            removedRecipe: savedRecipe,
                            removedIndex: index,
                          );
                        },
                        child: SizedBox(
                          height: 56, // exact match to pantry items
                          child: Material(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: InkWell(
                              onTap: () {
                                ref.read(recipeProvider.notifier).state =
                                    recipe;
                                if (!mounted) return;
                                context.goNamed('recipe');
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Icon(
                                      servings > 1
                                          ? Icons.people
                                          : Icons.person,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$servings',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        recipe.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
