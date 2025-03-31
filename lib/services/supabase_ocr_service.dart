import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_list_g11/services/shelf_life.dart';
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
        final standardizedName = item.name.toLowerCase();
        final shelfDays = ShelfLife.getShelfLife(standardizedName);
        final parsedReceiptDate = _parseDateOrNow(receiptData.date);
        final expirationDate = parsedReceiptDate.add(Duration(days: shelfDays));

        await supabase.from('receipt_items').insert({
          'receipt_id': receiptId,
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'allergy': item.allergy,
          'added_at': DateTime.now().toIso8601String(),
          'expiration_date': expirationDate.toIso8601String(),
        }).select().single();

      } catch (e) {
        debugPrint('Error inserting item "${item.name}": $e');
      }
    }
  }

  /// Parse a date string or return the current date
  DateTime _parseDateOrNow(String dateString) {
    final dt = DateTime.tryParse(dateString);
    return dt ?? DateTime.now();
  }
}
