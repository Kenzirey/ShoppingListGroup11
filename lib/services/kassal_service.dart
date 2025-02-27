import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class KassalService {
  static const String _kBearerToken = 'jen8hGeedph78wDfqR37345l5lcIxCNjBHjjzjL4';
  static const String _kKassalBaseUrl = 'https://kassal.app/api/v1/products';

  // If needed, tweak or rename this method
  Future<List<dynamic>> searchProducts(String query) async {
    final url = Uri.parse('$_kKassalBaseUrl?search=$query');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $_kBearerToken',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final products = data['data'];
          if (products is List) {
            return products;
          }
        }
      } else {
        debugPrint('searchProducts got status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Kassal search error: $e');
    }
    return [];
  }
}