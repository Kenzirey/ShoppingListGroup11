import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/shopping_item.dart';

/// Screen for giving suggestions on what the user should purchase next.
/// Based on their habits of what they frequently buy.
class ShoppingSuggestionsScreen extends ConsumerStatefulWidget {
  const ShoppingSuggestionsScreen({super.key});

  @override
  ConsumerState<ShoppingSuggestionsScreen> createState() =>
      _ShoppingSuggestionsScreenState();
}

class _ShoppingSuggestionsScreenState
    extends ConsumerState<ShoppingSuggestionsScreen> {
  // Define sample shopping items.
  final List<ShoppingItem> weeklyItems = [
    ShoppingItem(name: 'Eggs'),
    ShoppingItem(name: 'Milk', icon: Icons.no_drinks),
    ShoppingItem(name: 'Bread', icon: Icons.no_food),
    ShoppingItem(name: 'Cheese', icon: Icons.eco),
  ];

  final List<ShoppingItem> monthlyItems = [
    ShoppingItem(name: 'Rice'),
    ShoppingItem(name: 'Pasta', icon: Icons.no_food),
    ShoppingItem(name: 'Canned Beans', icon: Icons.eco),
    ShoppingItem(name: 'Tomato Sauce'),
  ];

  // The constant quantity string.
  // TEMPORARY :)
  final String quantity = '1 unit';

  /// Toggles selection for all shopping items (weekly and monthly).
  /// Probably need to alter this when things are dynamic.
  void _toggleSelectAll() {
    final bool allSelected = weeklyItems.every((item) => item.isSelected) &&
        monthlyItems.every((item) => item.isSelected);
    setState(() {
      for (var item in weeklyItems) {
        item.isSelected = !allSelected;
      }
      for (var item in monthlyItems) {
        item.isSelected = !allSelected;
      }
    });
  }

  /// Action for the "Shopping list" button.
  void _onAddPressed() {
    final selectedItems = [
      ...weeklyItems.where((item) => item.isSelected),
      ...monthlyItems.where((item) => item.isSelected),
    ];
    debugPrint(
        "Add pressed. Selected items: ${selectedItems.map((i) => i.name).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    // Access theme colors, to not have to repeat all the theme of stuff.
    final color = Theme.of(context).colorScheme.tertiary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final background = primaryContainer;

    // find if all are selected
    final bool allSelected = weeklyItems.every((item) => item.isSelected) &&
        monthlyItems.every((item) => item.isSelected);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header text.
            Text(
              'Shopping Suggestions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Add items to shopping list?',
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                // Left side: Add selected.
                Expanded(
                  child: InkWell(
                    onTap: _onAddPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryContainer,
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            size: 20,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side with "Select all" button, outlined and changes color upon selected/not.
                Expanded(
                  child: InkWell(
                    onTap: _toggleSelectAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: allSelected
                            ? primaryColor.withOpacity(0.3)
                            : primaryContainer,
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'Select all',
                          style: TextStyle(
                            fontSize: 16,
                            color: allSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Weekly Section Header.
            Text(
              'Weekly',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            // Weekly items.
            ...weeklyItems.map((item) {
              final containerColor =
                  item.isSelected ? primaryColor.withOpacity(0.3) : background;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                // wrap container to only have inkwell splash contained with the actual item
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        item.isSelected = !item.isSelected;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Display the cart icon.
                          Icon(
                            Icons.shopping_cart,
                            size: 20,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          // Item name and quantity.
                          Expanded(
                            child: Text(
                              '${item.name} | $quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Checkbox indicator.
                          item.isSelected
                              ? Icon(Icons.check_box_outlined,
                                  size: 20, color: primaryColor)
                              : Icon(Icons.check_box_outline_blank,
                                  size: 20, color: color),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Monthly Section Header.
            Text(
              'Monthly',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            // Monthly items.
            ...monthlyItems.map((item) {
              final containerColor =
                  item.isSelected ? primaryColor.withOpacity(0.3) : background;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        item.isSelected = !item.isSelected;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: containerColor,
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
                            child: Text(
                              '${item.name} | $quantity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          item.isSelected
                              ? Icon(Icons.check_box_outlined,
                                  size: 20, color: primaryColor)
                              : Icon(Icons.check_box_outline_blank,
                                  size: 20, color: color),
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
