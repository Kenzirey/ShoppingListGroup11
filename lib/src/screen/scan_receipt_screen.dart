import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

/// Data class to hold the parsed receipt data
class ReceiptData {
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final double total;

  /// Constructor
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

  /// Constructor
  ReceiptItem({
    required this.name,
    required this.price,
    this.weight,
  });

  @override
  String toString() {
    return 'ReceiptItem(name: $name, price: $price)';
  }
}

/// Screen widget for scanning a receipt
class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ScanReceiptScreenState createState() => ScanReceiptScreenState();
}

/// State class for the ScanReceiptScreen widget
class ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  ReceiptData? _receiptData;
  bool _isProcessing = false;
  File? _image;

  Future<void> _scanReceipt(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _image = File(image.path);
          _isProcessing = true;
        });

        // Preprocess the image
        File processedImage = await _preprocessImage(_image!);

        // Extract text
        final inputImage = InputImage.fromFile(processedImage);
        final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);
        print("OCR Result:\n${recognizedText.text}");

        // Parse receipt data
        final receiptData = await _parseReceiptText(recognizedText.text);
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

  /// Preprocess the image to improve OCR accuracy
  Future<File> _preprocessImage(File imageFile) async {
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) return imageFile;
    image = img.copyResize(image, width: 1000);
    image = img.gaussianBlur(image, radius: 1);

    /// Save the processed image
    final tempDir = await getTemporaryDirectory();
    final processedPath = '${tempDir.path}/processed_receipt.jpg';
    File processedImage = File(processedPath);
    await processedImage.writeAsBytes(img.encodeJpg(image));

    return processedImage;
  }

  /// Parse the OCR text to extract receipt data
  Future<ReceiptData> _parseReceiptText(String text) async {
    /// Split text into lines
    List<String> lines = text.split('\n');

    /// Extract store name
    String storeName = _extractStoreName(lines);

    /// Extract date
    String date = _extractDate(lines);

    /// Extract items
    List<ReceiptItem> items = _extractItems(lines);

    /// Extract total
    double total = _extractTotal(lines);

    /// Return the parsed receipt data
    return ReceiptData(
      storeName: storeName,
      date: date,
      items: items,
      total: total,
    );
  }

  /// Extract store name from the receipt text
  String _extractStoreName(List<String> lines) {
    for (int i = 0; i < math.min(5, lines.length); i++) {
      String line = lines[i].trim().toUpperCase();
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

  /// Extract date from the receipt text
  String _extractDate(List<String> lines) {
    // Expanded date patterns
    final datePatterns = [
      RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b'),
      RegExp(r'\b\d{4}[./-]\d{2}[./-]\d{2}\b'),
      RegExp(
          r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4}\b'),
    ];

    for (String line in lines) {
      for (final pattern in datePatterns) {
        Match? match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(0) ?? '';
        }
      }
    }
    return '';
  }

  /// Extract items from the receipt text
  List<ReceiptItem> _extractItems(List<String> lines) {
    List<ReceiptItem> items = [];
    RegExp priceRegex = RegExp(r'(\d+,\d{2})\s*$');

    // Keywords to skip
    bool isItemSection = false;
    List<String> skipKeywords = [
      'salgskvittering',
      'org.nr',
      'foretaksregisteret',
      'tlf:',
      'kvitt:',
      'kasse:',
      'opernr:',
      'serienr',
      '---------------',
    ];

    for (String originalLine in lines) {
      String line = originalLine.trim();

      if (line.isEmpty ||
          skipKeywords.any((keyword) =>
              line.toLowerCase().contains(keyword.toLowerCase()))) {
        continue;
      }

      final lowerLine = line.toLowerCase();
      if (lowerLine.contains('subtotal') ||
          lowerLine.contains('sum') ||
          lowerLine.contains('bank')) {
        isItemSection = false;
        continue;
      }

      if (isItemSection) {
        // Extract price
        final priceMatch = priceRegex.firstMatch(line);
        if (priceMatch != null) {
          String rawPrice = priceMatch.group(1) ?? '0,00';
          double price = double.parse(rawPrice.replaceAll(',', '.'));

          // Extract name by removing the price portion
          String name = line.substring(0, priceMatch.start).trim();

          if (name.isNotEmpty) {
            items.add(ReceiptItem(
              name: name,
              price: price,
            ));
          }
        }
      }
    }

    return items;
  }

  /// Extract total from the receipt text
  double _extractTotal(List<String> lines) {
    for (String line in lines) {
      // Use case-insensitive checks in real usage
      if (line.contains('TOTAL') || line.contains('SUM')) {
        RegExp totalRegex = RegExp(r'\d+,\d{2}');
        Match? match = totalRegex.firstMatch(line);
        if (match != null) {
          return double.parse(match.group(0)!.replaceAll(',', '.'));
        }
      }
    }
    return 0.0;
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
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
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
            ...receipt.items.map(
                  (item) => Padding(
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
              ),
            ),
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

  /// Dispose the text recognizer
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}
