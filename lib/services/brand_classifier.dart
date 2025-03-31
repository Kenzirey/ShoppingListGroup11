import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for classifying brand names to generic product names.
class BrandClassifierService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 1) Fetch all brand snippets and their corresponding generic product names.
  Future<List<Map<String, dynamic>>> fetchSynonyms() async {
    try {
      final data = await _client
          .from('product_synonyms')
          .select('*');

      final List<dynamic> dataList = data as List<dynamic>;
      return dataList.map((e) => e as Map<String, dynamic>).toList();
    } catch (error) {
      debugPrint('Error fetching synonyms: $error');
      return [];
    }
  }

  /// 2) Classify an item name using the synonyms.
  Future<String?> autoClassify(
      String itemName,
      List<Map<String, dynamic>> synonyms,
      ) async {
    final lowerName = itemName.toLowerCase();

    for (final row in synonyms) {
      final snippet = (row['brand_snippet'] as String).toLowerCase();
      if (lowerName.contains(snippet)) {
        return row['generic_product_name'] as String;
      }
    }
    return null;
  }

  /// 3) Insert a new mapping into the "product_synonyms" table.
  Future<void> insertNewMapping(String snippet, String genericName) async {
    try {
      final inserted = await _client
          .from('product_synonyms')
          .insert({
        'brand_snippet': snippet.toLowerCase().trim(),
        'generic_product_name': genericName.toLowerCase().trim(),
      })
          .select();
      debugPrint('Inserted brand snippet mapping: $inserted');
    } catch (error) {
      debugPrint('Error inserting new mapping: $error');
    }
  }
}
