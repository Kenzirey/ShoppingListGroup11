import 'package:flutter/material.dart';
import '../controllers/purchase_statistics_controller.dart';
import '../models/purchase_statistics.dart';

/// This service fetches and processes purchase statistics data from Supabase.
class PurchaseStatisticsService {
  final PurchaseStatisticsController statisticsController;

  PurchaseStatisticsService({required this.statisticsController});

  Future<MonthlySpending> getMonthlySpending(int year, int month) async {
    // Get raw purchase data from Supabase through the controller
    final purchases = await statisticsController.getPurchasesByMonth(year, month);
    print('Processing ${purchases.length} purchases for monthly spending');
    final Map<String, double> categoryAmounts = {};

    for (final purchase in purchases) {
      final category = purchase['category'] ?? 'Other';
      final price = double.tryParse('${purchase['price']}') ?? 0.0;
      categoryAmounts[category] = (categoryAmounts[category] ?? 0) + price;
    }

    // Create category objects with appropriate colors
    final List<PurchaseCategory> categories = [];
    final categoryColors = {
      'Fridge': Colors.blue,
      'Dry Storage': Colors.red,
      'Freezer': Colors.green,
    };

    categoryAmounts.forEach((name, amount) {
      categories.add(PurchaseCategory(
        name: name,
        amount: amount,
        color: categoryColors[name] ?? Colors.blueGrey,
      ));
    });

    // Handle the case where no purchases were made
    if (categories.isEmpty) {
      categories.add(PurchaseCategory(
        name: 'No Data',
        amount: 0,
        color: Colors.grey,
      ));
    }

    final totalAmount = categories.fold(0.0, (sum, cat) => sum + cat.amount);

    return MonthlySpending(
      date: DateTime(year, month),
      totalAmount: totalAmount,
      categories: categories,
    );
  }

  Future<YearlySpending> getYearlySpending(int year) async {
    final purchases = await statisticsController.getPurchasesByYear(year);
    print('Processing ${purchases.length} purchases for yearly spending');

    // Initialize monthly amounts to zero
    final List<double> monthlyAmounts = List.filled(12, 0.0);

    for (final purchase in purchases) {
      final date = DateTime.parse(purchase['purchased_at']);
      final purchaseMonth = date.month - 1;
      final price = double.tryParse('${purchase['price']}') ?? 0.0;

      monthlyAmounts[purchaseMonth] += price;
    }

    return YearlySpending(
      year: year,
      monthlyAmounts: monthlyAmounts,
      totalAmount: monthlyAmounts.fold(0.0, (sum, amount) => sum + amount),
    );
  }
}