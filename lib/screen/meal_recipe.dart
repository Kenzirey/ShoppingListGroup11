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

/// Screen showing a recipe with ingredients and instructions.
/// Allows user to save recipe to their profile, as well as add it to a weekly meal planner.
/// And allows for selecting individual ingredients to add to shopping list.
class MealRecipeScreen extends ConsumerStatefulWidget {
  const MealRecipeScreen({super.key});

  @override
  ConsumerState<MealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends ConsumerState<MealRecipeScreen> {
  bool _isExpanded = true;

  // Generate weekdays for planner hint
  final List<String> weekDays = List.generate(
    7,
    (i) =>
        DateFormat('EEEE').format(DateTime(2025, 1, 4).add(Duration(days: i))),
  );
  final List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    final recipe = ref.read(recipeProvider);
    if (recipe != null) {
      RecipeController(ref: ref).fetchRecipeByName(recipe.name);
    }
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
                    final currentUser = ref.read(currentUserProvider);
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
                    final savedRecipesController =
                        ref.read(savedRecipesControllerProvider);
                    if (isSaved) {
                      SavedRecipe? savedRecipe;
                      try {
                        savedRecipe = savedRecipes.firstWhere(
                          (sr) => sr.recipe.name == currentRecipe.name,
                        );
                      } catch (_) {
                        savedRecipe = null;
                      }
                      if (savedRecipe != null) {
                        await savedRecipesController.removeRecipeByAuthId(
                          currentUser.authId,
                          savedRecipe,
                        );
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
                      await savedRecipesController.addRecipeByAuthId(
                        currentUser.authId,
                        currentRecipe,
                      );
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
                value: _selectedDays.isEmpty ? null : _selectedDays.last,
                onChanged: (_) {},
                selectedItemBuilder: (_) => weekDays
                    .map((e) => Container(
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Add to weekly meal planner',
                            style:
                                TextStyle(fontSize: 16, color: theme.tertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                items: weekDays
                    .map(
                      (day) => DropdownMenuItem<String>(
                        value: day,
                        enabled: false,
                        child: StatefulBuilder(
                          builder: (ctx, setMb) {
                            final sel = _selectedDays.contains(day);
                            return InkWell(
                              onTap: () {
                                if (sel) {
                                  _selectedDays.remove(day);
                                } else {
                                  _selectedDays.add(day);
                                }
                                setState(() {});
                                setMb(() {});
                              },
                              child: Container(
                                height: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 20, color: theme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(day,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: theme.tertiary)),
                                    ),
                                    const SizedBox(width: 16),
                                    sel
                                        ? Icon(Icons.check_box_outlined,
                                            color: theme.primary)
                                        : const Icon(
                                            Icons.check_box_outline_blank,
                                            color: Colors.white),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
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
                onExpansionChanged: (exp) {
                  setState(() {
                    _isExpanded = exp;
                  });
                },
                children: [
                  const SizedBox(height: 8),
                  IngredientList(ingredients: recipe.ingredients),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Visibility(
              visible: !_isExpanded,
              child: Divider(
                color: theme.tertiary,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.tertiary,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.instructions.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        step,
                        style: TextStyle(color: theme.tertiary),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
