import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// IngredientList that allows to select individual or all ingredients,
/// to add them to shopping list.
class IngredientList extends ConsumerStatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>>?
      onAddIngredients; // need to make this actually do something
  // need to alter this when adding actual logic for dynamic storage.

  const IngredientList({
    super.key,
    required this.ingredients,
    this.onAddIngredients,
  });

  @override
  ConsumerState<IngredientList> createState() => _IngredientListState();
}

class _IngredientListState extends ConsumerState<IngredientList> {
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
  // non-header as some of the "ingredients" are actually the group name such as "salsa", or "tortilla"
  void _toggleSelectAll(bool value) {
    setState(() {
      for (int i = 0; i < widget.ingredients.length; i++) {
        if (!_isGroupHeader(widget.ingredients[i])) {
          _selected[i] = value;
        }
      }
    });
  }

  // Expose the selected ingredients.
  // probably need to alter this later
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
    final primaryColor = theme.colorScheme.primary;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final tertiary = theme.colorScheme.tertiary;
    final selectedBackground = primaryColor.withOpacity(0.3);
    final unselectedBackground = primaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Add items to shopping list?',
          style: TextStyle(
            fontSize: 16,
            color: tertiary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Left side, both left and right is the same as shopping suggestions for cohesion.
            Expanded(
              child: InkWell(
                onTap: () {
                  if (widget.onAddIngredients != null) {
                    widget.onAddIngredients!(getSelectedIngredients());
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryContainer,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        size: 20,
                        color: tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Shopping list',
                        style: TextStyle(
                          fontSize: 16,
                          color: tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right side
            Expanded(
              child: InkWell(
                onTap: () {
                  _toggleSelectAll(!_allSelected);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _allSelected
                        ? selectedBackground
                        : unselectedBackground,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'Select all',
                      style: TextStyle(
                        fontSize: 16,
                        color: _allSelected ? Colors.white : tertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Ingredient List here
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
                    color: tertiary,
                  ),
                ),
              );
            }
            final isSelected = _selected[index];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selected[index] = !_selected[index];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedBackground
                            : unselectedBackground,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.brightness_1,
                            size: 8,
                            color: tertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                color: tertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          isSelected
                              ? Icon(
                                  Icons.check_box_outlined,
                                  size: 20,
                                  color: primaryColor,
                                )
                              : Icon(
                                  Icons.check_box_outline_blank,
                                  size: 20,
                                  color: tertiary,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
