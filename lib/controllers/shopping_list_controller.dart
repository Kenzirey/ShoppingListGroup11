import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_items_provider.dart';
import 'package:shopping_list_g11/services/shopping_service.dart';


class ShoppingListController {
  final Ref ref;
  final ShoppingService _service;

  ShoppingListController({
    required this.ref,
    required ShoppingService service,
  }) : _service = service;

  /// Fetch all items and write into state.
  Future<void> fetchShoppingItems(String userId) async {
    try {
      final items = await _service.fetchItems(userId);
      ref.read(shoppingItemsProvider.notifier).setItems(items);
    } catch (e) {
      rethrow;
    }
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
