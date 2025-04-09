import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';

class ShoppingListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final int numericQuantity = QuantityParser.parseLeadingNumber(quantityText, defaultValue: 1);
    final String parsedUnit = QuantityParser.parseUnit(quantityText);
    final String displayUnit = parsedUnit.isNotEmpty ? parsedUnit : unitLabel;
    final String initialText = numericQuantity.toString();

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
              item,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(
            width: 60,
            child: TextField(
              controller: TextEditingController(text: initialText),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                final parsedValue = int.tryParse(value);
                if (parsedValue != null && parsedValue > 0) {
                  onQuantityChanged(parsedValue);
                }
              },
            ),
          ),

          if (displayUnit.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                displayUnit,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
