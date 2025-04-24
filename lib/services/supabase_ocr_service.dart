import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/receipt_data.dart';

/// Handles Supabase communication
class SupabaseService {
  Future<void> saveReceipt(ReceiptData receiptData) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('User not logged in!');
      return;
    }

    Map<String, dynamic>? profileRow;
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('auth_id', user.id)
          .single();
      profileRow = response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return;
    }
    final profileId = profileRow['id'];

    Map<String, dynamic> insertedReceipt;
    try {
      insertedReceipt = await supabase
          .from('receipts')
          .insert({
        'user_id': profileId,
        'store_name': receiptData.storeName,
        'total_amount': receiptData.total,
        'uploaded_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();
    } catch (e) {
      debugPrint('Error inserting receipt: $e');
      return;
    }
    final receiptId = insertedReceipt['id'];

    for (final item in receiptData.items) {
      try {
        final expirationDate = item.expirationDate ??
            DateTime.now().add(const Duration(days: 10));

        await supabase.from('receipt_items').insert({
          'receipt_id': receiptId,
          'name': item.name,
          'quantity': item.quantity.round(),
          'price': item.price,
          "allergy": item.allergy,
          "unit": item.unit,
          'added_at': DateTime.now().toIso8601String(),
          'expiration_date': expirationDate.toIso8601String(),
          'category': item.category,
        }).select().single();

        await supabase.from('inventory').upsert({
          'user_id': profileId,
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity.toString(),
          'unit': item.unit,
          'expiration_date': expirationDate.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });

        await supabase.from('purchase_history').insert({
          'user_id'     : profileId,
          'item_name'   : item.name,
          'category'    : item.category,
          'purchase_count': item.quantity.round(),
          'unit'        : item.unit,
          'price'       : item.price,
          'purchased_at': DateTime.now().toIso8601String(),
        }).select();
      } catch (e) {
        debugPrint('Error inserting item "${item.name}": $e');
      }
    }
  }
}
