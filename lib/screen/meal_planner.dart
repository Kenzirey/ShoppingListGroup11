import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/widget/meal_item_helper.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';

/// Allows user to keep track and manage meals for the week.
class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  // Example placeholder for the current week number.
  late int currentWeek;

  // This represents the actual current week, we do need to use datetime or something instead.
  late int actualCurrentWeek;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    actualCurrentWeek = _calculateWeekNumber(now);
    currentWeek = actualCurrentWeek;
  }

  /// Calculate ISO week number (week starting Monday) for a given date.
  /// So that the week number is consistent with the current week, without hardcoding the specific week.
  int _calculateWeekNumber(DateTime date) {
    final firstThursday = DateTime(date.year, 1, 1).add(
      Duration(days: (4 - DateTime(date.year, 1, 1).weekday + 7) % 7),
    );
    final week1Monday = firstThursday.subtract(
      Duration(days: firstThursday.weekday - DateTime.monday),
    );
    return ((date.difference(week1Monday).inDays) / 7).floor() + 1;
  }

  /// Remove a meal from a specific day, with undo support.
  void _removeMeal(
    BuildContext context,
    String day,
    Map<String, dynamic> meal,
  ) {
    // capture index so we can undo removal
    final planner = ref.read(mealPlannerProvider);
    final removedIndex = planner[day]!.indexOf(meal);

    // Call the notifier's method to remove the meal
    final notifier = ref.read(mealPlannerProvider.notifier);
    notifier.removeMeal(day, meal);

    // Use the custom reu-sable snackbar with an undo to resto.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.buildSnackBar(
          title: 'Removed',
          message: '"${meal['name']}" removed',
          innerPadding: const EdgeInsets.symmetric(horizontal: 16),
          actionText: 'Undo',
          onAction: () {
            // Use the insertMeal method to undo removal
            notifier.insertMeal(day, removedIndex, meal);
            // Confirm re-addition
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.buildSnackBar(
                  title: 'Restored',
                  message:
                      '"${meal['name']}" successfully restored to meal plan',
                  innerPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              );
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final mealPlan = ref.watch(mealPlannerProvider);

    // Gather all meal names for the search bar suggestions, temporary setup.
    final allMeals = mealPlan.values
        .expand((dayList) => dayList.map((meal) => meal['name'].toString()))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

            // title row and the week/time picker.
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
                DropdownButton<int>(
                  value: currentWeek,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 16,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: List.generate(52, (index) {
                    final week = index + 1;
                    final bool isCurrentWeek = week == actualCurrentWeek;
                    return DropdownMenuItem<int>(
                      value: week,
                      child: Text(
                        isCurrentWeek ? 'Current Week $week' : 'Week $week',
                        style: TextStyle(
                          color: isCurrentWeek
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.tertiary,
                          fontWeight: isCurrentWeek
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                  // the days + meals section below
                  selectedItemBuilder: (BuildContext context) {
                    return List.generate(52, (index) {
                      final week = index + 1;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          week == actualCurrentWeek
                              ? 'Current Week $week'
                              : 'Week $week',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 16,
                          ),
                        ),
                      );
                    });
                  },
                  onChanged: (newWeek) {
                    if (newWeek != null) {
                      setState(() {
                        currentWeek = newWeek;
                      });
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // The days + meals section below.
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
                            background: Material(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {}, // ripple effect only
                                splashColor: Colors.white24,
                                highlightColor: Colors.white24,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            child: MealItem(
                              mealName: meal['name'],
                              servings: meal['servings'] ?? 1,
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
