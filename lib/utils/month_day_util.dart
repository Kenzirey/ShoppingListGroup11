import 'package:intl/intl.dart';
import 'package:shopping_list_g11/models/product.dart';

/// Utility class for month and day related product filtering and grouping.
class MonthAndDayUtility {
  MonthAndDayUtility._(); // private constructor to prevent instantiation

  /// Filters [prods] to only those matching [selectedMonth] ("MMMM yyyy").
  static List<Product> getProductsForSelectedMonth(
      List<Product> prods, String selectedMonth) {
    return prods.where((product) {
      final productMonth = DateFormat('MMMM yyyy').format(product.purchaseDate);
      return productMonth == selectedMonth;
    }).toList();
  }

  /// Groups [prods] by day ("dd MMM, yyyy").
  static Map<String, List<Product>> groupProductsByDay(
      List<Product> prods) {
    final Map<String, List<Product>> grouped = {};
    final dayFormat = DateFormat('dd MMM, yyyy');
    for (final product in prods) {
      final dayKey = dayFormat.format(product.purchaseDate);
      grouped.putIfAbsent(dayKey, () => []).add(product);
    }
    return grouped;
  }

  /// Returns the list of months up to the current month in the format "MMMM yyyy".
  static List<String> getMonthsUpToCurrent() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonthIndex = now.month;
    final List<String> months = [];

    for (int i = 1; i <= currentMonthIndex; i++) {
      final date = DateTime(currentYear, i);
      months.add(DateFormat('MMMM yyyy').format(date));
    }
    return months;
  }
}
