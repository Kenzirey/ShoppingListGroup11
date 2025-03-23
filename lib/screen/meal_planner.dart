import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/widget/meal_item_helper.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';

/// Allows user to keep track and manage meals for the week.
class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  // Example placeholder for the current week number.
  int currentWeek = 12;

  /// A private helper for UI development process only.
  void _removeMeal(
      BuildContext context, String day, Map<String, dynamic> meal) {
    final plan = ref.read(mealPlannerProvider);

    final removedIndex = plan[day]!.indexOf(meal);

    final updatedMap = {...plan};
    final updatedList = [...?updatedMap[day]];
    updatedList.removeAt(removedIndex);
    updatedMap[day] = updatedList;

    ref.read(mealPlannerProvider.notifier).state = updatedMap;

    //TODO: set up a separate snackbar to keep consistency across app.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${meal['name']}"'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Theme.of(context).colorScheme.error,
          onPressed: () {
            final undoMap = {...ref.read(mealPlannerProvider)};
            final undoList = [...?undoMap[day]];
            undoList.insert(removedIndex, meal);
            undoMap[day] = undoList;
            ref.read(mealPlannerProvider.notifier).state = undoMap;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealPlan = ref.watch(mealPlannerProvider);

    // Gather all meal names for the search bar suggestions, temporary setup
    final allMeals = mealPlan.values
        .expand((dayList) => dayList.map((meal) => meal['name'].toString()))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBarWidget(
              suggestions: allMeals,
              hintText: 'Search meals...',
              onSuggestionSelected: (selectedMeal) {
                debugPrint('Selected meal: $selectedMeal');
              },
            ),
            const SizedBox(height: 16),

            // title, week n filter icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meal Planner',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Week $currentWeek',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // filter for weeks here
                      },
                      icon: Icon(
                        Icons.filter_alt,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // the days + meals section below
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64.0),
                itemCount: mealPlan.keys.length,
                itemBuilder: (context, index) {
                  final day = mealPlan.keys.elementAt(index);
                  final meals = mealPlan[day]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (meals.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No meals planned',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        )
                      else
                        ...meals.map((meal) {
                          return Dismissible(
                            key: ValueKey(meal),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: Colors.red,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              _removeMeal(context, day, meal);
                            },
                            child: MealItem(
                              mealName: meal['name'],
                              servings: meal['servings'] ??
                                  1, // defaults to one portion :)
                              lactoseFree: meal['lactoseFree'] ?? false,
                              vegan: meal['vegan'] ?? false,
                              vegetarian: meal['vegetarian'] ?? false,
                              onDelete: () {
                                _removeMeal(context, day, meal);
                              },
                            ),
                          );
                        }),
                    ],
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
