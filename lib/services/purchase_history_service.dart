import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

/// This service fetches the purchase history of a user from the Supabase database.
class PurchaseHistoryService {
  final _supabase = Supabase.instance.client;

  Future<List<Product>> fetchPurchaseHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final profileData = await _supabase
          .from('profiles')
          .select('id')
          .eq('auth_id', user.id)
          .single();

      final profileId = profileData['id'];

      // plain select – one row per purchase event
      final rows = await _supabase
          .from('purchase_history')
          .select()
          .eq('user_id', profileId)
          .order('purchased_at', ascending: false);

      return rows.map<Product>((row) {
        final unit   = row['unit'] ?? '';
        final amount = '${row['purchase_count']} $unit'.trim();

        return Product.fromName(
          name        : row['item_name'],
          purchaseDate: DateTime.parse(row['purchased_at']),
          price       : (row['price'] ?? 0).toString(),
          amount      : amount,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching purchase history: $e');
      return [];
    }
  }
}
