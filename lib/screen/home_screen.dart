import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/controllers/gemini_controller.dart';
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
  // THese are only temporary for testing and showing the ui look.
  final Map<String, String> expiringItems = {
    'Milk': '2',
    'Cheese': '3',
    'Yogurt': '5',
    'Carrots': '2',
  };

  IconData _getExpiringIcon(String itemName) {
    final lower = itemName.toLowerCase();
    if (lower.contains('milk') ||
        lower.contains('cheese') ||
        lower.contains('yogurt')) {
      return Icons.icecream;
    }
    return Icons.shopping_basket;
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ShelfAware',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.tertiary),
            ),
            /// TEMPORARY BUTTON UNTIL THE TESTING OF CATEGORY THING IS DONE WITH GEMINI 
            const SizedBox(height: 4),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final controller = GeminiController(
                    ref: ref,
                    controller: TextEditingController(),
                  );
                  await controller.processProducts();
                },
                child: const Text('Buy More Pokemon'),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),

            Text('Expiring Soon',
                style: TextStyle(fontSize: 18, color: theme.tertiary)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: expiringItems.length,
                itemBuilder: (context, index) {
                  final item = expiringItems.keys.elementAt(index);
                  final expiryTime = expiringItems[item];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(_getExpiringIcon(item),
                                  size: 20, color: theme.tertiary),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.tertiary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 20,
                                color: theme.tertiary.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              expiryTime ?? '',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.tertiary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Meal Suggestions section
            Text('Meal Suggestions',
                style: TextStyle(fontSize: 18, color: theme.tertiary)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: mealSuggestions.length,
                itemBuilder: (context, index) {
                  final meal = mealSuggestions[index];
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
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      final removed = mealSuggestions[index];
                      notifier.removeSuggestion(index);
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
                              notifier.insertSuggestion(index, removed);
                            },
                          ),
                        );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          borderRadius: BorderRadius.circular(8)),
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          child: Row(
                            children: [
                              Icon(servings > 1 ? Icons.people : Icons.person,
                                  size: 20, color: theme.tertiary),
                              const SizedBox(width: 4),
                              Text('$servings',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.tertiary)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: theme.tertiary),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    if (lactoseFree || vegan || vegetarian)
                                      const SizedBox(width: 8),
                                    if (lactoseFree) ...[
                                      Icon(Icons.icecream,
                                          size: 20, color: theme.tertiary),
                                      const SizedBox(width: 4)
                                    ],
                                    if (vegan) ...[
                                      Icon(Icons.eco,
                                          size: 20, color: theme.tertiary),
                                      const SizedBox(width: 4)
                                    ],
                                    if (vegetarian) ...[
                                      Icon(Icons.spa,
                                          size: 20, color: theme.tertiary),
                                      const SizedBox(width: 4)
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
