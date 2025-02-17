import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A small helper class to hold each OCR line plus its bounding box.
class OcrLine {
  final Rect box;
  final String text;
  OcrLine({required this.box, required this.text});
}

/// Data class to hold the parsed receipt data
class ReceiptData {
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final double total;

  ReceiptData({
    required this.storeName,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  String toString() {
    return 'ReceiptData(storeName: $storeName, date: $date, total: $total, items: $items)';
  }
}

/// Data class to hold the parsed receipt item
class ReceiptItem {
  final String name;
  final double price;
  final String? weight;

  ReceiptItem({
    required this.name,
    required this.price,
    this.weight,
    // this.category,
  });

  @override
  String toString() => 'ReceiptItem(name: $name, price: $price)';
}

/// Screen widget for scanning a receipt
class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ScanReceiptScreenState createState() => ScanReceiptScreenState();
}

class ScanReceiptScreenState extends State<ScanReceiptScreen> {
  // Kassal constants:
  static const String _kBearerToken = 'jen8hGeedph78wDfqR37345l5lcIxCNjBHjjzjL4';
  static const String _kKassalBaseUrl = 'https://kassal.app/api/v1/products';

  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  ReceiptData? _receiptData;
  bool _isProcessing = false;
  File? _image;

  // Helper: search Kassal for a product name, returning a list of matches
  Future<List<dynamic>> _searchKassalProducts(String query) async {
    final url = Uri.parse('$_kKassalBaseUrl?search=$query&sort=price_desc');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $_kBearerToken',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        }
      } else {
        debugPrint(
            'Kassal API error: ${response.statusCode} => ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in Kassal search: $e');
    }
    return [];
  }

