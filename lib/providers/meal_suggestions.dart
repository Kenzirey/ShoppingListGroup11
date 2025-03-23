import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A StateNotifier that manages a list of meal suggestions.
class MealSuggestionsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
MealSuggestionsNotifier()
      : super([
          {
            'name': 'Pasta with tomato sauce',
            'servings': 2,
            'lactoseFree': false,
            'vegan': false,
            'vegetarian': true,
          },
          {
            'name': 'Grilled cheese sandwich',
            'servings': 1,
            'lactoseFree': false,
            'vegan': false,
            'vegetarian': true,
          },
          {
            'name': 'Vegetable stir-fry',
            'servings': 3,
            'lactoseFree': true,
            'vegan': true,
            'vegetarian': true,
          },
        ]);

  /// temporary
  void addSuggestion(String name, int servings) {
    final updated = [...state];
    updated.add({
      'name': name,
      'servings': servings,
    });
    state = updated;
  }

  /// temporary
  void removeSuggestion(int index) {
    final updated = [...state];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = updated;
    }
  }
}

/// the actual riverpod provider.
final mealSuggestionsProvider =
    StateNotifierProvider<MealSuggestionsNotifier, List<Map<String, dynamic>>>(
  (ref) => MealSuggestionsNotifier(),
);
