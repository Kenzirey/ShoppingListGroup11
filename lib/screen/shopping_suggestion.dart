import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingSuggestionsScreen extends ConsumerStatefulWidget {
  const ShoppingSuggestionsScreen({super.key});

  @override
  ConsumerState<ShoppingSuggestionsScreen> createState() =>
      _ShoppingSuggestionsScreenState();
}

class _ShoppingSuggestionsScreenState
    extends ConsumerState<ShoppingSuggestionsScreen> {
  final List<Map<String, dynamic>> weeklyItems = [
    {'name': 'Eggs', 'icon': null},
    {'name': 'Milk', 'icon': Icons.no_drinks},      // lactose-free
    {'name': 'Bread', 'icon': Icons.no_food},       // gluten-free
    {'name': 'Cheese', 'icon': Icons.eco},          // vegetarian
  ];

  final List<Map<String, dynamic>> monthlyItems = [
    {'name': 'Rice', 'icon': null},
    {'name': 'Pasta', 'icon': Icons.no_food},
    {'name': 'Canned Beans', 'icon': Icons.eco},
    {'name': 'Tomato Sauce', 'icon': null},
  ];

  final String quantity = '1 unit';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    final background = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.centerLeft,
            child: Text('Shopping Suggestions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            // Weekly Section
            Text(
              'Weekly',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...weeklyItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item['icon'] != null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                item['icon'],
                                size: 16,
                                color: color,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        quantity,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

            // Monthly Section
            Text(
              'Monthly',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...monthlyItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item['icon'] != null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                item['icon'],
                                size: 16,
                                color: color,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        quantity,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
