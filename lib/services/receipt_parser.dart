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

    // Keywords to identify total amounts
    final List<String> totalKeywords = [
      'total', 'sum', 'å betale', 'bank', 'beløp'
    ];

    // Pattern to match explicit total amounts
    final RegExp totalPattern = RegExp(
        r'(total|sum|beløp|betalt)\s*(?:kr\.?|nok)?\s*(\d+[.,]\d{2})',
        caseSensitive: false
    );

    // Check for explicit total patterns first
    for (int i = lines.length - 1; i >= 0; i--) {
      final match = totalPattern.firstMatch(lines[i].toLowerCase());
      if (match != null) {
        return double.tryParse(match.group(2)!.replaceAll(',', '.')) ?? 0.0;
      }
    }

    // If no explicit total found, check for keywords in the last few lines
    for (int i = lines.length - 1; i >= math.max(0, lines.length - 15); i--) {
      final String lineLower = lines[i].toLowerCase();

      if (RegExp(r'sum\s+\d+\s+varer', caseSensitive: false).hasMatch(lineLower) &&
          !RegExp(r'total|å betale|betalt', caseSensitive: false).hasMatch(lineLower)) {
        continue;
      }

      // Check if the line contains any of the keywords
      if (totalKeywords.any((k) => lineLower.contains(k.toLowerCase()))) {
        final match = pricePattern.firstMatch(lines[i]);
        if (match != null) {
          return double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
        }

        for (int offset = 1; offset <= 2; offset++) {

          if (i + offset < lines.length) {
            final nextMatch = pricePattern.firstMatch(lines[i + offset]);
            if (nextMatch != null) {
              return double.tryParse(nextMatch.group(1)!.replaceAll(',', '.')) ?? 0.0;
            }
          }

          if (i - offset >= 0) {
            final prevMatch = pricePattern.firstMatch(lines[i - offset]);
            if (prevMatch != null) {
              return double.tryParse(prevMatch.group(1)!.replaceAll(',', '.')) ?? 0.0;
            }
          }
        }
      }
    }

    // Last resort: find the largest amount in the last few lines
    final candidates = <double>[];
    for (int i = lines.length - 1; i >= math.max(0, lines.length - 10); i--) {
      final matches = pricePattern.allMatches(lines[i]);
      for (final match in matches) {
        final value = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0.0;
        candidates.add(value);
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort();
      return candidates.last;
    }

    return 0.0;
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
    final List<OcrLine> allLines = _extractOcrLines(recognizedText);
    final List<List<OcrLine>> rows = _groupLinesByRow(allLines);
    return _processRowsIntoItems(rows);
  }

  /// Extract individual OCR lines from recognized text blocks
  List<OcrLine> _extractOcrLines(RecognizedText recognizedText) {
    final List<OcrLine> lines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        lines.add(OcrLine(box: line.boundingBox, text: line.text));
      }
    }
    lines.sort((a, b) => a.box.top.compareTo(b.box.top));
    return lines;
  }

  /// Group lines that belong on the same visual row
  List<List<OcrLine>> _groupLinesByRow(List<OcrLine> allLines) {
    const double rowThreshold = 18.0;
    final List<List<OcrLine>> rows = [];

    for (final line in allLines) {
      bool placed = false;

      for (final row in rows) {
        // Check if the line is close to the median top of the row
        final rowTops = row.map((l) => l.box.top).toList()..sort();
        final medianTop = rowTops[rowTops.length ~/ 2];

        if ((line.box.top - medianTop).abs() < rowThreshold) {
          bool overlaps = false;
          for (final rowLine in row) {
            if (math.max(line.box.left, rowLine.box.left) <
                math.min(line.box.right, rowLine.box.right) - 20) {
              overlaps = true;
              break;
            }
          }

          if (!overlaps) {
            row.add(line);
            placed = true;
            break;
          }
        }
      }

      if (!placed) {
        rows.add([line]);
      }
    }
    return rows;
  }

  /// Process grouped rows into receipt items
  List<ReceiptItem> _processRowsIntoItems(List<List<OcrLine>> rows) {
    final RegExp quantityPricePattern = RegExp(r'^\d+\s*x\s*(?:kr\s*)?\d+[.,]\d{2}$',
        caseSensitive: false);
    final items = <ReceiptItem>[];
    bool stopParsing = false;

    for (int i = 0; i < rows.length && !stopParsing; i++) {
      final row = rows[i];
      final combinedLower = row.map((l) => l.text.toLowerCase()).join(' ');

      if (_isFooterSection(combinedLower) ||
          _isSpecialEntry(combinedLower) ||
          quantityPricePattern.hasMatch(combinedLower)) {
        if (_isFooterSection(combinedLower)) {
          stopParsing = true;
        }
        continue;
      }

      final itemDetails = _extractItemDetailsFromRow(row);
      if (itemDetails != null) {
        items.add(itemDetails);
      }
    }

    return items;
  }

  /// Check if line indicates the receipt footer section
  bool _isFooterSection(String text) {
    return RegExp(r'sum\s+\d+\s+varer', caseSensitive: false).hasMatch(text) ||
        text.contains('subtotal') ||
        text.contains('bank') ||
        text.contains('total') ||
        text.contains('å betale');
  }

  /// Check if line is a special entry (like pant, discount)
  bool _isSpecialEntry(String text) {
    return text.contains('pant') ||
        text.contains('rabatt') ||
        text.contains('konto') ||
        text.contains('betaling');
  }

  /// Extract item details from a row of text lines
  ReceiptItem? _extractItemDetailsFromRow(List<OcrLine> row) {
    row.sort((a, b) => a.box.left.compareTo(b.box.left));

    String rawNameText = '';
    String priceText = '';

    // Extract price and name from the row
    if (row.length >= 2) {
      priceText = row.last.text.trim();
      rawNameText = row.sublist(0, row.length - 1).map((l) => l.text).join(' ');
    } else if (row.length == 1) {
      final match = RegExp(r'(\d+[.,]\d{2})').firstMatch(row[0].text);
      if (match != null) {
        priceText = row[0].text.substring(match.start).trim();
        rawNameText = row[0].text.substring(0, match.start).trim();
      } else {
        rawNameText = row[0].text.trim();
      }
    }

    // Skip if the raw text contains suspicious patterns suggesting merged lines
    if (_containsMergedLinePatterns(rawNameText)) {
      return null;
    }

    // Process name and extract quantity information
    final quantityInfo = extractQuantity(rawNameText);
    final quantity = quantityInfo['quantity'] as int;
    final nameWithoutQuantity = quantityInfo['text'] as String;
    final cleanedName = cleanName(nameWithoutQuantity);

    // Parse price from the text
    final priceVal = _parsePrice(priceText);
    final unitInfo = separateNameAndUnit(cleanedName);
    final unit = unitInfo['unit'] ?? '';

    // Create ReceiptItem if valid name and price are found
    if (priceVal != null && cleanedName.isNotEmpty) {
      return ReceiptItem(
        name: cleanedName,
        price: priceVal,
        quantity: quantity,
        unit: unit,
      );
    }

    return null;
  }

  /// Check for patterns suggesting incorrectly merged lines
  bool _containsMergedLinePatterns(String text) {
    return RegExp(r'\d+[.,]\d+kg\s*x\s*kr').hasMatch(text) ||
        RegExp(r'kr\s+\d+[.,]\d+\s+[A-ZÆØÅ]').hasMatch(text);
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