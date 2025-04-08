import 'package:flutter/material.dart';
import 'package:shopping_list_g11/utils/quantity_parser.dart';
import 'package:shopping_list_g11/utils/measurement_config.dart';


/// A shopping list item that shows the product to buy, and allows to add existing items
/// or add a new custom item to the list via an add button.
class ShoppingListItem extends StatelessWidget {
  final String item;
  final String quantityText;
  final String unitLabel;
  final ValueChanged<int> onQuantityChanged;
  final int? maxQuantity;
  final int step;

  final int actualDefaultQuantity = 1;

  const ShoppingListItem({
    super.key,
    required this.item,
    required this.quantityText,
    required this.unitLabel,
    required this.onQuantityChanged,
    this.maxQuantity,
    this.step = 1,
  });

int get _maxQuantity {
  final unitKey = unitLabel.trim().toLowerCase();
  return defaultUnitMaxValues[unitKey] ?? 100;
}


  int get _dropdownItemCount => (_maxQuantity / step).ceil();

  double _calculateDropdownMaxWidth(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.tertiary,
    );
    final displayText = quantityText;
    final tp = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout();
    const iconWidth = 24.0;
    return tp.width + iconWidth;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMaxWidth = _calculateDropdownMaxWidth(context);
    final itemCount = _dropdownItemCount;
    final int numericQuantity =
        QuantityParser.parseLeadingNumber(quantityText, defaultValue: actualDefaultQuantity);
    final String parsedUnit = QuantityParser.parseUnit(quantityText);
    final String displayUnit = parsedUnit.isNotEmpty ? parsedUnit : unitLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Left: name of grocery item.
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
          // Right: dropdown button for changign quantity of a grocery item.
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dropdownMaxWidth),
              child: DropdownButton<int>(
                value: numericQuantity,
                isDense: true,
                isExpanded: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                items: List.generate(itemCount, (index) {
                  final value = (index + 1) * step;
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      QuantityParser.formatQuantity(value, displayUnit),
                      style: TextStyle(
                        color: value == numericQuantity
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  );
                }),
                selectedItemBuilder: (BuildContext context) {
                  return List.generate(itemCount, (index) {
                    final value = (index + 1) * step;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        QuantityParser.formatQuantity(value, displayUnit),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    );
                  });
                },
                onChanged: (newQuantity) {
                  if (newQuantity != null) {
                    onQuantityChanged(newQuantity);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
