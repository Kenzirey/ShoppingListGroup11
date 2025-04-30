import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import 'package:shopping_list_g11/providers/meal_suggestions.dart';

/// Home screen for the app.
/// Displays "Expiring Soon" items and "Meal Suggestions" upon the above items.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Now mutable so we can remove/restore on swipe
  List<Map<String, String>> expiringItems = [
    {'name': 'Milk', 'days': '2', 'category': 'fridge'},
    {'name': 'Cheese', 'days': '3', 'category': 'fridge'},
    {'name': 'Minced Meat', 'days': '1', 'category': 'freezer'},
    {'name': 'Can of Beans', 'days': '10', 'category': 'dry_storage'},
  ];

  // icon helper.
  //TODO: set up this as its own widget so it can be reused for other screens.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    // get meal changes:
    final mealSuggestions = ref.watch(mealSuggestionsProvider);
    // Get access to controller methods (add, remove etc)
    final notifier = ref.read(mealSuggestionsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: ListView(
          children: [
            // Title
            Text(
              'ShelfAware',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.tertiary,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),

            Text('Expiring Soon',
                style: TextStyle(fontSize: 18, color: theme.tertiary)),
            const SizedBox(height: 12),
            ...expiringItems.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              final name = rec['name']!;
              final days = rec['days']!;
              final category = rec['category']!;

              return Dismissible(
                key: ValueKey(name),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  final removed = expiringItems[index];
                  setState(() => expiringItems.removeAt(index));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      CustomSnackbar.buildSnackBar(
                        title: 'Removed',
                        message: '$name removed',
                        innerPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        actionText: 'Undo',
                        onAction: () {
                          // restore item
                          setState(() => expiringItems.insert(index, removed));
                          // show restored snackbar
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              CustomSnackbar.buildSnackBar(
                                title: 'Restored',
                                message: '$name restored successfully',
                                innerPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            );
                        },
                      ),
                    );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            PantryIcons(category: category, size: 20, color: theme.tertiary),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.tertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 20, color: theme.tertiary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            days,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.tertiary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Meal Suggestions section 
            Text('Meal Suggestions',
                style: TextStyle(fontSize: 18, color: theme.tertiary)),
            const SizedBox(height: 12),

            // Meal Suggestions (unchanged)
            ...mealSuggestions.asMap().entries.map((entry) {
              final idx = entry.key;
              final meal = entry.value;
              final name = meal['name'] as String;
              final servings = meal['servings'] as int? ?? 1;
              final lactoseFree = meal['lactoseFree'] as bool? ?? false;
              final vegan = meal['vegan'] as bool? ?? false;
              final vegetarian = meal['vegetarian'] as bool? ?? false;

              return Dismissible(
                key: ValueKey(name),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  final removed = mealSuggestions[idx];
                  notifier.removeSuggestion(idx);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      CustomSnackbar.buildSnackBar(
                        title: 'Removed',
                        message: '$name removed',
                        innerPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        actionText: 'Undo',
                        onAction: () {
                          notifier.insertSuggestion(idx, removed);
                        },
                      ),
                    );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      child: Row(
                        children: [
                          Icon(
                            servings > 1 ? Icons.people : Icons.person,
                            size: 20,
                            color: theme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$servings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.tertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lactoseFree) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.icecream,
                                      size: 20, color: theme.tertiary),
                                ],
                                if (vegan) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.eco,
                                      size: 20, color: theme.tertiary),
                                ],
                                if (vegetarian) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.spa,
                                      size: 20, color: theme.tertiary),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}