import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_items_provider.dart';
import 'package:shopping_list_g11/services/shopping_service.dart';


class ShoppingListController {
  final Ref ref;
  final ShoppingService _service;
  bool _ascending = false;
  bool get isAscending => _ascending;

  ShoppingListController({
    required this.ref,
    required ShoppingService service,
  }) : _service = service;

  /// Fetch all items, server sorted by created_at.
  /// the Supabase table to_buy has:
  /// ALTER COLUMN created_at SET DEFAULT now();
  /// so that each row is timestamped on insert.
  /// The client omits created_at in the payload to allow the database default to apply.
  /// [userId] is the Supabase profile ID. [ascending] flips between oldest first (true) and newest first (false).
  Future<void> fetchShoppingItems(String userId) async {
    final items = await _service.fetchItems(
      userId,
      ascending: _ascending,
    );
    ref.read(shoppingItemsProvider.notifier).setItems(items);
  }

  /// Toggle sort direction and re fetch
  Future<void> toggleSortOrder(String userId) async {
    _ascending = !_ascending;
    await fetchShoppingItems(userId);
  }

  /// Create a new shopping item.
  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      final newItem = await _service.addItem(item);
      ref.read(shoppingItemsProvider.notifier).addItem(newItem);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a shopping item by ID.
  Future<void> removeShoppingItem(String itemId) async {
    try {
      await _service.removeItem(itemId);
      ref.read(shoppingItemsProvider.notifier).removeItem(itemId);
    } catch (e) {
      rethrow;
    }
  }

  /// updating quantity or category
  Future<void> updateShoppingItem({
    required String itemId,
    String? newQuantity,
    String? newCategory,
  }) async {
    final changes = <String, dynamic>{};
    if (newQuantity != null) changes['quantity'] = newQuantity;
    if (newCategory != null) changes['category'] = newCategory;

    try {
      final updated = await _service.updateItem(itemId, changes);
      if (updated != null) {
        ref.read(shoppingItemsProvider.notifier).updateItem(updated);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// add many
  Future<void> addShoppingItems(List<ShoppingItem> items) async {
    if (items.isEmpty) return;
    final inserted = await _service.addItems(items);
    ref.read(shoppingItemsProvider.notifier).addItems(inserted);
  }

  /// clear all for a user
  Future<void> clearAll(String userId) async {
    await _service.clearUserItems(userId);  
    ref.read(shoppingItemsProvider.notifier).clear(); 
  }
}
