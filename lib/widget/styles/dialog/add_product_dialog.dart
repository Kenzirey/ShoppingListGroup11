import 'package:flutter/material.dart';

/// A dialog for adding a new product to the shopping list.
/// Allows user to add their own grocery name, quantity of it and unit of measurement.
class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final List<String> unitOptions = ["", "liter", "ml", "gram", "kg"];
  String selectedUnit = "";

  @override
  void dispose() {
    productController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Add grocery item',
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Enter the name of the product',
            child: TextField(
              controller: productController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                hintText: 'e.g. Apples',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Tooltip(
            message: 'Enter the amount you want to add',
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                hintText: 'e.g. 50',
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Tooltip(
            message: 'Select the unit of measurement',
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Unit',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                    width: 2,
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedUnit,
                  isDense: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 16,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  items: unitOptions.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(
                        unit.isEmpty ? 'No unit' : unit,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedUnit = newValue ?? "";
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          onPressed: () {
            final name = productController.text.trim();
            final amount = int.tryParse(amountController.text.trim()) ?? 1;
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a product name.'),
                ),
              );
              return;
            }
            Navigator.of(context).pop({
              'name': name,
              'amount': amount,
              'unit': selectedUnit,
            });
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
