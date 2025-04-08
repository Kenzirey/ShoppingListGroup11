import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pantry_item.dart';
import '../providers/pantry_items_provider.dart';

final pantryControllerProvider = Provider<PantryController>((ref) {
  return PantryController(ref: ref);
});

class PantryController {
  final Ref ref;

  PantryController({required this.ref});

  /// Fetch pantry items from inventory for the given user.
  Future<void> fetchPantryItems(String userId) async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('inventory')
          .select('*')
          .eq('user_id', userId);

      final items = response.map((map) => PantryItem.fromMap(map)).toList();

      ref.read(pantryItemsProvider.notifier).setItems(items);
    } catch (e) {
      rethrow;
    }
  }

  /// Add an item to the users inventory
  Future<void> addPantryItem(PantryItem item) async {
    try {

      final List<dynamic> insertResponse = await Supabase.instance.client
          .from('inventory')
          .insert(item.toMap())
          .select();

      final insertedData = insertResponse.first;
      final newItem = PantryItem.fromMap(insertedData);

      ref.read(pantryItemsProvider.notifier).addItem(newItem);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove an item by ID
  Future<void> removePantryItem(String itemId) async {
    try {
      await Supabase.instance.client
          .from('inventory')
          .delete()
          .match({'id': itemId});

      ref.read(pantryItemsProvider.notifier).removeItem(itemId);
    } catch (e) {
      rethrow;
    }
  }

}
