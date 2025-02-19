import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen that shows recipes that users have chosen to save for later.
/// Allows user to see how many portions recipe is for, as well as dietary information (lactose, vegan).
class SavedRecipesScreen extends ConsumerStatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  SavedRecipesState createState() => SavedRecipesState();
}

class SavedRecipesState extends ConsumerState<SavedRecipesScreen> {

  // Just some dummy data.
  final List<Map<String, dynamic>> savedRecipes = [
    {'name': 'Vegan Pasta', 'isVegan': true, 'isLactoseFree': true, 'servings': 2},
    {'name': 'Cheese Omelette', 'isVegan': false, 'isLactoseFree': false, 'servings': 1},
    {'name': 'Lactose-Free Pancakes', 'isVegan': false, 'isLactoseFree': true, 'servings': 4},
    {'name': 'Vegetable Stir-Fry', 'isVegan': true, 'isLactoseFree': true, 'servings': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Recipes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 64.0),
                itemCount: savedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = savedRecipes[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${recipe['servings']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.people,
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary),
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
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              children: [
                                if (recipe['isVegan'])
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.eco,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                if (recipe['isLactoseFree'])
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.local_drink,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.tertiary),
                          onPressed: () {
                            setState(() {
                              savedRecipes.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
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