  Future<void> _scanReceipt(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _image = File(image.path);
          _isProcessing = true;
        });

        // Preprocess the image
        final processedImage = await _preprocessImage(_image!);

        // Extract text with ML Kit
        final inputImage = InputImage.fromFile(processedImage);
        final recognizedText = await _textRecognizer.processImage(inputImage);

        // Debug: print lines
        final debugLines = recognizedText.text.split('\n');
        debugPrint("===== OCR Lines =====");
        for (int i = 0; i < debugLines.length; i++) {
          debugPrint('Line $i: "${debugLines[i]}"');
        }
        debugPrint("===== End of OCR Lines =====");

        // Parse receipt data from recognized text
        final receiptData = await _parseReceiptData(recognizedText);

        // Optionally, for each item, call Kassal to get extra info
        for (final item in receiptData.items) {
          final results = await _searchKassalProducts(item.name);
          if (results.isNotEmpty) {
            final bestMatch = results.first;
          }
        }

        // Insert into Supabase
        await _saveToSupabase(receiptData);

        // Update UI
        setState(() {
          _receiptData = receiptData;
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Preprocess the image (resize & blur) to improve OCR accuracy
  Future<File> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return imageFile;

    decoded = img.copyResize(decoded, width: 1000);
    decoded = img.gaussianBlur(decoded, radius: 1);

    final tempDir = await getTemporaryDirectory();
    final processedPath = '${tempDir.path}/processed_receipt.jpg';
    final processedImage = File(processedPath);
    await processedImage.writeAsBytes(img.encodeJpg(decoded));
    return processedImage;
  }

  /// Main function to parse recognized text into ReceiptData
  Future<ReceiptData> _parseReceiptData(RecognizedText recognizedText) async {
    final rawLines = recognizedText.text.split('\n');
    final storeName = _extractStoreName(rawLines);
    final date = _extractDate(rawLines);
    final total = _extractTotal(rawLines);
    final items = _extractItemsByBoundingBox(recognizedText);

    return ReceiptData(
      storeName: storeName,
      date: date,
      items: items,
      total: total,
    );
  }

  /// Extract store name from first ~5 lines
  String _extractStoreName(List<String> lines) {
    for (int i = 0; i < math.min(5, lines.length); i++) {
      final line = lines[i].trim().toUpperCase();
      if (line.contains('MENY') ||
          line.contains('REMA 1000') ||
          line.contains('KIWI') ||
          line.contains('COOP') ||
          line.contains('SPAR')) {
        return lines[i].trim();
      }
    }
    return 'Unknown Store';
  }

  /// Extract date from any line that matches typical date patterns
  String _extractDate(List<String> lines) {
    final datePatterns = [
      RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b'),
      RegExp(r'\b\d{4}[./-]\d{2}[./-]\d{2}\b'),
      RegExp(
          r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s*\d{1,2},?\s*\d{4}\b'),
    ];

    for (String line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(0) ?? '';
        }
      }
    }
    return '';
  }

  /// Extract the total from the last occurrence of relevant total-related words
  double _extractTotal(List<String> lines) {
    final RegExp pricePattern = RegExp(r'(\d+[.,]\d{2})');
    final RegExp intermediateTotalPattern =
    RegExp(r'sum\s+\d+\s+varer', caseSensitive: false);
    final List<String> keywords = ['total', 'totalt', 'sum', 'bank'];
    double total = 0.0;

    // Start from the end and work backwards
    for (int i = lines.length - 1; i >= 0; i--) {
      final String lineLower = lines[i].toLowerCase();

      // Skip intermediate totals
      if (intermediateTotalPattern.hasMatch(lineLower)) {
        continue;
      }

      // Check if this line contains any of our keywords
      if (keywords.any((k) => lineLower.contains(k))) {
        final match = pricePattern.firstMatch(lines[i]);
        if (match != null) {
          total =
              double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
          return total;
        } else {
          // Try lines following it (some receipts print total below)
          final candidatePrices = <double>[];
          for (int j = i + 1; j < math.min(i + 4, lines.length); j++) {
            final nextMatch = pricePattern.firstMatch(lines[j]);
            if (nextMatch != null) {
              final p = double.tryParse(
                nextMatch.group(1)!.replaceAll(',', '.'),
              ) ??
                  0.0;
              candidatePrices.add(p);
            }
          }
          if (candidatePrices.isNotEmpty) {
            return candidatePrices.last;
          }
        }
      }
    }
    return total;
  }

  /// 2 Column bounding-box approach to extract item names and corresponding prices
  List<ReceiptItem> _extractItemsByBoundingBox(RecognizedText recognizedText) {
    final List<OcrLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allLines.add(OcrLine(box: line.boundingBox, text: line.text));
      }
    }

    // Sort by top
    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    // Group lines into rows by vertical proximity
    const double rowThreshold = 20.0;
    final List<List<OcrLine>> rows = [];

    for (var line in allLines) {
      bool placed = false;
      for (var row in rows) {
        final avgTop =
            row.map((l) => l.box.top).reduce((a, b) => a + b) / row.length;
        if ((line.box.top - avgTop).abs() < rowThreshold) {
          row.add(line);
          placed = true;
          break;
        }
      }
      if (!placed) {
        rows.add([line]);
      }
    }

    final items = <ReceiptItem>[];
    bool stopParsing = false;

    for (final row in rows) {
      if (stopParsing) break;
      final combinedLower =
      row.map((l) => l.text.toLowerCase()).join(' ');

      // Skip certain lines that might indicate totals
      if (RegExp(r'sum\s+\d+\s+varer', caseSensitive: false)
          .hasMatch(combinedLower) ||
          combinedLower.contains('subtotal') ||
          combinedLower.contains('bank')) {
        stopParsing = true;
        break;
      }

      // Sort row elements by left
      row.sort((a, b) => a.box.left.compareTo(b.box.left));

      if (row.length == 2) {
        final nameText = row[0].text.trim();
        final priceText = row[1].text.trim();
        final priceVal = _parsePrice(priceText);
        if (priceVal != null && nameText.isNotEmpty) {
          items.add(ReceiptItem(name: nameText, price: priceVal));
        }
      } else if (row.length == 1) {
        final singleText = row[0].text.trim();
        final priceVal = _parsePrice(singleText);
        if (priceVal != null) {
          final match = RegExp(r'(\d+[.,]\d{2})').firstMatch(singleText);
          if (match != null) {
            final namePart = singleText.substring(0, match.start).trim();
            if (namePart.isNotEmpty) {
              items.add(ReceiptItem(name: namePart, price: priceVal));
            }
          }
        }
      } else {
        // If more than 2 lines in a row, combine all left ones as name,
        // last one as price
        final leftText = row
            .sublist(0, row.length - 1)
            .map((l) => l.text)
            .join(' ');
        final rightText = row.last.text.trim();
        final priceVal = _parsePrice(rightText);
        if (priceVal != null && leftText.isNotEmpty) {
          items.add(ReceiptItem(name: leftText, price: priceVal));
        }
      }
    }
    return items;
  }

  double? _parsePrice(String text) {
    final regex = RegExp(r'(\d+[.,]\d{2})');
    final match = regex.firstMatch(text);
    if (match != null) {
      final raw = match.group(1)!;
      return double.parse(raw.replaceAll(',', '.'));
    }
    return null;
  }

  /// Insert the receipt + items into Supabase
  Future<void> _saveToSupabase(ReceiptData receiptData) async {
    final supabase = Supabase.instance.client;

    // 1) Insert the receipt row and get it back
    Map<String, dynamic> insertedReceipt;
    try {
      insertedReceipt = await supabase
          .from('receipts')
          .insert({
        'user_id': 'someUserId',
        'store_name': receiptData.storeName,
        'total_amount': receiptData.total,
        'uploaded_at': DateTime.now().toIso8601String(),
      }).select().single();

      debugPrint('Inserted receipt: $insertedReceipt');

    } catch (e) {
      debugPrint('Error inserting receipt: $e');
      return;
    }

    final receiptId = insertedReceipt['id'];
    debugPrint('Newly created receipt_id = $receiptId');

    // 2) Insert each item. We'll do each insert in a try/catch too:
    for (final item in receiptData.items) {
      try {
        final insertedItem = await supabase
            .from('receipt_items')
            .insert({
          'receipt_id': receiptId,
          'name': item.name,
          'category': 'Uncategorized',
          'quantity': 1,
          'price': item.price,
          'added_at': DateTime.now().toIso8601String(),
        })
            .select()
            .single();

        debugPrint('Inserted item => $insertedItem');

      } catch (e) {
        debugPrint('Error inserting item "${item.name}": $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _scanReceipt(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
            ),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_receiptData != null)
              _buildReceiptDisplay(_receiptData!),
          ],
        ),
      ),
    );
  }

  /// Build the receipt display widget
  Widget _buildReceiptDisplay(ReceiptData receipt) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.storeName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Text(
              'Date: ${receipt.date}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...receipt.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${item.price.toStringAsFixed(2)} kr',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(thickness: 1, color: Colors.black26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${receipt.total.toStringAsFixed(2)} kr',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Clean up
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}
