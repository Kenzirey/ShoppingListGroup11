import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    'Milk': '2 days',
    'Cheese': '3 days',
    'Yogurt': '5 days',
    'Carrots': '2 days',
  };

  /// Returns an icon for expiring items, temporary setup
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
    final mealSuggestions = ref.watch(mealSuggestionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ShelfAware',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Expiring Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
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
                        // left side, icon and name
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                _getExpiringIcon(item),
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // when it expires
                        Text(
                          expiryTime ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Meal Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: mealSuggestions.length,
                itemBuilder: (context, index) {
                  final meal = mealSuggestions[index];
                  final mealName = meal['name'] as String;
                  final servings = meal['servings'] as int? ?? 1;
                  final lactoseFree = meal['lactoseFree'] as bool? ?? false;
                  final vegan = meal['vegan'] as bool? ?? false;
                  final vegetarian = meal['vegetarian'] as bool? ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip
                          .hardEdge, // so that the "press / hold" feedback is contained within the item, not outside
                      child: InkWell(
                        onTap: () {
                          // navigate via meal provider the meal which matches this name.
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          child: Row(
                            children: [
                              // Servings icon and number.
                              Icon(
                                servings > 1 ? Icons.people : Icons.person,
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$servings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Meal name and additional icons.
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        mealName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (lactoseFree || vegan || vegetarian)
                                      const SizedBox(width: 8),
                                    if (lactoseFree) ...[
                                      Icon(
                                        Icons.icecream,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (vegan) ...[
                                      Icon(
                                        Icons.eco,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (vegetarian) ...[
                                      Icon(
                                        Icons.spa,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      const SizedBox(width: 4),
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
