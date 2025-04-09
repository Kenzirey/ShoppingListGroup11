import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math' as math;
import '../models/receipt_item.dart';

/// Represents a single line of text with its bounding box
class OcrLine {
  final Rect box;
  final String text;
  OcrLine({required this.box, required this.text});
}

/// Parses recognized text from a receipt image
class ReceiptParser {

  /// Extracts receipt data from the recognized text
  String cleanName(String raw) {
    // Remove percentage patterns like "15%"
    raw = raw.replaceAll(RegExp(r'\s*\d+\s*%', caseSensitive: false), '');
    // Remove extra spaces
    raw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return raw;
  }

  /// Extracts quantity information from product text
  Map<String, dynamic> extractQuantity(String text) {
    // Default values
    int quantity = 1;
    String modifiedText = text;

    // Case 1: Pattern like "2 stk" or "3 x"
    final standardPattern = RegExp(r'\b(\d+[.,]?\d*)\s*(?:stk|x|pk|pakke|box|pose)\b', caseSensitive: false);
    var match = standardPattern.firstMatch(text);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1.0;
      quantity = parsed.toInt();
      // Remove the matched pattern from text
      modifiedText = text.replaceFirst(match.group(0)!, '').trim();
      return {'quantity': quantity, 'text': modifiedText};
    }

