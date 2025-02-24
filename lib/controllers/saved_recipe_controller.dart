// controllers/saved_recipes_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_recipe.dart';
import '../providers/saved_recipe_provider.dart';

/// Controller for handle interaction of from riverpod with (later supabase).
/// need to actually set up supabase next.
class SavedRecipesController {
  final WidgetRef ref;

  SavedRecipesController({required this.ref});

  /// Adds a [SavedRecipe] to the list.
  void addRecipe(SavedRecipe recipe) {
    final currentList = ref.read(savedRecipesProvider);
    ref.read(savedRecipesProvider.notifier).state = [...currentList, recipe];
  }

  /// Removes the selected [SavedRecipe] from the list.
  void removeRecipe(SavedRecipe recipe) {
    final currentList = ref.read(savedRecipesProvider);
    ref.read(savedRecipesProvider.notifier).state =
        currentList.where((r) => r != recipe).toList();
  }
}
