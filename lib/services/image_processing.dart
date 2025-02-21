import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopping_list_g11/services/receipt_parser.dart';
import 'package:shopping_list_g11/services/supabase_ocr_service.dart';
import '../models/receipt_data.dart';
import 'kassal_service.dart';
import 'package:image/image.dart' as img;

/// Handles image preprocessing
class ImageProcessingService {
  Future<File> preprocessImage(File imageFile) async {
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
}

/// Handles OCR text recognition
class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ScanReceiptScreenState createState() => ScanReceiptScreenState();
}

class ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);
  final ImageProcessingService _imageService = ImageProcessingService();
  final ReceiptParser _receiptParser = ReceiptParser();
  final KassalService _kassalService = KassalService();
  final SupabaseService _supabaseService = SupabaseService();

  ReceiptData? _receiptData;
  bool _isProcessing = false;
  File? _image;

  Future<void> _scanReceipt(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(source: source);
      if (pickedImage == null) return;

      setState(() {
        _image = File(pickedImage.path);
        _isProcessing = true;
      });

      // Preprocess image and run OCR
      final processedImage = await _imageService.preprocessImage(_image!);
      final inputImage = InputImage.fromFile(processedImage);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Parse receipt data
      final rawLines = recognizedText.text.split('\n');
      final storeName = _receiptParser.extractStoreName(rawLines);
      final date = _receiptParser.extractDate(rawLines);
      final total = _receiptParser.extractTotal(rawLines);
      final items = _receiptParser.extractItemsByBoundingBox(recognizedText);
      final receiptData =
      ReceiptData(storeName: storeName, date: date, items: items, total: total);

      // Update items with Kassal allergen info
      final uniqueNames = receiptData.items.map((e) => e.name).toSet();
      final searchResultsFutures = uniqueNames.map((name) async {
        final result = await _kassalService.searchProducts(name);
        return MapEntry(name, result);
      }).toList();
      final searchResults = await Future.wait(searchResultsFutures);
      final searchMap = Map<String, List<dynamic>>.fromEntries(searchResults);

      for (final item in receiptData.items) {
        final results = searchMap[item.name] ?? [];
        if (results.isNotEmpty && results.first is Map<String, dynamic>) {
          final bestMatch = results.first as Map<String, dynamic>;
          final allergenList = bestMatch['allergens'];
          if (allergenList is List) {
            final relevantAllergens = allergenList
                .where((a) =>
            a is Map &&
                a['contains'] != null &&
                a['contains'].toString().toUpperCase() == 'YES')
                .map((a) => a['display_name'])
                .toList();
            final allergenString = relevantAllergens.join(', ');
            item.allergy = allergenString.isEmpty ? null : allergenString;
          }
        }
      }

      // Save receipt and items to Supabase
      await _supabaseService.saveReceipt(receiptData);

      setState(() {
        _receiptData = receiptData;
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Scanner')),
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
              final displayName = item.allergy == null
                  ? item.name
                  : '${item.name} (Allergy: ${item.allergy})';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
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

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}