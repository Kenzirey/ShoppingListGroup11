import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_list_g11/models/receipt_data.dart';
import 'package:shopping_list_g11/providers/purchase_history_provider.dart';
import 'package:shopping_list_g11/screen/bottom_bar/receipts/view_scanned_receipt_screen.dart';
import 'package:shopping_list_g11/services/image_processing.dart';
import 'package:shopping_list_g11/services/kassal_service.dart';
import 'package:shopping_list_g11/services/supabase_ocr_service.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../../services/gemini_ocr_service.dart';

/// Screen for scanning a receipt and extracting data
class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final ImageProcessingService _imageService = ImageProcessingService();
  final KassalService _kassalService = KassalService();
  final SupabaseService _supabaseService = SupabaseService();
  final GeminiOcrService _geminiService = GeminiOcrService();

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

      final processedImage = await _imageService.preprocessImage(_image!);
      final receiptData =
          await _geminiService.extractReceiptData(processedImage);

      // Check if receiptData is null before proceeding
      if (receiptData == null) {
        setState(() {
          _isProcessing = false;
        });
        if (!mounted) return; // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to extract receipt data')),
        );
        return;
      }

      // Allergen lookup
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

      // Reload purchase history after saving receipt
      ref.read(purchaseHistoryProvider.notifier).loadPurchaseHistory();

      setState(() {
        _receiptData = receiptData;
        _isProcessing = false;
      });

      // After scanned, navigate to the receipt display screen.
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptDisplayScreen(receiptData: receiptData),
        ),
      );
    } catch (e) {
      debugPrint('Error scanning receipt: $e');
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return; // Check if widget is still in the tree
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar.buildSnackBar(
            title: 'Error',
            message: 'Error scanning receipt: $e',
            innerPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Receipt',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            Expanded(
              child: _isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 8,
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scan Receipt Button
                          Semantics(
                            label:
                                "Scan Receipt: Scan a new receipt using the camera", 
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed: () => _scanReceipt(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 32),
                              label: const Text(
                                'Scan Receipt',
                                style: TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'or',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Scan Barcode Button
                          Semantics(
                            label:
                                "Scan Existing: Scan an existing image from the gallery",
                            button: true,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _scanReceipt(ImageSource.gallery),
                              icon: PantryIcons(
                                category: 'gallery',
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                                semanticLabel: "Gallery icon",
                              ),
                              label: const Text(
                                'Scan Existing',
                                style: TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
