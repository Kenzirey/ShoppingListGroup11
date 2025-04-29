import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_list_g11/models/shopping_item.dart';


class ShoppingService {
  final SupabaseClient _db;

  ShoppingService({SupabaseClient? client})
      : _db = client ?? Supabase.instance.client;

  /// fetches all shopping items for [userId].
  Future<List<ShoppingItem>> fetchItems(String userId) async {
    final resp = await _db
        .from('to_buy')
        .select('*')
        .eq('user_id', userId);
    return (resp as List)
        .map((m) => ShoppingItem.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  /// Create inserts [item] into to_buy and returns the created row.
  Future<ShoppingItem> addItem(ShoppingItem item) async {
    final resp = await _db
        .from('to_buy')
        .insert(item.toMap())
        .select();
    return ShoppingItem.fromMap((resp as List).first as Map<String, dynamic>);
  }

  /// removes the row with id == [itemId].
  Future<void> removeItem(String itemId) async {
    await _db.from('to_buy').delete().match({'id': itemId});
  }

  /// patches [changes] into the row with id == [itemId].
  /// Returns the updated item or null if no row matched.
  Future<ShoppingItem?> updateItem(
      String itemId, Map<String, dynamic> changes) async {
    final resp = await _db
        .from('to_buy')
        .update(changes)
        .match({'id': itemId})
        .select();
    final list = resp as List;
    if (list.isEmpty) return null;
    return ShoppingItem.fromMap(list.first as Map<String, dynamic>);
  }

  /// Inserts a batch of items in a single call and returns the
  /// rows as they came back from the database.
  Future<List<ShoppingItem>> addItems(List<ShoppingItem> items) async {
    if (items.isEmpty) return [];

    final rows = items.map((e) => e.toMap()).toList();

    final resp = await _db
        .from('to_buy')
        .insert(rows)
        .select();

    return (resp as List)
        .map((m) => ShoppingItem.fromMap(m as Map<String, dynamic>))
        .toList();
  }
  Future<void> clearUserItems(String userId) async {
    await _db.from('to_buy').delete().eq('user_id', userId);
  }

}
