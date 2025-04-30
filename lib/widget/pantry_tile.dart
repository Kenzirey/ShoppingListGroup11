// lib/widget/pantry_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

/// Represents an item tile in the pantry list.
class PantryItemTile extends ConsumerStatefulWidget {
  final String? category;
  final String itemName;
  final String expiration;
  final String quantity;

  const PantryItemTile({
    super.key,
    required this.category,
    required this.itemName,
    required this.expiration,
    required this.quantity,
  });

  @override
  ConsumerState<PantryItemTile> createState() => _PantryItemTileState();
}

class _PantryItemTileState extends ConsumerState<PantryItemTile> {
  late String _expiration;
  late String _quantity;

  @override
  void initState() {
    super.initState();
    _expiration = widget.expiration;
    _quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.tertiary;
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
          PantryIcons(
            category: widget.category,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IntrinsicHeight(
              child: Row(
                children: [
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
                      initialValue: _expiration,
                      icon: Icons.access_time,
                      onChanged: (newValue) {
                        setState(() => _expiration = newValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 20, maxWidth: 60),
            alignment: Alignment.centerRight,
            child: IntrinsicWidth(
              child: CustomLazyDropdown(
                initialValue: _quantity,
                onChanged: (newValue) {
                  setState(() => _quantity = newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
