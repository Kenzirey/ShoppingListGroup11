import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/meal_plan_entry.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/widget/meal_item_helper.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';

/// Allows user to keep track and manage meals for the week.
class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  late int currentWeek;
  late int actualCurrentWeek;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    actualCurrentWeek = _calculateWeekNumber(now);
    currentWeek = actualCurrentWeek;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(currentUserValueProvider)?.profileId;
      if (userId != null) {
        ref.read(mealPlannerControllerProvider).fetchPlans(userId, currentWeek);
      }
    });
  }

  int _calculateWeekNumber(DateTime date) {
    final firstThursday = DateTime(date.year, 1, 1).add(
      Duration(days: (4 - DateTime(date.year, 1, 1).weekday + 7) % 7),
    );
    final week1Monday = firstThursday.subtract(
      Duration(days: firstThursday.weekday - DateTime.monday),
    );
    return ((date.difference(week1Monday).inDays) / 7).floor() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserValueProvider)?.profileId;
    final controller = ref.read(mealPlannerControllerProvider);
    final plansByWeek = ref.watch(mealPlannerProvider);
    final entries = plansByWeek[currentWeek] ?? <MealPlanEntry>[];

    const weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final mealPlan = {
      for (var d in weekDays) d: entries.where((e) => e.day == d).toList()
    };

    final allMeals = mealPlan.values
        .expand((dayList) => dayList.map((entry) => entry.name))
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
              onSuggestionSelected: (meal) => debugPrint('Picked: $meal'),
            ),

            const SizedBox(height: 16),

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
                  items: List.generate(52, (i) {
                    final week = i + 1;
                    final isCurrent = week == actualCurrentWeek;
                    return DropdownMenuItem(
                      value: week,
                      child: Text(
                        isCurrent ? 'Current Week $week' : 'Week $week',
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.tertiary,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                  selectedItemBuilder: (_) => List.generate(52, (i) {
                    final week = i + 1;
                    return Center(
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
                  }),
                  onChanged: (newWeek) {
                    if (newWeek != null) {
                      setState(() => currentWeek = newWeek);
                      if (userId != null) {
                        controller.fetchPlans(userId, newWeek);
                      }
                    }
                  },
                ),
              ],
            ),

            const Divider(),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64.0),
                itemCount: weekDays.length,
                itemBuilder: (context, idx) {
                  final day = weekDays[idx];
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
                              vertical: 10, horizontal: 14),
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
                        ...meals.map((entry) {
                          return Dismissible(
                            key: ValueKey(entry.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              // delete on server
                              await controller.removePlan(
                                  entry.id, currentWeek);
                              // re-fetch locally
                              if (userId != null) {
                                await controller.fetchPlans(
                                    userId, currentWeek);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('"${entry.name}" removed from $day'),
                                ),
                              );
                            },
                            child: MealItem(
                              mealName: entry.name,
                              servings: entry.servings,
                              lactoseFree: entry.lactoseFree,
                              vegan: entry.vegan,
                              vegetarian: entry.vegetarian,
                              onDelete: () async {
                                await controller.removePlan(
                                    entry.id, currentWeek);
                                if (userId != null) {
                                  await controller.fetchPlans(
                                      userId, currentWeek);
                                }
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
