import 'package:flutter/material.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

class PantryItemTile extends StatefulWidget {
  final IconData icon;
  final String itemName;
  final String expiration;
  final String quantity;

  const PantryItemTile({
    super.key,
    required this.icon,
    required this.itemName,
    required this.expiration,
    required this.quantity,
  });

  @override
  _PantryItemTileState createState() => _PantryItemTileState();
}

class _PantryItemTileState extends State<PantryItemTile> {
  String? _expiration;
  String? _quantity;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.itemName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: CustomLazyDropdown(
                      initialValue: _expiration ?? '0',
                      icon: Icons.access_time,
                      onChanged: (newValue) {
                        setState(() {
                          _expiration = newValue;
                          debugPrint('Expiration changed to: $newValue');
                        });
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
                initialValue: _quantity ?? '1',
                onChanged: (newValue) {
                  setState(() {
                    _quantity = newValue;
                    debugPrint('Quantity changed to: $newValue');
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
