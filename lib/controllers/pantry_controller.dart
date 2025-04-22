import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';
import '../providers/pantry_items_provider.dart';
import '../services/pantry_service.dart';

class PantryController {
  final Ref ref;
  final PantryService _service;

  PantryController({
    required this.ref,
    required PantryService service,
  }) : _service = service;

  /// Fetch pantry items from inventory for the given user.
  Future<void> fetchPantryItems(String userId) async {
    try {
      final items = await _service.fetchItems(userId);
      ref.read(pantryItemsProvider.notifier).setItems(items);
    } catch (e) {
      rethrow;
    }
  }

  /// Add an item to the users inventory
  Future<void> addPantryItem(PantryItem item) async {
    try {
      final newItem = await _service.addItem(item);
      ref.read(pantryItemsProvider.notifier).addItem(newItem);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove an item by ID
  Future<void> removePantryItem(String itemId) async {
    try {
      await _service.removeItem(itemId);
      ref.read(pantryItemsProvider.notifier).removeItem(itemId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing pantry item.
  Future<void> updatePantryItem(String itemId,
      {required String name, required double amount, required String unit}) async {
    try {
      final updated = await _service.updateItem(itemId, {
        'name': name,
        'amount': amount,
        'unit': unit,
      });
      if (updated != null) {
        ref.read(pantryItemsProvider.notifier).updateItem(updated);
      }
    } catch (e) {
      rethrow;
    }
  }
}
