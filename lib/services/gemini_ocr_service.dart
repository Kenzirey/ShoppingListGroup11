import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/receipt_data.dart';
import '../models/receipt_item.dart';

/// Service for performing OCR on receipts with Gemini AI
class GeminiOcrService {
  /// Extracts structured receipt data from an image file
  Future<ReceiptData?> extractReceiptData(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // System prompt to guide Gemini on data extraction
      const systemPrompt = """
You are an OCR system specialized in analyzing receipts. Extract the following in JSON format:
- Store name
- Date (YYYY-MM-DD)
- Total amount
- List of items with:
  - Product name
  - Quantity (default to 1)
  - Price
  - unit (e.g. "473ml", "500g", "1L", or "pcs")
  - Allergy info (default to "none")
  - expirationDate (YYYY-MM-DD)
  
  Important:
1) Ignore any line that contains 'pant'.
2) If you see something like "473ml" or "1l" in the product name, use that as the unit. Otherwise default to "pcs".
3) Try to expiration date by guessing typical shelf life. Provide a date in YYYY-MM-DD format.
4) If you see for example 2 x kr 25.90, count it as 2 quantities of the item. You generally see it the line under the product name. 
5) Output only JSON, with no additional text.

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
      "allergy": "none"
      "expirationDate": "2025-04-12"
    }
  ]
}
Use reasonable defaults for missing information. Clean product names of promotional text.
""";

      final result = await Gemini.instance.textAndImage(
        text: systemPrompt,
        images: [bytes],
      );

      final responseText = result?.output ?? '';
      if (responseText.isEmpty) {
        debugPrint('Empty response from Gemini');
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
            quantity: item['quantity'] ?? 1,
            price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
            unit: item['unit'] ?? 'pcs',
            allergy: item['allergy'] ?? 'none',
            expirationDate: _parseDate(item['expirationDate']),
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
