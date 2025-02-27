import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/receipt_data.dart';

/// Handles Supabase communication for receipt data
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
    if (profileRow == null) {
      debugPrint('No profile row found.');
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

    // Insert each receipt item
    for (final item in receiptData.items) {
      try {
        await supabase.from('receipt_items').insert({
          'receipt_id': receiptId,
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'allergy': item.allergy,
          'added_at': DateTime.now().toIso8601String(),
        }).select().single();
      } catch (e) {
        debugPrint('Error inserting item "${item.name}": $e');
      }
    }
  }
}