    // Case 2: Pattern like "2x" without space
    final compactPattern = RegExp(r'\b(\d+[.,]?\d*)x\b', caseSensitive: false);
    match = compactPattern.firstMatch(text);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1.0;
      quantity = parsed.toInt();
      // Remove the matched pattern from text
      modifiedText = text.replaceFirst(match.group(0)!, '').trim();
      return {'quantity': quantity, 'text': modifiedText};
    }

    // Case 3: Pattern like "2 for 30"
    final forPattern = RegExp(r'\b(\d+[.,]?\d*)\s*for\b', caseSensitive: false);
    match = forPattern.firstMatch(text);
    if (match != null) {
      final parsed = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1.0;
      quantity = parsed.toInt();
      // Remove the matched pattern from text
      modifiedText = text.replaceFirst(match.group(0)!, '').trim();
      return {'quantity': quantity, 'text': modifiedText};
    }

    // Case 4: Number at start of text that might indicate quantity
    final startNumberPattern = RegExp(r'^\s*(\d+[.,]?\d*)\s+');
    match = startNumberPattern.firstMatch(text);
    if (match != null) {
      // Only use this if it looks like a standalone number, not part of the product name
      final potentialQuantity = double.tryParse(match.group(1)!.replaceAll(',', '.'));
      if (potentialQuantity != null && potentialQuantity < 20) { // Reasonable quantity limit
        quantity = potentialQuantity.toInt();
        // Remove the matched pattern from text
        modifiedText = text.replaceFirst(match.group(0)!, '').trim();
        return {'quantity': quantity, 'text': modifiedText};
      }
    }

    return {'quantity': quantity, 'text': modifiedText};
  }

  /// Extracts the store name from the recognized text.
  String extractStoreName(List<String> lines) {
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

  /// Extracts the date from the recognized text
  String extractDate(List<String> lines) {
    final datePatterns = [
      RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b'),
      RegExp(r'\b\d{4}[./-]\d{2}[./-]\d{2}\b'),
      RegExp(r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s*\d{1,2},?\s*\d{4}\b'),
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

  /// Extracts the total amount from the recognized text
  double extractTotal(List<String> lines) {
    final RegExp pricePattern = RegExp(r'(\d+[.,]\d{2})');
    final RegExp intermediateTotalPattern = RegExp(r'sum\s+\d+\s+varer', caseSensitive: false);
    final List<String> keywords = ['BANK'];
    double total = 0.0;

    for (int i = lines.length - 1; i >= 0; i--) {
      final String lineLower = lines[i].toLowerCase();
      if (intermediateTotalPattern.hasMatch(lineLower)) continue;
      if (keywords.any((k) => lineLower.contains(k))) {
        final match = pricePattern.firstMatch(lines[i]);
        if (match != null) {
          total = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
          return total;
        } else {
          // Fallback: look at the next few lines
          final candidatePrices = <double>[];
          for (int j = i + 1; j < math.min(i + 4, lines.length); j++) {
            final nextMatch = pricePattern.firstMatch(lines[j]);
            if (nextMatch != null) {
              final p = double.tryParse(nextMatch.group(1)!.replaceAll(',', '.')) ?? 0.0;
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

  /// Extracts unit information (e.g., 400g, 0,5L) from a product name
  String extractUnit(String text) {
    // Match common measurement patterns
    final RegExp unitPattern = RegExp(
        r'(\d+[,.]?\d*)\s*(g|kg|ml|l|cl|dl|stk|pk|box|pakke)',
        caseSensitive: false
    );

    final match = unitPattern.firstMatch(text);
    if (match != null) {
      return match.group(0)!.trim();
    }
    return '';
  }

  /// Separates the product name from its unit
  Map<String, String> separateNameAndUnit(String text) {
    final unit = extractUnit(text);
    final name = unit.isNotEmpty
        ? text.replaceFirst(unit, '').trim()
        : text;

    return {
      'name': name,
      'unit': unit
    };
  }

  List<ReceiptItem> extractItemsByBoundingBox(RecognizedText recognizedText) {
    final List<OcrLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allLines.add(OcrLine(box: line.boundingBox, text: line.text));
      }
    }

    // Sort by boundingBox top
    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    // Group lines that belong on the same "row"
    const double rowThreshold = 20.0;
    final List<List<OcrLine>> rows = [];
    for (final line in allLines) {
      bool placed = false;
      for (final row in rows) {
        final avgTop = row.map((l) => l.box.top).reduce((a, b) => a + b) / row.length;
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

    final RegExp quantityPricePattern = RegExp(r'^\d+\s*x\s*(?:kr\s*)?\d+[.,]\d{2}$', caseSensitive: false);
    final items = <ReceiptItem>[];
    bool stopParsing = false;
    for (int i = 0; i < rows.length; i++) {
      if (stopParsing) break;
      final row = rows[i];

      final combinedLower = row.map((l) => l.text.toLowerCase()).join(' ');
      // If we see lines that indicate a total, we assume the item section is done.
      if (RegExp(r'sum\s+\d+\s+varer', caseSensitive: false).hasMatch(combinedLower) ||
          combinedLower.contains('subtotal') ||
          combinedLower.contains('bank')) {
        stopParsing = true;
        break;
      }
      // Also skip lines that mention 'pant'
      if (combinedLower.contains('pant')) {
        debugPrint('Skipping pant line: $combinedLower');
        continue;
      }
      if (quantityPricePattern.hasMatch(combinedLower)) {
        debugPrint('Skipping quantity/price-only line: $combinedLower');
        continue;
      }

      // Sort row elements by boundingBox left, so [name..., possible price]
      row.sort((a, b) => a.box.left.compareTo(b.box.left));

      String rawNameText = '';
      String priceText = '';

      if (row.length == 2) {
        rawNameText = row[0].text.trim();
        priceText = row[1].text.trim();
      } else if (row.length == 1) {
        rawNameText = row[0].text.trim();
        final match = RegExp(r'(\d+[.,]\d{2})').firstMatch(rawNameText);
        if (match != null) {
          priceText = rawNameText.substring(match.start).trim();
          rawNameText = rawNameText.substring(0, match.start).trim();
        }
      } else {
        rawNameText = row.sublist(0, row.length - 1).map((l) => l.text).join(' ');
        priceText = row.last.text.trim();
      }

      // Extract quantity and clean name in one step
      final quantityInfo = extractQuantity(rawNameText);
      final quantity = quantityInfo['quantity'] as int;
      final nameWithoutQuantity = quantityInfo['text'] as String;

      final cleanedName = cleanName(nameWithoutQuantity);
      final priceVal = _parsePrice(priceText);

      // Extract unit information
      final unitInfo = separateNameAndUnit(cleanedName);
      final productName = unitInfo['name'] ?? cleanedName;
      final unit = unitInfo['unit'] ?? '';

      if (priceVal != null && cleanedName.isNotEmpty) {
        items.add(ReceiptItem(
            name: productName,
            price: priceVal,
            quantity: quantity,
            unit: unit
        ));
      }
    }
    return items;
  }

  double? _parsePrice(String text) {
    final regex = RegExp(r'(\d+[.,]\d{2})');
    final match = regex.firstMatch(text);
    if (match != null) {
      final raw = match.group(1)!;
      return double.tryParse(raw.replaceAll(',', '.'));
    }
    return null;
  }
}