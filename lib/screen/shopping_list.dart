import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/add_product_dialog.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import 'package:shopping_list_g11/widget/shopping_list_item.dart';
import 'package:shopping_list_g11/models/shopping_item.dart';
import 'package:shopping_list_g11/providers/shopping_items_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';
import 'package:shopping_list_g11/models/app_user.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';

/// A screen for showing what products the user wishes to buy
/// on their next shopping trip.
///
/// Allows user to add or remove items to the shopping list.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListState();
}

class _ShoppingListState extends ConsumerState<ShoppingListScreen> {
  late Future<void> _initialFetch;
  ShoppingItem? lastDeletedItem;
  int? lastDeletedIndex;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final profileId = ref.read(currentUserValueProvider)?.profileId;
    _initialFetch = profileId != null
      ? ref.read(shoppingListControllerProvider)
          .fetchShoppingItems(profileId)
      : Future.value();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppUser?>(currentUserValueProvider, (prev, next) {
      if (prev?.profileId == null && next != null && next.profileId != null) {
        ref
            .read(shoppingListControllerProvider)
            .fetchShoppingItems(next.profileId!);
      }
    });

    return FutureBuilder<void>(
      future: _initialFetch,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading shopping list'));
        }

        const horizontalPadding = 16.0;
        final items = ref.watch(shoppingItemsProvider);
        final ctrl   = ref.read(shoppingListControllerProvider);
        final userId = ref.read(currentUserValueProvider)?.profileId;
        
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
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
                        suggestions:
                            items.map((e) => e.itemName).toList(),
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
                          Row(
                            children: [
                        TextButton.icon(
                          onPressed: () async {
                            if (userId == null) return;
                            setState(() => _loading = true);
                            await ctrl.toggleSortOrder(userId);
                            setState(() => _loading = false);
                          },
                          icon: Icon(
                            Icons.swap_vert,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          label: Text(
                            // ascending==false newest first “Latest”
                            // ascending==true oldest first “Oldest”
                            ctrl.isAscending ? 'Oldest' : 'Latest',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),

                              TextButton.icon(
                                onPressed: () async {
                                  final user =
                                      ref.read(currentUserValueProvider);
                                  final items = ref.read(shoppingItemsProvider);
                                  final count = items.length;
                                  if (user == null ||
                                      user.profileId == null ||
                                      count == 0) return;
                                  final profileId = user.profileId!;
                                  final backup = List<ShoppingItem>.from(items);
                                  await ref
                                      .read(shoppingListControllerProvider)
                                      .clearAll(profileId);
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      CustomSnackbar.buildSnackBar(
                                        title: 'Cleared',
                                        message:
                                            'Shopping list cleared $count item${count == 1 ? '' : 's'}',
                                        innerPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        actionText: 'Undo',
                                        onAction: () async {
                                          await ref
                                              .read(
                                                  shoppingListControllerProvider)
                                              .addShoppingItems(backup);
                                        },
                                      ),
                                    );
                                },
                                icon: PantryIcons(
                                  category: 'trash',
                                  size: 20,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                label: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 120.0),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final itemObj = items[index];
                            final itemName = itemObj.itemName;
                            final quantityText = itemObj.quantity ?? '';
                            final String parsedUnit =
                                QuantityParser.parseUnit(quantityText);
                            final bool isCountBased = parsedUnit.isEmpty;
                            final String displayUnit =
                                isCountBased ? '' : parsedUnit;

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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                lastDeletedItem = itemObj;
                                lastDeletedIndex = index;
                                if (itemObj.id != null) {
                                  await ref
                                      .read(shoppingListControllerProvider)
                                      .removeShoppingItem(itemObj.id!);
                                }
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    CustomSnackbar.buildSnackBar(
                                      title: 'Removed',
                                      message: '$itemName removed',
                                      innerPadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      actionText: 'Undo',
                                      onAction: () async {
                                        if (lastDeletedItem != null &&
                                            lastDeletedIndex != null) {
                                          final currentUser = ref
                                              .watch(currentUserValueProvider);
                                          if (currentUser != null &&
                                              currentUser.profileId != null) {
                                            await ref
                                                .read(
                                                    shoppingListControllerProvider)
                                                .addShoppingItem(
                                                    lastDeletedItem!);
                                          }
                                        }
                                      },
                                    ),
                                  );
                              },
                              child: ShoppingListItem(
                                item: itemName,
                                quantityText: quantityText,
                                unitLabel: displayUnit,
                                onQuantityChanged: (newQuantity) async {
                                  if (itemObj.id != null) {
                                    final oldUnit = QuantityParser.parseUnit(
                                        itemObj.quantity ?? '');
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
                        final amountValue = result['amount'] as int;
                        final unit = result['unit'] as String? ?? '';
                        final finalQuantity = '$amountValue $unit'.trim();
                        final currentUser = ref.watch(currentUserValueProvider);
                        if (currentUser != null &&
                            currentUser.profileId != null) {
                          await ref
                              .read(shoppingListControllerProvider)
                              .addShoppingItem(
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
          ),
        );
      },
    );
  }
}
