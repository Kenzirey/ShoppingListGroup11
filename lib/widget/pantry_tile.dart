import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

/// One row in the pantry list.
class PantryItemTile extends ConsumerStatefulWidget {
  final String? category;
  final String itemName;

  /// Initial label shown in the *quantity* dropdown.
  final String quantity;

  /// Initial label shown in the *expires* dropdown (ignored if
  final String expiration;
  final DateTime? expiryDate;
  final String itemId;
  final Function(String id, DateTime newDate) onExpiryChanged;

  const PantryItemTile({
    super.key,
    required this.category,
    required this.itemName,
    required this.quantity,
    required this.expiration,
    required this.expiryDate,
    required this.itemId,
    required this.onExpiryChanged,
  });

  @override
  ConsumerState<PantryItemTile> createState() => _PantryItemTileState();
}

class _PantryItemTileState extends ConsumerState<PantryItemTile> {
  late String _quantity;
  late String _expiresLabel;

  @override
  void initState() {
    super.initState();

    _quantity = widget.quantity;

    _expiresLabel = widget.expiryDate == null
        ? widget.expiration
        : widget.expiryDate!
        .difference(DateTime.now())
        .inDays
        .clamp(-7, 30)
        .toString();
  }

  /// Called every time the user chooses a new value in the *Expires* column.
  void _handleExpiryChanged(String newValue) {
    setState(() => _expiresLabel = newValue);

    final int? days = int.tryParse(newValue);
    if (days == null) return;

    final newDate = DateTime.now().add(Duration(days: days));
    widget.onExpiryChanged(widget.itemId, newDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final color      = theme.colorScheme.tertiary;
    final background = theme.colorScheme.primaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          PantryIcons(category: widget.category, size: 20, color: color),
          const SizedBox(width: 8),

          Expanded(
            child: Text(
              widget.itemName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),

          const SizedBox(width: 8),
          IntrinsicWidth(
            child: CustomLazyDropdown(
              initialValue: _quantity,
              onChanged: (v) => setState(() => _quantity = v),
            ),
          ),

          const SizedBox(width: 8),
          IntrinsicWidth(
            child: CustomLazyDropdown(
              initialValue: _expiresLabel,
              icon: Icons.access_time,
              onChanged: _handleExpiryChanged,
            ),
          ),
        ],
      ),
    );
  }
}
