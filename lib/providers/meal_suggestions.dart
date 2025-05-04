import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/main.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/services/meal_suggestion_service.dart';

class MealSuggestionsNotifier extends StateNotifier<List<Recipe>> {
  MealSuggestionsNotifier() : super(const []);

  /// Replace the entire list
  void setSuggestions(List<Recipe> list) => state = list;

  /// Add a recipe to the end
  void addSuggestion(Recipe r) => state = [...state, r];

  /// Remove by index
  void removeAt(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state]..removeAt(index);
    }
  }

  /// Insert at a specific position
  void insertAt(int index, Recipe r) {
    final clamped = index.clamp(0, state.length);
    state = [...state]..insert(clamped, r);
  }
}

final mealSuggestionsProvider =
    StateNotifierProvider<MealSuggestionsNotifier, List<Recipe>>(
  (ref) => MealSuggestionsNotifier(),
);
final mealSuggestionServiceProvider = Provider<MealSuggestionService>((ref) {
  return MealSuggestionService(
    supabase: supabase,
    gemini  : Gemini.instance,
  );
});
