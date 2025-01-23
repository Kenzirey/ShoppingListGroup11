import 'package:flutter/material.dart';

class ShoppingList extends StatelessWidget {
  const ShoppingList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy items for the shopping list
    final shoppingItems = [
      'Apples',
      'Bananas',
      'Carrots',
      'Eggs',
      'Milk',
      'Bread',
      'Cheese',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: ListView.builder(
        itemCount: shoppingItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(shoppingItems[index]),
            onTap: () {
              // Test navigation ? Should we try the id thing.
              // context.goNamed('details', params: {'id': '123'});
            },
          );
        },
      ),
    );
  }
}
