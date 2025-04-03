import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/pantry_tile.dart';

/// Screen for showing which food items the user has in stock,
/// from fridge to dry goods, canned food etc.
class PantryListScreen extends ConsumerStatefulWidget {
  const PantryListScreen({super.key});

  @override
  ConsumerState<PantryListScreen> createState() => _PantryListScreenState();
}

class _PantryListScreenState extends ConsumerState<PantryListScreen> {
  final List<String> fridgeItems = ['Milk', 'Eggs', 'Cheese', 'Chicken'];
  final List<String> dryGoodsItems = ['Bread', 'Cereal', 'Pasta'];
  final List<String> cannedFoodItems = ['Canned Beans', 'Tomato Sauce', 'Corn'];

  final String expiration = '2 days'; // dummy text until we set it dynamic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Current Stock',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),

            // Fridge Section
            _buildSectionHeader('Fridge'),
            const SizedBox(height: 12),
            ...fridgeItems.map((item) => PantryItemTile(
                  icon: Icons.kitchen,
                  itemName: item,
                  expiration: expiration,
                  quantity: '2 units',
                )),

            const SizedBox(height: 24),

            // Dry Goods Section
            _buildSectionHeader('Dry Goods'),
            const SizedBox(height: 12),
            ...dryGoodsItems.map((item) => PantryItemTile(
                  icon: Icons.store,
                  itemName: item,
                  expiration: expiration,
                  quantity: '1 unit',
                )),

            const SizedBox(height: 24),

            // Canned Food Section
            _buildSectionHeader('Canned Food'),
            const SizedBox(height: 12),
            ...cannedFoodItems.map((item) => PantryItemTile(
                  icon: Icons.archive,
                  itemName: item,
                  expiration: expiration,
                  quantity: '300 grams',
                )),
          ],
        ),
      ),
    );
  }

  // Simplified section header without the stock message
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
