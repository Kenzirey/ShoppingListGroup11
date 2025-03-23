import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';

/// A screen for showing what products the user wishes to buy
/// on their next shopping trip.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListState createState() => ShoppingListState();
}

class ShoppingListState extends ConsumerState<ShoppingListScreen> {
  // Track item quantities
  Map<String, int> itemQuantities = {
    'Apples': 1,
    'Bananas': 1,
    'Carrots': 1,
    'Eggs': 1,
    'Milk': 1,
    'Bread': 1,
    'Cheese': 1,
    'Monster Ultra Violet': 50,
    "Billy's Pizza": 5,
  };
  final SearchController _searchController = SearchController();

  // Store deleted item details for undo
  String? lastDeletedItem;
  int? lastDeletedQuantity;
  int? lastDeletedIndex;

  @override
  Widget build(BuildContext context) {
    final shoppingItems = itemQuantities.keys.toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // new search widget on top instead
            CustomSearchBarWidget(
              suggestions: shoppingItems,
              onSuggestionSelected: (suggestion) {
                debugPrint("Selected: $suggestion");
              },
              hintText: 'Search products...',
            ),

            const SizedBox(height: 16.0),
            // Title + filter button below search
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
                    // TODO: Implement filter toggle logic
                  },
                  icon: Icon(
                    Icons.swap_vert,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                      bottom: 120.0), // temporary padding, need to test
                  itemCount: shoppingItems.length,
                  itemBuilder: (context, index) {
                    final item = shoppingItems[index];

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
                          itemQuantities.remove(item);
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
                                    final List<MapEntry<String, int>> entries =
                                        itemQuantities.entries.toList();

                                    entries.insert(
                                        lastDeletedIndex!,
                                        MapEntry(lastDeletedItem!,
                                            lastDeletedQuantity!));

                                    itemQuantities = Map.fromEntries(entries);
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Grocery Icon & Item Name
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.local_grocery_store,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      item,
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
                                ],
                              ),
                            ),
                            // The item quantity selector (where we have + and -)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (itemQuantities[item]! > 1) {
                                          itemQuantities[item] =
                                              itemQuantities[item]! - 1;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.remove,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  child: Center(
                                    child: Text(
                                      '${itemQuantities[item]}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        itemQuantities[item] =
                                            itemQuantities[item]! + 1;
                                      });
                                    },
                                    icon: Icon(Icons.add,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
