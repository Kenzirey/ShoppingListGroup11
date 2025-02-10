import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

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
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  ReceiptData? _receiptData;
  bool _isProcessing = false;
  File? _image;

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
        final recognizedText =
        await _textRecognizer.processImage(inputImage);

        // Print lines for debugging
        List<String> debugLines = recognizedText.text.split('\n');
        print("===== OCR Lines =====");
        for (int i = 0; i < debugLines.length; i++) {
          print('Line $i: "${debugLines[i]}"');
        }
        print("===== End of OCR Lines =====");

        // Parse receipt data
        final receiptData = await _parseReceiptData(recognizedText);
        print("Parsed Receipt Data: $receiptData");

        setState(() {
          _receiptData = receiptData;
          _isProcessing = false;
        });
      }
    } catch (e) {
      print('Error scanning receipt: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Preprocess the image (resize & blur) to improve OCR accuracy
  Future<File> _preprocessImage(File imageFile) async {
    img.Image? decoded = img.decodeImage(await imageFile.readAsBytes());
    if (decoded == null) return imageFile;

    decoded = img.copyResize(decoded, width: 1000);
    decoded = img.gaussianBlur(decoded, radius: 1);

    final tempDir = await getTemporaryDirectory();
    final processedPath = '${tempDir.path}/processed_receipt.jpg';
    File processedImage = File(processedPath);
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

  /// Extract store name from first ~5 lines (line-based approach)
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
    // Pattern to skip intermediate totals (like "sum 2 varer")
    final RegExp intermediateTotalPattern =
    RegExp(r'sum\s+\d+\s+varer', caseSensitive: false);
    // Keywords that indicate a total line.
    final List<String> keywords = ['total', 'totalt', 'sum', 'bank'];
    double total = 0.0;

    // Start from the end and work backwards
    for (int i = lines.length - 1; i >= 0; i--) {
      final String lineLower = lines[i].toLowerCase();

      // Skip intermediate totals (like "sum 2 varer")
      if (intermediateTotalPattern.hasMatch(lineLower)) {
        continue;
      }

      // Check if this line contains any of our keywords.
      if (keywords.any((keyword) => lineLower.contains(keyword))) {
        // Try to extract a price from this line.
        final match = pricePattern.firstMatch(lines[i]);
        if (match != null) {
          total = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
          return total;
        } else {
          List<double> candidatePrices = [];
          for (int j = i + 1; j < math.min(i + 4, lines.length); j++) {
            final nextMatch = pricePattern.firstMatch(lines[j]);
            if (nextMatch != null) {
              double price =
                  double.tryParse(nextMatch.group(1)!.replaceAll(',', '.')) ?? 0.0;
              candidatePrices.add(price);
            }
          }
          if (candidatePrices.isNotEmpty) {
            total = candidatePrices.last;
            return total;
          }
        }
      }
    }
    return total;
  }

  /// 2 Column bounding-box approach to extract item names and get corresponding prices
  List<ReceiptItem> _extractItemsByBoundingBox(RecognizedText recognizedText) {
    final List<OcrLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allLines.add(OcrLine(box: line.boundingBox, text: line.text));
      }
    }

    // Sort by top position
    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    // Group lines into rows based on vertical proximity
    const double rowThreshold = 20.0;
    final List<List<OcrLine>> rows = [];
    for (var line in allLines) {
      bool placed = false;
      for (var row in rows) {
        double avgTop = row.map((l) => l.box.top).reduce((a, b) => a + b) / row.length;
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

    List<ReceiptItem> items = [];
    bool stopParsing = false;

    for (var row in rows) {
      if (stopParsing) break;
      final combinedLower = row.map((l) => l.text.toLowerCase()).join(' ');

      // Updated filtering: Skip rows that appear to be intermediate totals
      if (RegExp(r'sum\s+\d+\s+varer', caseSensitive: false).hasMatch(combinedLower) ||
          combinedLower.contains('subtotal') ||
          combinedLower.contains('bank')) {
        stopParsing = true;
        break;
      }

      // Sort row items by their left position
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
        final leftText = row.sublist(0, row.length - 1).map((l) => l.text).join(' ');
        final rightText = row.last.text.trim();
        final priceVal = _parsePrice(rightText);
        if (priceVal != null && leftText.isNotEmpty) {
          items.add(ReceiptItem(name: leftText, price: priceVal));
        }
      }
    }
    return items;
  }

  /// Parse a price from a string
  double? _parsePrice(String text) {
    final regex = RegExp(r'(\d+[.,]\d{2})');
    final match = regex.firstMatch(text);
    if (match != null) {
      final raw = match.group(1)!;
      return double.parse(raw.replaceAll(',', '.'));
    }
    return null;
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
            // List of items
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
