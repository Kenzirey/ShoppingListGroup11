import 'package:flutter/material.dart';

/// IngredientList with a global "Select all ingredients" row that includes an
/// "Add" button to its right. The [onAddIngredients] callback is called with a
/// list of selected ingredients when the button is pressed.
class IngredientList extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>>? onAddIngredients; // optional callback

  const IngredientList({
    Key? key,
    required this.ingredients,
    this.onAddIngredients,
  }) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.ingredients.map((_) => false).toList();
  }

  // Returns true if the ingredient is a group header.
  bool _isGroupHeader(String ingredient) {
    return ingredient.toLowerCase().startsWith('for the');
  }

  // Returns true if all selectable (non-header) ingredients are selected.
  bool get _allSelected {
    for (int i = 0; i < widget.ingredients.length; i++) {
      if (!_isGroupHeader(widget.ingredients[i]) && !_selected[i]) {
        return false;
      }
    }
    return true;
  }

  // Toggle selection of all non-header ingredients.
  void _toggleSelectAll(bool? value) {
    setState(() {
      for (int i = 0; i < widget.ingredients.length; i++) {
        if (!_isGroupHeader(widget.ingredients[i])) {
          _selected[i] = value ?? false;
        }
      }
    });
  }

  // Expose the selected ingredients.
  List<String> getSelectedIngredients() {
    List<String> selectedIngredients = [];
    for (int i = 0; i < widget.ingredients.length; i++) {
      if (!_isGroupHeader(widget.ingredients[i]) && _selected[i]) {
        selectedIngredients.add(widget.ingredients[i]);
      }
    }
    return selectedIngredients;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Global "Select all" row with an "Add" button on the right.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: "Add" button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: implement add logic
              },
              icon: Icon(
                Icons.add_shopping_cart,
                color: theme.colorScheme.tertiary,
              ),
              label: Text(
                'Add',
                style: TextStyle(color: theme.colorScheme.tertiary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // circular corners
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),

            // Right: text + checkbox
            Row(
              children: [
                Text(
                  'Select all ingredients',
                  style: TextStyle(
                    color: theme.colorScheme.tertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Default Checkbox with normal padding.
                Checkbox(
                  value: _allSelected,
                  onChanged: _toggleSelectAll,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // List of individual ingredient rows.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.ingredients.length, (index) {
            final ingredient = widget.ingredients[index];
            if (_isGroupHeader(ingredient)) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  ingredient.replaceAll(":", ""),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              );
            }
            final isSelected = _selected[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.secondary.withOpacity(0.3)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_1,
                    size: 8,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: TextStyle(color: theme.colorScheme.tertiary),
                    ),
                  ),
                  // Individual checkbox with InkWell feedback.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selected[index] = !isSelected;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.secondary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
