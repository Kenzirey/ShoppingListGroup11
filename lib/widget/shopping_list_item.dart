import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

/// A ShoppingListItem shows the item name and, when count‑based (unitLabel is empty),
/// displays a dropdown that lazy‑loads numeric options.
class ShoppingListItem extends StatefulWidget {
  final String item;
  final String quantityText;
  // For count‑based items, unitLabel is empty; for measured items, it contains the unit (e.g. "kg").
  final String unitLabel;
  final ValueChanged<int> onQuantityChanged;

  const ShoppingListItem({
    super.key,
    required this.item,
    required this.quantityText,
    required this.unitLabel,
    required this.onQuantityChanged,
  });

  @override
  State<ShoppingListItem> createState() => _ShoppingListItemState();
}

class _ShoppingListItemState extends State<ShoppingListItem> {
  TextEditingController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numericQuantity =
        QuantityParser.parseLeadingNumber(widget.quantityText, defaultValue: 1);
    final initialValue = numericQuantity.toString();
    final useDropdown = widget.unitLabel.isEmpty;

    if (!useDropdown && _controller == null) {
      _controller = TextEditingController(text: initialValue);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.item,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
IntrinsicWidth(
  child: useDropdown
      ? CustomLazyDropdown(
          initialValue: initialValue,
          onChanged: (String value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              widget.onQuantityChanged(parsed);
            }
          },
        )
      : TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            isDense: true,
            border: const UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            suffixText: widget.unitLabel,
            suffixStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              widget.onQuantityChanged(parsed);
            }
          },
        ),
),


        ],
      ),
    );
  }
}
