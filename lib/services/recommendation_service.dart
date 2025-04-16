import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> fetchRecommendations(String userId) async {
    try {
      final result = await _client
          .from('recommendations')
          .select('items')
          .eq('user_id', userId)
          .maybeSingle();

      if (result == null || result['items'] == null) {
        return [];
      }

      final List<dynamic> items = result['items'];
      return items.map((item) => item.toString()).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommendations: $e');
    }
  }
}
