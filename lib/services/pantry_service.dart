import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_list_g11/models/pantry_item.dart';

class PantryService {
  final SupabaseClient _db;

  /// Creates a [PantryService], using the provided Supabase client or
  /// the singleton instance by default.
  PantryService({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  /// Fetches all pantry items belonging to [userId].
  /// Returns a list of mapped [PantryItem] objects.
  Future<List<PantryItem>> fetchItems(String userId) async {
    final resp = await _db.from('inventory').select('*').eq('user_id', userId);
    final list = (resp as List).map((m) => PantryItem.fromMap(m)).toList();
    return list;
  }

  /// Inserts [item] into the inventory table.
  /// Returns the created [PantryItem] including its generated ID.
  Future<PantryItem> addItem(PantryItem item) async {
    final resp = await _db.from('inventory').insert(item.toMap()).select();
    return PantryItem.fromMap((resp as List).first);
  }

  /// Deletes the pantry item with the given [itemId].
  Future<void> removeItem(String itemId) async {
    await _db.from('inventory').delete().match({'id': itemId});
  }

  /// Applies [changes] to the pantry item identified by [itemId].
  /// Returns the updated [PantryItem] or null if no row matched.
  Future<PantryItem?> updateItem(
      String itemId, Map<String, dynamic> changes) async {
    final resp = await _db
        .from('inventory')
        .update(changes)
        .match({'id': itemId}).select();
    final list = resp as List;
    if (list.isEmpty) return null;
    return PantryItem.fromMap(list.first);
  }
}
