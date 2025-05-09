import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';
import 'package:shopping_list_g11/services/pantry_service.dart';
import 'package:shopping_list_g11/controllers/pantry_controller.dart';

///// StateNotifier for managing pantry items.
class PantryItemsNotifier extends StateNotifier<List<PantryItem>> {
  PantryItemsNotifier() : super([]);

  /// Set state to [items].
  void setItems(List<PantryItem> items) {
    state = items;
  }
  
  /// Add [item] to state.
  void addItem(PantryItem item) {
    state = [...state, item];
  }

  /// Update item in state by its [id].
  void updateItem(PantryItem updated) {
    state = state.map((item) => item.id == updated.id ? updated : item).toList();
  }

  /// Remove item from state by its [id].
  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Insert [item] back into state at its previous[index].
  void insertAt(int index, PantryItem item) {
    final updated = [...state];
    updated.insert(index, item);
    state = updated;
  }
}

final pantryItemsProvider =
    StateNotifierProvider<PantryItemsNotifier, List<PantryItem>>(
  (ref) => PantryItemsNotifier(),
);


final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService();
});

final pantryControllerProvider = Provider<PantryController>((ref) {
  final service = ref.watch(pantryServiceProvider);
  return PantryController(ref: ref, service: service);
});