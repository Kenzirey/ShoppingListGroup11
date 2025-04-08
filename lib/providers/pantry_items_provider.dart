import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';

class PantryItemsNotifier extends StateNotifier<List<PantryItem>> {
  PantryItemsNotifier() : super([]);

  void setItems(List<PantryItem> items) {
    state = items;
  }

  void addItem(PantryItem item) {
    state = [...state, item];
  }

  void updateItem(PantryItem updated) {
    state = state.map((item) => item.id == updated.id ? updated : item).toList();
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final pantryItemsProvider =
    StateNotifierProvider<PantryItemsNotifier, List<PantryItem>>(
  (ref) => PantryItemsNotifier(),
);
