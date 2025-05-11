import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/styles/dialog/add_product_dialog.dart';
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
  // ignore: unused_field, prefer_final_fields
  bool _loading = false; // this is false, it is actually being used..

  @override
  void initState() {
    super.initState();
    final profileId = ref.read(currentUserValueProvider)?.profileId;
    _initialFetch = profileId != null
        ? ref.read(shoppingListControllerProvider).fetchShoppingItems(profileId)
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

    final theme = Theme.of(context);

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
        final ctrl = ref.read(shoppingListControllerProvider);
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
                      // Title setup like the other screens
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Shopping List',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // the sort & clear button section here
                          Row(
                            children: [
                              Tooltip(
                                message:
                                    "Sort items by ${ctrl.isAscending ? 'oldest first' : 'latest first'}",
                                child: TextButton.icon(
                                  onPressed: () async {
                                    if (userId == null) return;
                                    setState(() => _loading = true);
                                    await ctrl.toggleSortOrder(userId);
                                    setState(() => _loading = false);
                                  },
                                  icon: Icon(
                                    Icons.swap_vert,
                                    color: theme.colorScheme.tertiary,
                                    semanticLabel: "Sort icon", // Added semanticLabel for the sort icon
                                  ),
                                  label: Text(
                                    ctrl.isAscending ? 'Oldest' : 'Latest',
                                    style: TextStyle(
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                                ),
                              ),
                              Tooltip(
                                message:
                                    "Clear all items from the shopping list", // This describes the button's action
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final user =
                                        ref.read(currentUserValueProvider);
                                    final currentItems =
                                        ref.read(shoppingItemsProvider);
                                    final count = currentItems.length;
                                    if (user == null ||
                                        user.profileId == null ||
                                        count == 0) return;
                                    final profileId = user.profileId!;
                                    final backup =
                                        List<ShoppingItem>.from(currentItems);
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
                                    color: theme.colorScheme.tertiary,
                                    semanticLabel:
                                        "Trash can icon", // This describes the icon itself
                                  ),
                                  label: Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: theme.colorScheme.tertiary,
                                    ),
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
                          padding:
                              const EdgeInsets.only(bottom: 120.0, top: 8.0),
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

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 12.0), 
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Dismissible(
                                  key: Key(itemObj.id ?? itemName),
                                  direction: DismissDirection.endToStart, 
                                  background: const SizedBox
                                      .shrink(), 
                                  secondaryBackground: Container(
                                    color: theme.colorScheme
                                        .error, 
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Semantics(
                                      label: "Delete item",
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
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
                                          innerPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          actionText: 'Undo',
                                          onAction: () async {
                                            if (lastDeletedItem != null &&
                                                lastDeletedIndex != null) {
                                              final currentUser = ref.read(
                                                  currentUserValueProvider);
                                              if (currentUser != null &&
                                                  currentUser.profileId !=
                                                      null) {
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
                                  child: Container( 
                                    color: theme.colorScheme
                                        .primaryContainer, 
                                    child: ShoppingListItem(
                                      item: itemName,
                                      quantityText: quantityText,
                                      unitLabel: displayUnit,
                                      onQuantityChanged: (newQuantity) async {
                                        if (itemObj.id != null) {
                                          final oldUnit =
                                              QuantityParser.parseUnit(
                                                  itemObj.quantity ?? '');
                                          final newQuantityString =
                                              '$newQuantity $oldUnit'.trim();
                                          await ref
                                              .read(
                                                  shoppingListControllerProvider)
                                              .updateShoppingItem(
                                                itemId: itemObj.id!,
                                                newQuantity: newQuantityString,
                                              );
                                        }
                                      },
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
                        final currentUser = ref.read(currentUserValueProvider);
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
                      backgroundColor: theme.colorScheme.secondary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16.0),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 32.0,
                      color: theme.colorScheme.tertiary,
                      semanticLabel: "Add new shopping item",
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
