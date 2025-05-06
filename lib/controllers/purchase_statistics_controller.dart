import 'package:supabase_flutter/supabase_flutter.dart';

/// This class is responsible for fetching purchase statistics from the Supabase database.
class PurchaseStatisticsController {
  final SupabaseClient supabase;
  final String? profileId;

  PurchaseStatisticsController({
    required this.supabase,
    required this.profileId,
  });

  Future<List<Map<String, dynamic>>> getPurchasesByMonth(int year, int month) async {
    if (profileId == null) {
      return [];
    }

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    try {
      final response = await supabase
          .from('purchase_history')
          .select()
          .gte('purchased_at', startDate.toIso8601String())
          .lte('purchased_at', endDate.toIso8601String())
          .eq('user_id', profileId!);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPurchasesByYear(int year) async {
    if (profileId == null) {
      return [];
    }

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    try {
      final response = await supabase
          .from('purchase_history')
          .select()
          .gte('purchased_at', startDate.toIso8601String())
          .lte('purchased_at', endDate.toIso8601String())
          .eq('user_id', profileId!);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}