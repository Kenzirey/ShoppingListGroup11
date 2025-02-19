import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/ingredient_list.dart';

/// Recipe screen for making UI alterations, and testing the supabase fetching/collecting.
class OldMealRecipeScreen extends ConsumerStatefulWidget {
  const OldMealRecipeScreen({super.key});

  @override
  ConsumerState<OldMealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends ConsumerState<OldMealRecipeScreen> {
  bool _isExpanded = true; //for the expansion state line thing (to track it)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 32, vertical: 16), // same as purchase history and shopping list.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title of the recipe (hard coded atm)
            Text(
              'Pesto Pasta',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary),
            ),
            const SizedBox(height: 12),
            // Icons section (person, time)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Over 60 min',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4 Personer',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ingredients
            Column(
              children: [
                ListTileTheme(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  horizontalTitleGap: 0.0,
                  minLeadingWidth: 0,
                  child: ExpansionTile(
                    title: const Text(
                      'Ingredients',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    initiallyExpanded: true,
                    childrenPadding: EdgeInsets.zero,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isExpanded = expanded; // keep track of expanded / not expanded :)
                      });
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasta',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          const IngredientList(ingredients: [
                            'Tonys salte tårer',
                            'Sitronsaft',
                            'Hvitløk',
                            'Basilikum',
                            'Revet parmesan',
                            'Flaksalt',
                            'Olivenolje',
                          ]),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Pesto',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                          const IngredientList(ingredients: [
                            '250 g hvetemel gjerne fint pastamel eller durumhvete',
                            '0,5 ts salt',
                            '2 stk. egg',
                            '2 stk. eggeplomme',
                          ]),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  // Only show divider via expanded condition.
                  visible: !_isExpanded,
                  child: Divider(
                    color: Theme.of(context).colorScheme.tertiary,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),

            // Instructions. Make it into its own widget too?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Rist pinjekjerner i en tørr stekepanne til de er lett gylne.\n'
                  '2. Ha alle ingrediensene i en foodprosessor og kjør til pestoen er jevn.\n'
                  '3. Kok pasta etter anvisning på pakken.\n'
                  '4. Bland pastaen med pestoen og server.',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}