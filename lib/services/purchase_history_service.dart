// lib/services/purchase_history_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

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

      final rows = await _supabase
        .from('purchase_history')
        .select('item_name, purchase_count, unit, price, purchased_at, category')
        .eq('user_id', profileId)
        .order('purchased_at', ascending: false);

      return rows.map<Product>((row) {
        final unit   = row['unit'] ?? '';
        final amount = '${row['purchase_count']} $unit'.trim();

        return Product(
          name        : row['item_name'] as String,
          purchaseDate: DateTime.parse(row['purchased_at'] as String),
          price       : (row['price'] ?? 0).toString(),
          amount      : amount,
          category    : row['category'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching purchase history: $e');
      return [];
    }
  }
}
