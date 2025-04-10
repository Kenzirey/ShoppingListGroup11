import 'package:flutter/material.dart';

class PantryItemTile extends StatefulWidget {
  final IconData icon;
  final String itemName;
  final String expiration; // from database; expected to be numeric (as string)
  final String quantity;   // from database; expected to be numeric (as string)

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
  late List<String> _expirationOptions;
  late List<String> _quantityOptions;

  @override
  void initState() {
    super.initState();
    _expiration = widget.expiration;
    _quantity = widget.quantity;
    
    // Generate numeric increment options for expiration.
    final int? expValue = int.tryParse(widget.expiration);
    if (expValue != null) {
      _expirationOptions = List.generate(10, (i) => (expValue + i).toString());
    } else {
      _expirationOptions = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
      if (!_expirationOptions.contains(widget.expiration)) {
        _expirationOptions.insert(0, widget.expiration);
      }
    }
    
    // Generate numeric increment options for quantity.
    final int? quantValue = int.tryParse(widget.quantity);
    if (quantValue != null) {
      _quantityOptions = List.generate(10, (i) => (quantValue + i).toString());
    } else {
      _quantityOptions = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
      if (!_quantityOptions.contains(widget.quantity)) {
        _quantityOptions.insert(0, widget.quantity);
      }
    }
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
        // Center everything vertically.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left icon.
          Icon(
            widget.icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8), // space between icon and left group.
          // Left group: wraps product name, vertical divider, time icon and expiration dropdown.
          Expanded(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product name takes available space and can wrap.
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
                  // Vertical divider replacing the "|" text.
                  VerticalDivider(
                    color: color,
                    thickness: 1,
                  ),
                  const SizedBox(width: 8),
                  // Time icon.
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  // Expiration dropdown (default underline preserved).
                  DropdownButton<String>(
                    value: _expiration,
                    onChanged: (newValue) {
                      setState(() {
                        _expiration = newValue;
                      });
                    },
                    items: _expirationOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(fontSize: 14, color: color),
                            ),
                          ),
                        )
                        .toList(),
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Quantity dropdown on the right wrapped in a Container with fixed width for alignment.
          Container(
            constraints: const BoxConstraints(minWidth: 80, maxWidth: 80),
            alignment: Alignment.centerRight,
            child: DropdownButton<String>(
              value: _quantity,
              onChanged: (newValue) {
                setState(() {
                  _quantity = newValue;
                });
              },
              items: _quantityOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 14, color: color),
                      ),
                    ),
                  )
                  .toList(),
              style: TextStyle(fontSize: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}