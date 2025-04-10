import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/saved_recipe.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/saved_recipe_controller.dart';
import '../models/recipe.dart';
import '../providers/current_user_provider.dart';
import '../providers/saved_recipe_provider.dart';

class MealRecipeScreen extends ConsumerStatefulWidget {
  const MealRecipeScreen({super.key});

  @override
  ConsumerState<MealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends ConsumerState<MealRecipeScreen> {
  bool _isExpanded = true;

  // Gets weekdays from intl
  final List<String> weekDays = List.generate(7, (index) {
    // Using January 4, 2021 as a reference Monday.
    final DateTime date = DateTime(2025, 1, 4).add(Duration(days: index));
    return DateFormat('EEEE').format(date);
  });

  // Hold the selected days.
  // should make this dynamic, to fetch a list of current meal plan for the user.
  List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    if (ref.read(recipeProvider) == null) {
      RecipeController(ref: ref).loadRecipeFromSupabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recipe? recipe = ref.watch(recipeProvider);

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title and save button row.
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  onPressed: () async {
                    final currentRecipe = ref.read(recipeProvider);
                    final currentUser = ref.read(currentUserProvider);
                    if (currentRecipe == null) return;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('You must be logged in to save a recipe.'),
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
                      } catch (e) {
                        savedRecipe = null;
                      }
                      if (savedRecipe != null) {
                        await savedRecipesController.removeRecipeByAuthId(
                          currentUser.authId,
                          savedRecipe,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${currentRecipe.name} removed from saved recipes.'),
                          ),
                        );
                      }
                    } else {
                      await savedRecipesController.addRecipeByAuthId(
                        currentUser.authId,
                        currentRecipe,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${currentRecipe.name} saved to your recipes.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row displaying prep time, cook time, and yields.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Prep time.
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.prepTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                // Cook time.
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.cookTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                // Yields (servings).
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      recipe.yields,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Multiselect dropdown using DropdownButton2. // https://pub.dev/packages/dropdown_button2
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                // Always display the static text in the button, instead of making it change upon day.. . don't ask.
                hint: Text(
                  "Add to weekly meal planner",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                // Dummy value
                value: _selectedDays.isEmpty ? null : _selectedDays.last,
                onChanged: (value) {},
                selectedItemBuilder: (context) => weekDays
                    .map(
                      (e) => Container(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          "Add to weekly meal planner",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                items: weekDays.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    // Disable default onTap so the menu doesn't close.
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        final isSelected = _selectedDays.contains(day);
                        return InkWell(
                          //TODO: have them actually add to the weekly meal planner of current week, and then refresh when next week hits?
                          onTap: () {
                            if (isSelected) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                            setState(() {});
                            menuSetState(() {});
                          },
                          child: Container(
                            height: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                // generic calendar icon on left first.
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                // what day it is after calendar icon.
                                Expanded(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // checkbox here that is the selection for which day is to be added to the weekly meal planner.
                                isSelected
                                    ? Icon(
                                        Icons.check_box_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : const Icon(
                                        Icons.check_box_outline_blank,
                                        color: Colors.white,
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                buttonStyleData: ButtonStyleData(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  offset: const Offset(0, 0),
                  maxHeight: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 50,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Ingredients Section.
            Column(
              children: [
                ListTileTheme(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 0,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.only(left: 0, right: 12),
                    collapsedIconColor: Theme.of(context).colorScheme.tertiary,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: const Text(
                      'Ingredients',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isExpanded = expanded;
                      });
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          IngredientList(ingredients: recipe.ingredients),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider when ingredients are collapsed.
                Visibility(
                  visible: !_isExpanded,
                  child: Divider(
                    color: Theme.of(context).colorScheme.tertiary,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Instructions Section.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.instructions.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      step,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
