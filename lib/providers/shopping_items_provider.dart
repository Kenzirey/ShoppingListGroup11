import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import 'package:shopping_list_g11/services/shopping_service.dart';
import 'package:shopping_list_g11/controllers/shopping_list_controller.dart';

class ShoppingItemsNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingItemsNotifier() : super([]);

  /// Replace the entire list of items
  void setItems(List<ShoppingItem> items) {
    state = items;
  }

  /// Add a single item to the state
  void addItem(ShoppingItem item) {
    state = [...state, item];
  }

  /// Update one item matching by ID in the state
  void updateItem(ShoppingItem updated) {
    state = state.map((item) => item.id == updated.id ? updated : item).toList();
  }

  /// Remove an item by ID
  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  
  /// append many items at once
  void addItems(List<ShoppingItem> items) {
    state = [...state, ...items];
  }

  /// wipe list (used by clear all button)
  void clear() => state = [];
}

final shoppingItemsProvider =
    StateNotifierProvider<ShoppingItemsNotifier, List<ShoppingItem>>(
  (ref) => ShoppingItemsNotifier(),
);

final shoppingServiceProvider = Provider<ShoppingService>((ref) {
  return ShoppingService();
});

final shoppingListControllerProvider =
    Provider<ShoppingListController>((ref) {
  final service = ref.watch(shoppingServiceProvider);
  return ShoppingListController(ref: ref, service: service);
});