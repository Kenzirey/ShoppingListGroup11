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
  - Quantity
  - Price
  - unit (e.g. ml, pcs, kg)
  - Allergy info (default to "none")
  - expirationDate (YYYY-MM-DD)
  
  Important:
1) Always return quantities as floating point numbers (e.g., 1.0, 473.0) not integers
2) Ignore any line that contains 'pant'
3) For product quantities and units:
   - If you see measurements like "473ml" or "1L" in product names:
     * Extract the unit (ml, L, etc.) for the 'unit' field
     * Extract the numeric value as a decimal for 'quantity' (e.g., 0.5 for "0,5L")
   - Otherwise default unit to "pcs" and quantity to 1.0
4) Determine expiration dates by estimating typical shelf life in YYYY-MM-DD format
5) If you see pricing like "2 x kr 25.90", set quantity to 2.0
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
      "unit": "ml",
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
            quantity: (item['quantity'] is num) ? item['quantity'].toDouble() : 1.0,            price: (item['price'] is num) ? item['price'].toDouble() : 0.0,
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
