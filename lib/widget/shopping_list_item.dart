import 'package:flutter/material.dart';

/// A shopping list item that shows the product to buy, and allows to add existing items
/// or add a new custom item to the list via an add button.
class ShoppingListItem extends StatelessWidget {
  final String item;
  final int quantity;
  final String unitLabel;
  final ValueChanged<int> onQuantityChanged;
  /// We should also change this one.
  final int? maxQuantity;
  /// The step between consecutive dropdown values, we need to refactor this
  /// as the value should be more dynamic, 1, 2 where needed, 10, 20, 30+ etc
  final int step;

  // temporary
  final int actualDefaultQuantity = 1;

  const ShoppingListItem({
    super.key,
    required this.item,
    required this.quantity,
    required this.unitLabel,
    required this.onQuantityChanged,
    this.maxQuantity,
    this.step = 1,
  });

  /// Compute a default maximum: if not provided, for units like grams/ml allow higher values.
  /// This is a temporary solution until we have a better way to handle this, perhaps a more abstract solution.
  int get _maxQuantity {
    if (maxQuantity != null) return maxQuantity!;
    if (unitLabel.toLowerCase() == 'g' ||
        unitLabel.toLowerCase() == 'grams' ||
        unitLabel.toLowerCase() == 'ml' ||
        unitLabel.toLowerCase() == 'milliliters') {
      return 5000;
    }
    return 100;
  }

  /// Returns the number of dropdown items.
  int get _dropdownItemCount => (_maxQuantity / step).ceil();

  /// Returns a fixed max width for the dropdown based on the selected text.
  double _calculateDropdownMaxWidth(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.tertiary,
    );
    final displayText = _formatQuantity(quantity);
    final tp = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    const iconWidth = 24.0;
    return tp.width + iconWidth;
  }

  /// If the unit is grams and the value is high, convert to kilograms for display.
  /// temporary method. Need to add setup for liter, ml etc too. But in its own file not here
  String _formatQuantity(int value) {
    if (unitLabel.toLowerCase() == 'g' && value >= 1000) {
      final kgValue = (value / 1000).toStringAsFixed(1);
      return '$kgValue kg';
    }
    return '$value $unitLabel';
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMaxWidth = _calculateDropdownMaxWidth(context);
    final itemCount = _dropdownItemCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
                value: quantity,
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
                      _formatQuantity(value),
                      style: TextStyle(
                        color: value == quantity
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  );
                }),
                // Ensure the selected item’s text is left aligned.
                selectedItemBuilder: (BuildContext context) {
                  return List.generate(itemCount, (index) {
                    final value = (index + 1) * step;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatQuantity(value),
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
