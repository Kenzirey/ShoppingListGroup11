import 'package:shopping_list_g11/models/receipt_item.dart';

/// Represents a single receipt with store name, date, items, and total amount
class ReceiptData {
  final String storeName;
  final String date;
  final List<ReceiptItem> items;
  final double total;

  ReceiptData({
    required this.storeName,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  String toString() {
    return 'ReceiptData(storeName: $storeName, date: $date, total: $total, items: $items)';
  }
}