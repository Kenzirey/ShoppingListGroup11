import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A StateNotifier that manages the meal plan for each day.
class MealPlannerNotifier extends StateNotifier<Map<String, List<Map<String, dynamic>>>> {
  MealPlannerNotifier()
      : super({
          'Monday': [
            {
              'name': 'Pasta Carbonara',
              'lactoseFree': false,
              'vegan': false,
              'servings': 3,
              'vegetarian': false,
            },
          ],
          'Tuesday': [],
          'Wednesday': [
            {
              'name': 'Roasted Pork',
              'lactoseFree': true,
              'vegan': false,
              'vegetarian': false,
            },
            {
              'name': 'Mashed Potato',
              'lactoseFree': true,
              'servings': 1,
              'vegan': false,
              'vegetarian': true,
            },
          ],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        });

  /// Removes a meal from the specified [day].
  /// Temporary.
  void removeMeal(String day, Map<String, dynamic> meal) {
    final updated = {...state};
    final mealsForDay = [...?updated[day]];
    mealsForDay.remove(meal);
    updated[day] = mealsForDay;
    state = updated;
  }

  /// Inserts a meal at [index] for the specified [day].
  /// Temporary
  void insertMeal(String day, int index, Map<String, dynamic> meal) {
    final updated = {...state};
    final mealsForDay = [...?updated[day]];
    mealsForDay.insert(index, meal);
    updated[day] = mealsForDay;
    state = updated;
  }
}

final mealPlannerProvider =
    StateNotifierProvider<MealPlannerNotifier, Map<String, List<Map<String, dynamic>>>>(
  (ref) => MealPlannerNotifier(),
);
