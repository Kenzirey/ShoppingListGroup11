import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/add_product_dialog.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/widget/shopping_list_item.dart';
import 'package:shopping_list_g11/models/shopping_item.dart';
import 'package:shopping_list_g11/providers/shopping_items_provider.dart';
import 'package:shopping_list_g11/controllers/shopping_list_controller.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';

/// A screen for showing what products the user wishes to buy
/// on their next shopping trip.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ShoppingListState createState() => ShoppingListState();
}

class ShoppingListState extends ConsumerState<ShoppingListScreen> {
  ShoppingItem? lastDeletedItem;
  int? lastDeletedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null && currentUser.profileId != null) {
        await ref
            .read(shoppingListControllerProvider)
            .fetchShoppingItems(currentUser.profileId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItems = ref.watch(shoppingItemsProvider);
    const horizontalPadding = 16.0;

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
                  suggestions: shoppingItems.map((e) => e.itemName).toList(),
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
                        // any logic for reordering/deleting etc.
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
                      final itemObj = shoppingItems[index];
                      final itemName = itemObj.itemName;
                      final quantityText = itemObj.quantity ?? '';
                      final String parsedUnit =
                          QuantityParser.parseUnit(quantityText);
                      final bool isCountBased = parsedUnit.isEmpty;
                      final String displayUnit = isCountBased ? '' : parsedUnit;

                      return Dismissible(
                        key: Key(itemObj.id ?? itemName),
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
                        onDismissed: (direction) async {
                          lastDeletedItem = itemObj;
                          lastDeletedIndex = index;
                          if (itemObj.id != null) {
                            await ref
                                .read(shoppingListControllerProvider)
                                .removeShoppingItem(itemObj.id!);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$itemName removed'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor:
                                    Theme.of(context).colorScheme.secondary,
                                onPressed: () async {
                                  if (lastDeletedItem != null &&
                                      lastDeletedIndex != null) {
                                    final currentUser =
                                        ref.read(currentUserProvider);
                                    if (currentUser != null &&
                                        currentUser.profileId != null) {
                                      await ref
                                          .read(shoppingListControllerProvider)
                                          .addShoppingItem(lastDeletedItem!);
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: ShoppingListItem(
                          item: itemName,
                          quantityText: quantityText,
                          unitLabel: displayUnit,
                          onQuantityChanged: (newQuantity) async {
                            if (itemObj.id != null) {
                              final oldUnit =
                                  QuantityParser.parseUnit(itemObj.quantity ?? '');
                              final newQuantityString =
                                  '$newQuantity $oldUnit'.trim();
                              await ref
                                  .read(shoppingListControllerProvider)
                                  .updateShoppingItem(
                                    itemId: itemObj.id!,
                                    newQuantity: newQuantityString,
                                  );
                            }
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
                  final name = result['name'] as String;
                  final amountValue = result['amount'] as int? ?? null;
                  final unit = result['unit'] as String? ?? '';
                  final finalQuantity = '$amountValue $unit'.trim();
                  final currentUser = ref.read(currentUserProvider);
                  if (currentUser != null && currentUser.profileId != null) {
                    await ref.read(shoppingListControllerProvider).addShoppingItem(
                      ShoppingItem(
                        userId: currentUser.profileId!,
                        itemName: name,
                        quantity: finalQuantity,
                        category: unit,
                      ),
                    );
                  }
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
