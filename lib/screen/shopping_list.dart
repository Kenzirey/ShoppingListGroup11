import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/add_product_dialog.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/widget/shopping_list_item.dart';
import '../data/measurement_type.dart';

/// A screen for showing what products the user wishes to buy
/// on their next shopping trip.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListState createState() => ShoppingListState();
}

class ShoppingListState extends ConsumerState<ShoppingListScreen> {
  // For regular items, we just store their quantity.
  Map<String, int> itemQuantities = {
    'Apples': 12,
    'Bananas': 1,
    'Carrots': 1,
    'Eggs': 1,
    'Milk': 3,
    'Bread': 1,
    'Cheese': 1,
    'Energy Drink': 50,
    'Frozen Pizza': 5,
  };

  // For custom items (added via the FAB) we store their unit in a separate map.
  Map<String, String> customItemUnits = {};

  final SearchController _searchController = SearchController();

  // For undo.
  String? lastDeletedItem;
  int? lastDeletedQuantity;
  int? lastDeletedIndex;
  String? lastDeletedUnit; // for custom items

  @override
  Widget build(BuildContext context) {
    final shoppingItems = itemQuantities.keys.toList();
    const horizontalPadding = 32.0;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchBarWidget(
                  suggestions: shoppingItems,
                  onSuggestionSelected: (suggestion) {
                    debugPrint("Selected: $suggestion");
                  },
                  hintText: 'Search products...',
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shopping List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Implement filter toggle logic.
                      },
                      icon: Icon(
                        Icons.swap_vert,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120.0),
                    itemCount: shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = shoppingItems[index];
                      final quantity = itemQuantities[item]!;
                      // Determine the unit:
                      // • If the item exists in your grocery mapping (via a case‑insensitive lookup),
                      //   use the mapped unit.
                      // • Otherwise, if there’s a custom unit saved for this item, use that.
                      // • Otherwise, use empty string.
                      String unit;
                      final mappedType = groceryMapping[item.toLowerCase()];
                      if (mappedType != null) {
                        unit = getUnitLabel(mappedType);
                      } else if (customItemUnits.containsKey(item)) {
                        unit = customItemUnits[item]!;
                      } else {
                        unit = '';
                      }
                      return Dismissible(
                        key: Key(item),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            lastDeletedItem = item;
                            lastDeletedQuantity = itemQuantities[item];
                            lastDeletedIndex = index;
                            lastDeletedUnit = customItemUnits.containsKey(item)
                                ? customItemUnits[item]
                                : '';
                            itemQuantities.remove(item);
                            customItemUnits.remove(item);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$item removed'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor:
                                    Theme.of(context).colorScheme.secondary,
                                onPressed: () {
                                  if (lastDeletedItem != null &&
                                      lastDeletedQuantity != null &&
                                      lastDeletedIndex != null) {
                                    setState(() {
                                      final entries =
                                          itemQuantities.entries.toList();
                                      entries.insert(
                                        lastDeletedIndex!,
                                        MapEntry(lastDeletedItem!,
                                            lastDeletedQuantity!),
                                      );
                                      itemQuantities = Map.fromEntries(entries);
                                      // Also restore custom unit if applicable.
                                      if (lastDeletedUnit != null &&
                                          lastDeletedUnit!.isNotEmpty) {
                                        customItemUnits[lastDeletedItem!] =
                                            lastDeletedUnit!;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: ShoppingListItem(
                          item: item,
                          quantity: quantity,
                          unitLabel: unit,
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              itemQuantities[item] = newQuantity;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: horizontalPadding,
            child: ElevatedButton(
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => const AddProductDialog(),
                );
                if (result != null) {
                  // add logic :)
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16.0),
              ),
              child: Icon(
                Icons.add,
                size: 32.0,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
