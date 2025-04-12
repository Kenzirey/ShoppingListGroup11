import 'package:shopping_list_g11/services/product_normalizer.dart';
import 'shelf_life.dart';

/// Service for predicting expiration dates based on product names
class ExpirationService {
  /// Predicts expiration date for a product
  Future<DateTime> predictExpirationDate(String productName) async {
    // Get shelf life days
    final days = getShelfLifeDays(productName);

    // Calculate expiration date from today
    return DateTime.now().add(Duration(days: days));
  }

  /// Gets shelf life in days for a product
  int getShelfLifeDays(String productName) {
    // Normalize the product name
    final normalizedName = ProductNameNormalizer.normalizeProductName(productName);

    // Get shelf life from normalized name
    return ShelfLife.getShelfLife(normalizedName);
  }
}