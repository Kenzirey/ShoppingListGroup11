import 'dart:convert';
import 'package:http/http.dart' as http;

/// A service for fetching product recommendations from a FastAPI backend.
class RecommendationService {
  final String baseUrl;

  RecommendationService({required this.baseUrl});

  /// Fetches recommended items for a given userId, returning a list of item IDs or names.
  Future<List<String>> fetchRecommendations(String userId, {int topN = 5}) async {
    final url = Uri.parse('$baseUrl/recommend/$userId?top_n=$topN');
    final response = await http.get(url);

    /// Check if the response is successful
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['recommendations']);
    } else {
      throw Exception('Failed to fetch recommendations: '
          'HTTP ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
