import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_recipe.dart';

/// Provider for holding all saved recipes.
final savedRecipesProvider = StateProvider<List<SavedRecipe>>((ref) => []);