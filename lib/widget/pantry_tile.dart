import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';

/// One row in the pantry list.
/// Quantity and expiry are both selectable via CustomLazyDropdown; unit appended to item name.
class PantryItemTile extends ConsumerStatefulWidget {
  final String? category;
  final String itemName;
  final String unit; // new unit field
  final String quantity;
  final String expiration;
  final DateTime? expiryDate;
  final String itemId;
  final void Function(String id, DateTime newDate) onExpiryChanged;

  const PantryItemTile({
    super.key,
    required this.category,
    required this.itemName,
    required this.unit, // unit param
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
  String _quantityLabel = '';
  String _expiresLabel = '';
  static const double _dropdownWidth = 80;

  @override
  void initState() {
    super.initState();
    // initialize quantity dropdown label
    _quantityLabel = widget.quantity;
    // initialize expiry dropdown label
    _expiresLabel = widget.expiration;
  }

  void _handleQuantityChanged(String newLabel) {
    setState(() => _quantityLabel = newLabel);
  }

  void _handleExpiryChanged(String newValue) {
    final days = int.tryParse(newValue) ?? 0;
    final newDate = DateTime.now().add(Duration(days: days));
    widget.onExpiryChanged(widget.itemId, newDate);
    setState(() => _expiresLabel = newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.tertiary;
    final background = theme.colorScheme.primaryContainer;

    // build display name with optional  (not every unit will have it)
    final unitLower = widget.unit.toLowerCase().trim();
    final displayName =
        (unitLower == 'pcs' || unitLower == 'stk' || unitLower.isEmpty)
            ? widget.itemName
            : '${widget.itemName} ${widget.unit.trim()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // category icon
          PantryIcons(category: widget.category, size: 20, color: color),
          const SizedBox(width: 8),
          // item name + unit
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // quantity dropdown
          SizedBox(
            width: 60,
            child: CustomLazyDropdown(
              initialValue: _quantityLabel,
              onChanged: _handleQuantityChanged,
              dropdownWidth: 60,
            ),
          ),
          const SizedBox(width: 16),
          // expiry dropdown with time icon
          CustomLazyDropdown(
            initialValue: _expiresLabel,
            icon: Icons.access_time,
            onChanged: _handleExpiryChanged,
            dropdownWidth: _dropdownWidth,
          ),
        ],
      ),
    );
  }
}
