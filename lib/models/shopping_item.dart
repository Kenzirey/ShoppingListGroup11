
import 'package:flutter/material.dart';

class ShoppingItem {
  final String? id;
  final String userId;
  final String itemName;
  final String? quantity;
  final String? category;
  final IconData? icon;
  final DateTime? addedAt;

  ShoppingItem({
    this.id,
    required this.userId,
    required this.itemName,
    this.quantity,
    this.category,
    this.icon,
    this.addedAt
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as String?,
      category: map['category'] as String?,
      addedAt:map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'item_name': itemName,
      'quantity': quantity,
      'category': category,
      if (id != null && id!.isNotEmpty) 'id': id,
      'created_at': addedAt?.toIso8601String(),
    };
  }
}
