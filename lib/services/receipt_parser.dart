import 'dart:ui';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:math' as math;
import '../models/receipt_item.dart';

/// Represents a single line of text with its bounding box
class OcrLine {
  final Rect box;
  final String text;
  OcrLine({required this.box, required this.text});
}

/// Parses receipt data from OCR results
class ReceiptParser {

  /// Cleans item names by removing unwanted patterns (e.g. trailing percentages)
  String cleanName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\b\d+%\b', caseSensitive: false), '');
    return cleaned.trim();
  }

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

  double extractTotal(List<String> lines) {
    final RegExp pricePattern = RegExp(r'(\d+[.,]\d{2})');
    final RegExp intermediateTotalPattern = RegExp(r'sum\s+\d+\s+varer', caseSensitive: false);
    final List<String> keywords = ['total', 'totalt', 'sum', 'bank'];
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

  List<ReceiptItem> extractItemsByBoundingBox(RecognizedText recognizedText) {
    final List<OcrLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allLines.add(OcrLine(box: line.boundingBox, text: line.text));
      }
    }

    // Sort by vertical position
    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    // Group lines into rows based on vertical proximity
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

    final items = <ReceiptItem>[];
    bool stopParsing = false;

    for (final row in rows) {
      if (stopParsing) break;

      final combinedLower = row.map((l) => l.text.toLowerCase()).join(' ');
      // End parsing when encountering non-item rows
      if (RegExp(r'sum\s+\d+\s+varer', caseSensitive: false).hasMatch(combinedLower) ||
          combinedLower.contains('subtotal') ||
          combinedLower.contains('bank')) {
        stopParsing = true;
        break;
      }
      if (combinedLower.contains('pant')) {
        continue;
      }

      // Sort row elements left-to-right
      row.sort((a, b) => a.box.left.compareTo(b.box.left));

      if (row.length == 2) {
        final rawNameText = row[0].text.trim();
        final cleanedName = cleanName(rawNameText);
        final priceText = row[1].text.trim();
        final priceVal = _parsePrice(priceText);
        if (priceVal != null && cleanedName.isNotEmpty) {
          items.add(ReceiptItem(name: cleanedName, price: priceVal));
        }
      } else if (row.length == 1) {
        final singleText = row[0].text.trim();
        final priceVal = _parsePrice(singleText);
        if (priceVal != null) {
          final match = RegExp(r'(\d+[.,]\d{2})').firstMatch(singleText);
          if (match != null) {
            final namePart = singleText.substring(0, match.start).trim();
            final cleanedName = cleanName(namePart);
            if (cleanedName.isNotEmpty) {
              items.add(ReceiptItem(name: cleanedName, price: priceVal));
            }
          }
        }
      } else {
        final leftText = row.sublist(0, row.length - 1).map((l) => l.text).join(' ');
        final cleanedName = cleanName(leftText);
        final rightText = row.last.text.trim();
        final priceVal = _parsePrice(rightText);
        if (priceVal != null && cleanedName.isNotEmpty) {
          items.add(ReceiptItem(name: cleanedName, price: priceVal));
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
}