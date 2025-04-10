import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen that shows currently popular recipes amongst fellow users.
class TrendingRecipeScreen extends ConsumerStatefulWidget {
  const TrendingRecipeScreen({super.key});

  @override
  TrendingRecipesState createState() => TrendingRecipesState();
}

class TrendingRecipesState extends ConsumerState<TrendingRecipeScreen> {
  // Dummy data.
  final List<Map<String, dynamic>> savedRecipes = [
    {
      'name': 'Vegan Pasta',
      'isVegan': true,
      'isLactoseFree': true,
      'servings': 2,
    },
    {
      'name': 'Cheese Omelette',
      'isVegan': false,
      'isLactoseFree': false,
      'servings': 1,
    },
    {
      'name': 'Lactose-Free Pancakes',
      'isVegan': false,
      'isLactoseFree': true,
      'servings': 4,
    },
    {
      'name': 'Vegetable Stir-Fry',
      'isVegan': true,
      'isLactoseFree': true,
      'servings': 2,
    },
  ];

  // Filter options.
  final List<String> filters = ['All', 'Vegan', 'Vegetarian'];
  String selectedFilter = 'All';

  // Returns a filtered list based on the current selected filter.
  List<Map<String, dynamic>> get filteredRecipes {
    if (selectedFilter == 'Vegan') {
      return savedRecipes.where((recipe) => recipe['isVegan'] == true).toList();
    } else if (selectedFilter == 'Vegetarian') {
      // Assuming vegetarian means non-vegan recipes.
      return savedRecipes.where((recipe) => recipe['isVegan'] == false).toList();
    } else {
      return savedRecipes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    final background = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header Title and Divider
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trending meals this week',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 16),

            // Filter Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: filters.map((filter) {
                final bool isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: background,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Recipes List
            ...filteredRecipes.map(
              (recipe) =>
                  buildRecipeTile(recipe, color, background, context),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the recipe container.
  Widget buildRecipeTile(Map<String, dynamic> recipe, Color color,
      Color background, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Servings and icon.
          Row(
            children: [
              Text(
                '${recipe['servings']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.people,
                size: 20,
                color: color,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: recipe['name'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                children: [
                  if (recipe['isVegan'])
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.eco,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  if (recipe['isLactoseFree'])
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.local_drink,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
