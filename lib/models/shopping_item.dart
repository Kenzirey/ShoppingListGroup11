import 'package:flutter/material.dart';

class ShoppingItem {
  final String name;
  final IconData? icon;
  bool isSelected;

  ShoppingItem({
    required this.name,
    this.icon,
    this.isSelected = false,
  });
}
