import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/pantry_tile.dart';
import 'package:shopping_list_g11/controllers/pantry_controller.dart';
import 'package:shopping_list_g11/providers/pantry_items_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';

/// Screen for showing which food items the user has in stock,
/// from fridge to dry goods, canned food etc.
class PantryListScreen extends ConsumerStatefulWidget {
  const PantryListScreen({super.key});

  @override
  ConsumerState<PantryListScreen> createState() => _PantryListScreenState();
}

class _PantryListScreenState extends ConsumerState<PantryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null && currentUser.profileId != null) {
        await ref
            .read(pantryControllerProvider)
            .fetchPantryItems(currentUser.profileId!);
      }
    });
  }

@override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(pantryItemsProvider);
    final fridgeItems = pantryItems.where((p) => p.category == 'Fridge').toList();
    final dryGoodsItems = pantryItems.where((p) => p.category == 'Dry Goods').toList();
    final cannedFoodItems = pantryItems.where((p) => p.category == 'Canned Food').toList();

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
            if (fridgeItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...fridgeItems.map((item) => PantryItemTile(
                    icon: Icons.kitchen,
                    itemName: item.name,
                    expiration: _formatExpiration(item.expirationDate),
                    quantity: item.quantity ?? 'N/A',
                  )),

            const SizedBox(height: 24),

            // Dry Goods Section
            _buildSectionHeader('Dry Goods'),
            const SizedBox(height: 12),
            if (dryGoodsItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...dryGoodsItems.map((item) => PantryItemTile(
                    icon: Icons.store,
                    itemName: item.name,
                    expiration: _formatExpiration(item.expirationDate),
                    quantity: item.quantity ?? 'N/A',
                  )),

            const SizedBox(height: 24),

            // Canned Food Section
            _buildSectionHeader('Canned Food'),
            const SizedBox(height: 12),
            if (cannedFoodItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...cannedFoodItems.map((item) => PantryItemTile(
                    icon: Icons.archive,
                    itemName: item.name,
                    expiration: _formatExpiration(item.expirationDate),
                    quantity: item.quantity ?? 'N/A',
                  )),
          ],
        ),
      ),

    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // TODO: Implement Logic here 
      },
      child: const Icon(Icons.add),
    ),

        );
      }

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

  Widget _noItemsPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No items found',
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        ),
      ),
    );
  }


  String _formatExpiration(DateTime? expiry) {
    if (expiry == null) return 'N/A';
    final diff = expiry.difference(DateTime.now()).inDays;

    if (diff < 0) {
      return 'Expired ${diff.abs()} days ago';
    } else if (diff == 0) {
      return 'Expires today';
    } else if (diff == 1) {
      return '1 day left';
    } else {
      return '$diff days left';
    }
  }
}
