import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/pantry_tile.dart';

class PantryListScreen extends ConsumerStatefulWidget {
  const PantryListScreen({super.key});

  @override
  ConsumerState<PantryListScreen> createState() => _PantryListScreenState();
}

class _PantryListScreenState extends ConsumerState<PantryListScreen> {
  final List<String> fridgeItems = ['Milk', 'Eggs', 'Cheese', 'Chicken'];
  final List<String> dryGoodsItems = ['Bread', 'Cereal', 'Pasta'];
  final List<String> cannedFoodItems = ['Canned Beans', 'Tomato Sauce', 'Corn'];

  final String stockMessage = 'Current Stock';
  final String expiration = '2 days'; // You can later make this dynamic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        Text(
          stockMessage,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}
