// lib/screens/meal_recipe_screen.dart

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/saved_recipe.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/saved_recipe_controller.dart';
import '../providers/current_user_provider.dart';
import '../providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/models/meal_plan_entry.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/utils/parse_servings.dart';

/// Screen showing a recipe with ingredients and instructions.
/// Allows user to save recipe to their profile, as well as add it to a weekly meal planner.
class MealRecipeScreen extends ConsumerStatefulWidget {
  const MealRecipeScreen({super.key});

  @override
  ConsumerState<MealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends ConsumerState<MealRecipeScreen> {
  bool _isExpanded = true;
  late int currentWeek;
  late int actualCurrentWeek;

  // Generate weekdays for planner hint
  final List<String> weekDays = List.generate(
    7,
    (i) =>
        DateFormat('EEEE').format(DateTime(2025, 1, 4).add(Duration(days: i))),
  );

  @override
  void initState() {
    super.initState();

    // Calculate current ISO week number
    final now = DateTime.now();
    actualCurrentWeek = _calculateWeekNumber(now);
    currentWeek = actualCurrentWeek;

    // Fetch any existing meal plans for this user/week
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUserValueProvider)?.profileId;
      if (uid != null) {
        ref.read(mealPlannerControllerProvider).fetchPlans(uid, currentWeek);
      }
    });

    // Load recipe details
    final recipe = ref.read(recipeProvider);
    if (recipe != null) {
      RecipeController(ref: ref).fetchRecipeByName(recipe.name);
    }
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
 void _removeMeal(
  BuildContext context,
  int week,
  MealPlanEntry entry,
) {
  final notifier = ref.read(mealPlannerProvider.notifier);
  final currentList = ref.read(mealPlannerProvider)[week]!;
  final removedIndex = currentList.indexWhere((e) => e.id == entry.id);

  notifier.remove(week, entry.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      CustomSnackbar.buildSnackBar(
        title: 'Removed',
        message: '"${entry.name}" removed',
        innerPadding: const EdgeInsets.symmetric(horizontal: 16),
        actionText: 'Undo',
        onAction: () {
          notifier.insert(week, entry);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              CustomSnackbar.buildSnackBar(
                title: 'Restored',
                message: '"${entry.name}" restored to meal plan',
                innerPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            );
        },
      ),
    );
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final recipe = ref.watch(recipeProvider);
    if (recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final savedRecipes = ref.watch(savedRecipesProvider);
    final isSaved = savedRecipes.any((sr) => sr.recipe.name == recipe.name);

    // All plans for this week from Supabase/local state
    final plansThisWeek =
        ref.watch(mealPlannerProvider)[currentWeek] ?? <MealPlanEntry>[];

    // Days where this recipe is already planned
    final selectedDays = plansThisWeek
        .where((e) => e.name == recipe.name)
        .map((e) => e.day)
        .toSet();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.tertiary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? theme.primary : theme.tertiary,
                  ),
                  onPressed: () async {
                    final currentRecipe = ref.read(recipeProvider);
                    final currentUser = ref.watch(currentUserValueProvider);
                    if (currentRecipe == null) return;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          CustomSnackbar.buildSnackBar(
                            title: 'Error',
                            message: 'You must be logged in to save a recipe.',
                            innerPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        );
                      return;
                    }
                    final ctrl = ref.read(savedRecipesControllerProvider);
                    if (isSaved) {
                      SavedRecipe? sr;
                      try {
                        sr = savedRecipes.firstWhere(
                          (e) => e.recipe.name == currentRecipe.name,
                        );
                      } catch (_) {
                        sr = null;
                      }
                      if (sr != null) {
                        await ctrl.removeRecipeByAuthId(currentUser.authId, sr);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            CustomSnackbar.buildSnackBar(
                              title: 'Removed',
                              message:
                                  '${currentRecipe.name} removed from saved recipes.',
                              innerPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          );
                      }
                    } else {
                      await ctrl.addRecipeByAuthId(
                          currentUser.authId, currentRecipe);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          CustomSnackbar.buildSnackBar(
                            title: 'Saved',
                            message:
                                '${currentRecipe.name} saved to your recipes.',
                            innerPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(recipe.prepTime,
                        style: TextStyle(color: theme.tertiary)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16),
                    const SizedBox(width: 4),
                    Text(recipe.cookTime,
                        style: TextStyle(color: theme.tertiary)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(recipe.yields,
                        style: TextStyle(color: theme.tertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Add to weekly meal planner',
                  style: TextStyle(fontSize: 16, color: theme.tertiary),
                ),
                value: null,

                items: weekDays.map((day) {
                  final isSelected = selectedDays.contains(day);
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            day,
                            style: TextStyle(color: theme.tertiary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? theme.primary : Colors.white,
                        ),
                      ],
                    ),
                  );
                }).toList(),

                onChanged: (day) async {
                  if (day == null) return;
                  final uid = ref.read(currentUserValueProvider)!.profileId!;
                  final ctrl = ref.read(mealPlannerControllerProvider);

                  MealPlanEntry? existing;
                  try {
                    existing = plansThisWeek.firstWhere(
                      (e) => e.day == day && e.name == recipe.name,
                    );
                  } catch (_) {
                    existing = null;
                  }
                  if (existing != null) {
                    await ctrl.removePlan(existing.id, currentWeek);
                  } else {
                    await ctrl.addPlan(MealPlanEntry(
                      id: '',
                      userId: uid,
                      week: currentWeek,
                      day: day,
                      name: recipe.name,
                      description: recipe.summary,
                      servings: parse_servings(recipe.yields),
                      lactoseFree: recipe.lactoseFree,
                      vegan: recipe.vegan,
                      vegetarian: recipe.vegetarian,
                      createdAt: DateTime.now(),
                    ));
                  }
                },
                buttonStyleData: ButtonStyleData(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  offset: const Offset(0, 0),
                  maxHeight: 400,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(6)),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 50,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTileTheme(
              contentPadding: EdgeInsets.zero,
              dense: true,
              horizontalTitleGap: 0,
              minLeadingWidth: 0,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.only(left: 0, right: 12),
                collapsedIconColor: theme.tertiary,
                iconColor: theme.primary,
                title: const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: true,
                onExpansionChanged: (exp) => setState(() => _isExpanded = exp),
                children: [
                  SizedBox(height: 8),
                 IngredientList(ingredients: recipe.ingredients),

                  SizedBox(height: 16),
                ],
              ),
            ),
            Visibility(
              visible: !_isExpanded,
              child: Divider(color: theme.tertiary, thickness: 1),
            ),

            const SizedBox(height: 8),

            // Instructions
            Text('Instructions',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.tertiary)),
            const SizedBox(height: 8),
            ...recipe.instructions.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(step, style: TextStyle(color: theme.tertiary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
