import 'dart:developer' as developer;
import 'shelf_life.dart';

/// Helps normalize product names to match shelf life categories
class ProductNameNormalizer {
  static final Map<String, List<String>> categoryKeywords = {
    'milk': ['melk', 'milk', 'lettmelk', 'skummet', 'helmelk'],
    'cheese': ['cheese', 'ost', 'cheddar', 'gouda', 'brie'],
    'yogurt': ['yogurt', 'yoghurt', 'yoghurtdrink'],
    'bread': ['bread', 'brød', 'loaf', 'toast'],
    'apples': ['apple', 'eple', 'granny smith', 'pink lady'],
    'bananas': ['banan', 'banana'],
    'chicken': ['chicken', 'kylling', 'grilled', 'filet', 'bryst'],
    'beef': ['beef', 'steak', 'biff', 'kjøttdeig', 'storfe', 'entrecote', 'ground beef', 'deig'],
    'pork': ['pork', 'svin', 'fläsk', 'ribbe', 'svinekjøtt', 'bacon'],
    'pasta': ['pasta', 'spaghetti', 'macaroni', 'linguini'],
    'rice': ['rice', 'ris', 'basmati', 'jasmin'],
    'eggs': ['eggs', 'egg', 'frittgående'],
  };

  /// Attempts to normalize a product name to match shelf life categories
  static String normalizeProductName(String productName) {
    if (productName.isEmpty) {
      developer.log('Empty product name provided');
      return productName;
    }

    // Debug
    developer.log('RAW INPUT: "$productName"');

    final lowerName = productName.toLowerCase().trim();
    developer.log('Normalized lowercase: "$lowerName"');

    if (lowerName == "kjøttdeig storfe") {
      developer.log('DIRECT MATCH for kjøttdeig storfe');
      return 'beef';
    }

    if (lowerName.contains('kj') && lowerName.contains('ttdeig')) {
      developer.log('Detected kjøttdeig through partial match');
      return 'beef';
    }

    if (lowerName.contains('storfe')) {
      developer.log('Detected storfe');
      return 'beef';
    }

    developer.log('Character by character: ${lowerName.split('').join(',')}');

    // Word matching
    final words = lowerName.split(RegExp(r'\s+'));
    developer.log('Split words: $words');

    // Check for exact matches first
    for (final word in words) {
      developer.log('Checking word: "$word"');
      for (final entry in categoryKeywords.entries) {
        for (final keyword in entry.value) {
          if (word == keyword) {
            developer.log('Exact word match: "$word" to "${entry.key}"');
            return entry.key;
          }
        }
      }
    }

    // Partial matching
    for (final entry in categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerName.contains(keyword)) {
          developer.log('Partial match: "$keyword" in "$lowerName" to "${entry.key}"');
          return entry.key;
        }
      }
    }

    // Try shelf life keys
    for (final key in ShelfLife.shelfLifeByItem.keys) {
      if (lowerName.contains(key)) {
        developer.log('Shelf life key match: "$key"');
        return key;
      }
    }

    developer.log('NO MATCH FOUND for: "$productName"');
    return productName;
  }
}