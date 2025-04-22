import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';
import 'package:shopping_list_g11/services/pantry_service.dart';
import 'package:shopping_list_g11/controllers/pantry_controller.dart';

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


final pantryServiceProvider = Provider<PantryService>((ref) {
  return PantryService();
});

final pantryControllerProvider = Provider<PantryController>((ref) {
  final service = ref.watch(pantryServiceProvider);
  return PantryController(ref: ref, service: service);
});