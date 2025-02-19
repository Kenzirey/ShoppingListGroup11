import 'package:flutter/material.dart';

/// The ingredient list for the recipe.
/// Each ingredient has a styled container with a bullet point.
class IngredientList extends StatelessWidget {
  final List<String> ingredients;

  const IngredientList({required this.ingredients, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ingredient) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.brightness_1, size: 8),
              const SizedBox(width: 8),
              Expanded(
                child: Text(ingredient,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}