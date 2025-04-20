import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// IngredientList that allows to select individual or all ingredients,
/// to add them to shopping list.
class IngredientList extends ConsumerStatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>>? onAddIngredients;

  const IngredientList({
    super.key,
    required this.ingredients,
    this.onAddIngredients,
  });

  @override
  ConsumerState<IngredientList> createState() => _IngredientListState();
}

class _IngredientListState extends ConsumerState<IngredientList> {
  // Pantry items to group under Others, may need to expand this.
  static const _hiddenItems = {'salt', 'water'};

  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.ingredients.length, false);
  }

  @override
  void didUpdateWidget(covariant IngredientList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ingredients.length != oldWidget.ingredients.length) {
      _selected = List<bool>.filled(widget.ingredients.length, false);
    }
  }

bool _isGroupHeader(String ingredient) {
  final trimmed = ingredient.trim();
  // either “For the X:” or anything ending in “:”
  return trimmed.toLowerCase().startsWith('for the') 
      || trimmed.endsWith(':');
}


  bool _isHidden(String ingredient) {
    final low = ingredient.toLowerCase();
    return _hiddenItems.any((h) => low.contains(h));
  }

  bool get _allSelected {
    for (int i = 0; i < widget.ingredients.length; i++) {
      final ing = widget.ingredients[i];
      if (!_isGroupHeader(ing) && !_isHidden(ing) && !_selected[i]) return false;
    }
    return true;
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      for (int i = 0; i < widget.ingredients.length; i++) {
        final ing = widget.ingredients[i];
        if (!_isGroupHeader(ing) && !_isHidden(ing)) {
          _selected[i] = value;
        }
      }
    });
  }

  List<String> getSelectedIngredients() {
    final selected = <String>[];
    for (int i = 0; i < widget.ingredients.length; i++) {
      final ing = widget.ingredients[i];
      if (!_isGroupHeader(ing) && !_isHidden(ing) && _selected[i]) {
        selected.add(ing);
      }
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final primaryContainer = theme.colorScheme.primaryContainer;
    final tertiary = theme.colorScheme.tertiary;
    final selectedBackground = primaryColor.withOpacity(0.3);
    final unselectedBackground = primaryContainer;

    final otherItems = widget.ingredients
        .where((ing) => !_isGroupHeader(ing) && _isHidden(ing))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Add items to shopping list?',
          style: TextStyle(fontSize: 16, color: tertiary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (widget.onAddIngredients != null) {
                    widget.onAddIngredients!(getSelectedIngredients());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryContainer,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 20, color: tertiary),
                      const SizedBox(width: 8),
                      Text('Shopping list', style: TextStyle(fontSize: 16, color: tertiary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _toggleSelectAll(!_allSelected),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _allSelected ? selectedBackground : unselectedBackground,
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'Select all',
                      style: TextStyle(fontSize: 16, color: _allSelected ? Colors.white : tertiary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Purchaseable ingredients, so not salt or water.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            if (_isGroupHeader(ingredient)) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  ingredient.replaceAll(':', ''),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tertiary),
                ),
              );
            } else if (_isHidden(ingredient)) {
              return const SizedBox.shrink();
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
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? selectedBackground : unselectedBackground,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.brightness_1, size: 8, color: tertiary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ingredient, style: TextStyle(color: tertiary))),
                          const SizedBox(width: 4),
                          isSelected
                              ? Icon(Icons.check_box_outlined, size: 20, color: primaryColor)
                              : Icon(Icons.check_box_outline_blank, size: 20, color: tertiary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Others section, with items that are hidden in the main list.
        // Such as salt or water, since this is usually in the pantry / from the tap.
        if (otherItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Others', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tertiary)),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: otherItems.map((ing) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: unselectedBackground,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.brightness_1, size: 8, color: tertiary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ing, style: TextStyle(color: tertiary))),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}