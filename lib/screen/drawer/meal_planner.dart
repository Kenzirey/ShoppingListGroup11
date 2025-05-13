import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/models/meal_plan_entry.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../controllers/recipe_controller.dart';

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
    actualCurrentWeek = _isoWeek(now);
    currentWeek = actualCurrentWeek;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUserValueProvider)?.profileId;
      if (uid != null) {
        ref.read(mealPlannerControllerProvider).fetchPlans(uid, currentWeek);
      }
    });
  }

  int _isoWeek(DateTime d) {
    final jan4 = DateTime(d.year, 1, 4);
    final week1Mon =
        jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    return (d.difference(week1Mon).inDays ~/ 7) + 1;
  }

  /// Snackbar to show when a meal is removed from the list, with undo option to store it.
  void _showDeleteSnackBar({
    required BuildContext ctx,
    required MealPlanEntry removed,
    required int removedIdx,
  }) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CustomSnackbar.buildSnackBar(
          title: 'Removed from week $currentWeek',
          message: '"${removed.name}" removed from ${removed.day}',
          actionText: 'UNDO',
          onAction: () async {
            // restore locally
            ref
                .read(mealPlannerProvider.notifier)
                .insertAt(currentWeek, removedIdx, removed);

            // restore remotely
            await ref.read(mealPlannerControllerProvider).addPlan(removed);

            ScaffoldMessenger.of(ctx)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.buildSnackBar(
                  title: 'Restored!',
                  message: '"${removed.name}" restored meal to week $currentWeek.',
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
    final uid = ref.watch(currentUserValueProvider)?.profileId;
    final ctrl = ref.read(mealPlannerControllerProvider);
    final plansByWeek = ref.watch(mealPlannerProvider);
    final entries = plansByWeek[currentWeek] ?? <MealPlanEntry>[];

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final mealPlan = {
      for (var day in days) day: entries.where((entry) => entry.day == day).toList()
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Meal Planner',
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.tertiary)),
                DropdownButton<int>(
                  alignment: Alignment.center,
                  value: currentWeek,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),

                  // they both use week number values so both open + closed need the week generation.
                  selectedItemBuilder: (context) => List.generate(52, (i) {
                    final w = i + 1;
                    final isCurr = w == actualCurrentWeek;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isCurr ? 'Current Week $w' : 'Week $w',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary, // always tertiary
                          fontWeight:
                              isCurr ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),

                  // open menu 🔽
                  items: List.generate(52, (i) {
                    final w = i + 1;
                    final isCurr = w == actualCurrentWeek;
                    return DropdownMenuItem(
                      value: w,
                      child: Text(
                        isCurr ? 'Current Week $w' : 'Week $w',
                        style: TextStyle(
                          color: isCurr
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary // only here
                              : Theme.of(context).colorScheme.tertiary,
                          fontWeight:
                              isCurr ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),

                  onChanged: (w) {
                    if (w == null) return;
                    setState(() => currentWeek = w);
                    if (uid != null) ctrl.fetchPlans(uid, w);
                  },
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // Weekday list section below
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64),
                itemCount: days.length,
                itemBuilder: (ctx, i) {
                  final day = days[i];
                  final meals = mealPlan[day]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.tertiary)),
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
                          child: Text('No meals planned',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                        )
                      else
                        ...List.generate(meals.length, (idx) {
                          final entry = meals[idx];
                          final servings = entry.servings;

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
                              await ctrl.removePlan(entry.id, currentWeek);
                              ref
                                  .read(mealPlannerProvider.notifier)
                                  .remove(currentWeek, entry.id);

                              _showDeleteSnackBar(
                                ctx: context,
                                removed: entry,
                                removedIdx: idx,
                              );
                            },

                            // allow to open the recipe screen via item when pressed.
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Material(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: InkWell(
                                    onTap: () {
                                      // fetch the recipe, then open screen
                                      RecipeController(ref: ref)
                                          .fetchRecipeByName(entry.name);
                                      if (!mounted) return;
                                      context.goNamed('recipe');
                                    },
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(minHeight: 56),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 14),
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
                                                entry.name,
                                                softWrap: true,
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
