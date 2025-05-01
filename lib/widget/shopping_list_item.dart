import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';
import 'package:shopping_list_g11/widget/styles/buttons/lazy_dropdown.dart';

/// A ShoppingListItem shows the item name and, when count-based (unitLabel is empty),
/// displays a dropdown that lazy-loads numeric options.
class ShoppingListItem extends StatefulWidget {
  final String item;
  final String quantityText;
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
    final theme            = Theme.of(context);
    final bg               = theme.colorScheme.primaryContainer;
    final tertiary         = theme.colorScheme.tertiary;
    final numericQuantity  = QuantityParser.parseLeadingNumber(
      widget.quantityText, defaultValue: 1);
    final initialValue     = numericQuantity.toString();
    final useDropdown      = widget.unitLabel.isEmpty;

    if (!useDropdown && _controller == null) {
      _controller = TextEditingController(text: initialValue);
    }

    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // item name
          Expanded(
            child: Text(
              widget.item,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (useDropdown)
            // ───── dropdown branch ─────
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // hide the built-in underline and center the trigger
                  DropdownButtonHideUnderline(
                    child: Center(
                      child: 
CustomLazyDropdown(
  initialValue: initialValue,
  onChanged: (value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      widget.onQuantityChanged(parsed);
    }
  },
),

                    ),
                  ),
                  // draw a 1px underline exactly under the trigger
                  Container(
                    height: 1,
                    color: tertiary,
                  ),
                ],
              ),
            )
          else
            // ───── text-field branch (unchanged) ─────
            IntrinsicWidth(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  isDense: true,
                  border: const UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tertiary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.colorScheme.primary),
                  ),
                  suffixText: widget.unitLabel,
                  suffixStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: tertiary,
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
