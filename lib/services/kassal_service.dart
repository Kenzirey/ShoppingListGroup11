import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/// Handles communication with Kassal API for product search
class KassalService {
  static const String _kBearerToken = 'jen8hGeedph78wDfqR37345l5lcIxCNjBHjjzjL4';
  static const String _kKassalBaseUrl = 'https://kassal.app/api/v1/products';

  Future<List<dynamic>> searchProducts(String query) async {
    final url = Uri.parse('$_kKassalBaseUrl?search=$query&sort=price_desc');
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
      }
    } catch (e) {
      debugPrint('Kassal search error: $e');
    }
    return [];
  }
}