import 'package:flutter/material.dart';

/// Represents a purchase category with a name, amount, and color.
class PurchaseCategory {
  final String name;
  final double amount;
  final Color color;

  PurchaseCategory({
    required this.name,
    required this.amount,
    required this.color,
  });
}

class MonthlySpending {
  final DateTime date;
  final double totalAmount;
  final List<PurchaseCategory> categories;

  MonthlySpending({
    required this.date,
    required this.totalAmount,
    required this.categories,
  });
}

class YearlySpending {
  final int year;
  final List<double> monthlyAmounts;
  final double totalAmount;

  YearlySpending({
    required this.year,
    required this.monthlyAmounts,
    required this.totalAmount,
  });
}