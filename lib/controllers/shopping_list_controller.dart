import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_items_provider.dart';


final shoppingListControllerProvider = Provider<ShoppingListController>((ref) {
  return ShoppingListController(ref: ref);
});

class ShoppingListController {
  final Ref ref;

  ShoppingListController({required this.ref});

  /// Fetch all items from to_buy for the given user.
  Future<void> fetchShoppingItems(String userId) async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('to_buy')
          .select('*')
          .eq('user_id', userId);

      final items = response.map((row) => ShoppingItem.fromMap(row)).toList();
      ref.read(shoppingItemsProvider.notifier).setItems(items);
    } catch (e) {
      rethrow;
    }
  }

  /// Insert a new shopping item into to_buy.
  Future<void> addShoppingItem(ShoppingItem item) async {
    try {
      final List<dynamic> insertResponse = await Supabase.instance.client
          .from('to_buy')
          .insert(item.toMap())
          .select();

      final insertedMap = insertResponse.first;
      final newItem = ShoppingItem.fromMap(insertedMap);
      ref.read(shoppingItemsProvider.notifier).addItem(newItem);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a shopping item by ID.
  Future<void> removeShoppingItem(String itemId) async {
    try {
      await Supabase.instance.client
          .from('to_buy')
          .delete()
          .match({'id': itemId});
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
    // Build a partial update map
    final updateData = <String, dynamic>{};
    if (newQuantity != null) updateData['quantity'] = newQuantity;
    if (newCategory != null) updateData['category'] = newCategory;

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('to_buy')
          .update(updateData)
          .eq('id', itemId)
          .select();

      final updatedRow = response.first;
      final updatedItem = ShoppingItem.fromMap(updatedRow);
      ref.read(shoppingItemsProvider.notifier).updateItem(updatedItem);
    } catch (e) {
      rethrow;
    }
  }
}
