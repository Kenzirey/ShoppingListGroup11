import 'package:flutter/material.dart';

/// Reustable meal item widget, that represents serving size, dietary preference and on delete.
class MealItem extends StatelessWidget {
  final String mealName;
  final int servings;
  final bool? lactoseFree;
  final bool? vegan;
  final bool? vegetarian;
  final VoidCallback onDelete;
//TODO: set this up to be used for saved_recipes as well, to remove code duplication
  const MealItem({
    super.key,
    required this.mealName,
    required this.servings,
    required this.onDelete,
    this.lactoseFree,
    this.vegan,
    this.vegetarian,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    const iconSize = 20.0;

    // single icon vs multiple :)
    final IconData personIcon = (servings > 1) ? Icons.people : Icons.person;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(personIcon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(
            '$servings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    mealName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Only add spacing if at least one dietary icon is present, to keep things consistent
                if (lactoseFree == true || vegan == true || vegetarian == true)
                  const SizedBox(width: 8),

                if (lactoseFree == true) ...[
                  Icon(Icons.icecream, size: iconSize, color: color),
                  const SizedBox(width: 4),
                ],
                if (vegan == true) ...[
                  Icon(Icons.eco, size: iconSize, color: color),
                  const SizedBox(width: 4),
                ],
                if (vegetarian == true) ...[
                  Icon(Icons.spa, size: iconSize, color: color),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),

          // Delete icon at the far right
          const SizedBox(width: 10),
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.delete,
              size: iconSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
