// lib/screens/meal_recipe_screen.dart

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/models/meal_plan_entry.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/providers/meal_planner_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/utils/parse_servings.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/saved_recipe_controller.dart';

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

  bool _selectingWeek = true;
  bool _menuOpen = false;
  bool _pendingWeekdayOpen = false;

  final _ddKey = GlobalKey<DropdownButton2State>();

  late final int _weeksInYear = _isoWeek(DateTime(DateTime.now().year, 12, 28));
  late final List<int> _weeks = List.generate(_weeksInYear, (i) => i + 1);
  
  // Generate weekdays for planner hint
  final List<String> _weekdays = List.generate(
    7,
    (i) =>
        DateFormat('EEEE').format(DateTime(2025, 1, 6).add(Duration(days: i))),
  );

  Set<String> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    // Calculate current ISO week number
    actualCurrentWeek = _isoWeek(DateTime.now());
    currentWeek = actualCurrentWeek;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlans(currentWeek);
    });

    final recipe = ref.read(recipeProvider);
    if (recipe != null) {
      RecipeController(ref: ref).fetchRecipeByName(recipe.name);
    }
  }

  int _isoWeek(DateTime d) {
    final firstThu = DateTime(d.year, 1, 1)
        .add(Duration(days: (4 - DateTime(d.year, 1, 1).weekday + 7) % 7));
    final week1Mon =
        firstThu.subtract(Duration(days: firstThu.weekday - DateTime.monday));
    return (d.difference(week1Mon).inDays ~/ 7) + 1;
  }

  Future<void> _loadPlans(int week) async {
    final uid = ref.read(currentUserValueProvider)?.profileId;
    if (uid == null) return;
    await ref.read(mealPlannerControllerProvider).fetchPlans(uid, week);
    final plans = ref.read(mealPlannerProvider)[week] ?? <MealPlanEntry>[];
    final name = ref.read(recipeProvider)!.name;
    _selectedDays =
        plans.where((e) => e.name == name).map((e) => e.day).toSet();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final recipe = ref.watch(recipeProvider);
    if (recipe == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Remove "approx" from yields just in case.
    final rawYields = recipe.yields;
    final cleanedYields = rawYields
      .replaceAll(
        RegExp(r'\bApprox[^\d]*\s*', caseSensitive: false),
        '',
      )
      .trim();
    final saved = ref
        .watch(savedRecipesProvider)
        .any((sr) => sr.recipe.name == recipe.name);

    final buttonText = _selectingWeek && !_menuOpen
        ? 'Add to meal planner: current week $currentWeek'
        : _selectingWeek && _menuOpen
            ? 'Current week: $actualCurrentWeek'
            : 'Add to weekly meal planner: week $currentWeek';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //-----------------------------------------------------------------
            // Header
            //-----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(recipe.name,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.tertiary)),
                ),
                IconButton(
                  icon: Icon(
                    saved ? Icons.favorite : Icons.favorite_border,
                    color: saved ? theme.primary : theme.tertiary,
                  ),
                  onPressed: () async {
                    final user = ref.read(currentUserValueProvider);
                    if (user == null) return;
                    final ctrl = ref.read(savedRecipesControllerProvider);
                    if (saved) {
                      final sr = ref
                          .read(savedRecipesProvider)
                          .firstWhere((e) => e.recipe.name == recipe.name);
                      await ctrl.removeRecipeByAuthId(user.authId, sr);
                    } else {
                      await ctrl.addRecipeByAuthId(user.authId, recipe);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _meta(theme, Icons.timer_outlined, recipe.prepTime),
                _meta(theme, Icons.local_fire_department, recipe.cookTime),
                _meta(theme, Icons.people, cleanedYields),
              ],
            ),
            const SizedBox(height: 12),

            // Weekday dropdown
            DropdownButtonHideUnderline(
              child: DropdownButton2<dynamic>(
                key: _ddKey,
                isExpanded: true,
                value: _selectingWeek ? currentWeek : null,
                customButton: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(buttonText,
                            style:
                                TextStyle(fontSize: 16, color: theme.tertiary)),
                      ),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                onMenuStateChange: (open) {
                  if (!open && _pendingWeekdayOpen) {
                    _pendingWeekdayOpen = false;
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _ddKey.currentState?.callTap());
                  } else if (!open && !_pendingWeekdayOpen) {
                    setState(() {
                      _selectingWeek = true;
                      currentWeek = actualCurrentWeek; // reset next cycle
                    });
                  }
                  _menuOpen = open;
                },
                items: _selectingWeek
                    ? _weeks.map((w) {
                        final isCurrentIso = w == actualCurrentWeek;
                        return DropdownMenuItem<int>(
                          enabled: false,
                          value: w,
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                currentWeek = w;
                                _selectingWeek = false;
                                _pendingWeekdayOpen = true;
                              });
                              await _loadPlans(currentWeek);
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isCurrentIso
                                        ? 'Current week $w'
                                        : 'Week $w',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isCurrentIso
                                            ? theme.primary
                                            : theme.tertiary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    : _weekdays.map((day) {
                        return DropdownMenuItem<String>(
                          enabled: false,
                          value: day,
                          child: StatefulBuilder(
                            builder: (ctx, menuSet) {
                              final selected = _selectedDays.contains(day);
                              return InkWell(
                                onTap: () async {
                                  final uid = ref
                                      .read(currentUserValueProvider)!
                                      .profileId!;
                                  final ctrl =
                                      ref.read(mealPlannerControllerProvider);

                                  if (selected) {
                                    final entry =
                                        (ref.read(mealPlannerProvider)[
                                                    currentWeek] ??
                                                <MealPlanEntry>[])
                                            .firstWhere((e) =>
                                                e.day == day &&
                                                e.name == recipe.name);
                                    await ctrl.removePlan(
                                        entry.id, currentWeek);
                                    _selectedDays.remove(day);

                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        CustomSnackbar.buildSnackBar(
                                          title:
                                              'Removed from week $currentWeek',
                                          message:
                                              '"${recipe.name}" removed from $day',
                                          innerPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                        ),
                                      );
                                  } else {
                                    await ctrl.addPlan(
                                      MealPlanEntry(
                                        id: '',
                                        userId: uid,
                                        week: currentWeek,
                                        day: day,
                                        name: recipe.name,
                                        description: recipe.summary,
                                        servings: parseServings(recipe.yields),
                                        lactoseFree: recipe.lactoseFree,
                                        vegan: recipe.vegan,
                                        vegetarian: recipe.vegetarian,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                    _selectedDays.add(day);
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        CustomSnackbar.buildSnackBar(
                                          title: 'Added to week $currentWeek',
                                          message:
                                              '"${recipe.name}" planned for $day',
                                          innerPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                        ),
                                      );
                                  }
                                  setState(() {});
                                  menuSet(() {});
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: selected ? theme.primary : Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(day,
                                          style:
                                              TextStyle(color: theme.tertiary)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                onChanged: (_) {},
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 400,
                  offset: const Offset(0, 0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(6)),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 48,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Ingredients list tile
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
                onExpansionChanged: (v) => setState(() => _isExpanded = v),
                children: [
                  const SizedBox(height: 8),
                  IngredientList(ingredients: recipe.ingredients),
                  const SizedBox(height: 16),
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
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(s, style: TextStyle(color: theme.tertiary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(ColorScheme color, IconData icon, String t) => Row(
        children: [
          Icon(icon, size: 16, color: color.tertiary),
          const SizedBox(width: 4),
          Text(t, style: TextStyle(color: color.tertiary)),
        ],
      );
}
