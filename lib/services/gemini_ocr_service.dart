import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/receipt_data.dart';
import '../models/receipt_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

/// Service for performing OCR on receipts with Gemini AI
class GeminiOcrService {
  final _supa = Supabase.instance.client; 
  /// Extracts structured receipt data from an image file
  Future<ReceiptData?> extractReceiptData(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final b64    = base64Encode(bytes); 


      // System prompt to guide Gemini on data extraction
      const systemPrompt = """
You are an OCR system specialized in analyzing receipts. Extract the following in JSON format:
- Store name
- Date (YYYY-MM-DD)
- Total amount
- List of items with:
  - Product name
  - Quantity
  - Price
  - unit (e.g. "473ml", "500g", "1L", or "pcs")
  - Allergy info (default to "none")
  - expirationDate (YYYY-MM-DD)
  
  Important:
1) When you see a line containing 'pant', add its value to the price of the previous beverage item. Do not create a separate item for 'pant'.
2) If you see something like "473ml" or "1l" in the product name, use that as the unit. Otherwise default to "pcs".
3) Try to expiration date by guessing typical shelf life. Provide a date in YYYY-MM-DD format.
   - For energy drinks (Monster, Red Bull, etc.), use 12 months shelf life
   - For other beverages, use 6 months
   - For dairy, use 2 weeks
   - For bread, use 1 week
   - For other items, use 3 months
4) If you see for example 2 x kr 25.90, count it as 2 quantities of the item. You generally see it the line under the product name.
5) Decide the category based on the product name. Use "Fridge" for perishable items, "Freezer" for frozen items, and "Dry Storage" for dry goods. Energy drinks should be "Dry Storage".
6) Return ONLY valid JSON with no additional text or code formatting

Format as valid JSON:
{
  "storeName": "Store Name",
  "date": "YYYY-MM-DD",
  "total": 123.45,
  "items": [
    {
      "name": "Product Name",
      "quantity": 1,
      "price": 10.99,
      "unit": "473ml",
      "allergy": "none",
      "expirationDate": "2025-04-12",
      "category": "Fridge"
    }
  ]
}
Use reasonable defaults for missing information. Clean product names of promotional text.
""";

    // Supabase Edge Function call
    final fnRes = await _supa.functions.invoke(
      'gemini-ocr',
      body: {
        'prompt'     : systemPrompt,
        'imageBase64': b64,
      },
    );

    // Handle errors
    if (fnRes.status >= 400 || fnRes.data == null) {
      debugPrint('OCR edge failed: status ${fnRes.status}, body=${fnRes.data}');
      return null;
    }

    final payload = fnRes.data is String
        ? jsonDecode(fnRes.data as String)
        : fnRes.data as Map<String, dynamic>;

        final candidates = payload['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          debugPrint('No candidates in response: $payload');
          return null;
        }

        final first = candidates.first as Map<String, dynamic>;
        final content = first['content'] as Map<String, dynamic>?;
        if (content == null) {
          debugPrint('No content in first candidate: $first');
          return null;
        }

        final parts = content['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          debugPrint('No parts in content: $content');
          return null;
        }

        final responseText = (parts.first as Map<String, dynamic>)['text'] as String?;
        if (responseText == null || responseText.isEmpty) {
          debugPrint('First part has no text: $parts');
          return null;
        }




          return _parseResponseToReceiptData(responseText);
        } catch (e) {
          debugPrint('Error extracting receipt data: $e');
          return null;
        }
      }

  /// Parses Gemini response into structured ReceiptData
  ReceiptData? _parseResponseToReceiptData(String response) {
    try {
      // Extract JSON from the response
      final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```|(\{[\s\S]*\})');
      final match = jsonPattern.firstMatch(response);

      if (match == null) {
        debugPrint('No JSON found in response');
        return null;
      }

      final jsonStr = match.group(1) ?? match.group(2) ?? '';
      final data = jsonDecode(jsonStr.trim());

      // Parse items
      final items = <ReceiptItem>[];
      if (data['items'] is List) {
        for (var item in data['items']) {
          items.add(ReceiptItem(
            name: item['name'] ?? 'Unknown Item',
            quantity: (item['quantity'] is num) ? item['quantity'].toDouble() : 1.0,
            price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
            unit: item['unit'] ?? 'pcs',
            allergy: item['allergy'] ?? 'none',
            expirationDate: _parseDate(item['expirationDate']),
            category: '${item['category'] ?? 'Fridge'}',
          ));
        }
      }

      return ReceiptData(
        storeName: data['storeName'] ?? 'Unknown Store',
        date: data['date'] ?? DateTime.now().toIso8601String().split('T')[0],
        total: (data['total'] is num) ? data['total'].toDouble() : 0.0,
        items: items,
      );
    } catch (e) {
      debugPrint('Failed to parse receipt data: $e');
      return null;
    }
  }
}

// Helper function to parse date strings
DateTime? _parseDate(dynamic raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    return DateTime.tryParse(raw.trim());
  }
  return null;
}
