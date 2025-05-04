import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/widget/pantry_tile.dart';
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
      final currentUser = ref.watch(currentUserValueProvider);
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
    final fridgeItems =
        pantryItems.where((p) => p.category == 'Fridge').toList();
    final dryGoodsItems =
        pantryItems.where((p) => p.category == 'Freezer').toList();
    final cannedFoodItems =
        pantryItems.where((p) => p.category == 'Dry Storage').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
            _buildSectionHeader('Fridge'),
            const SizedBox(height: 12),
            if (fridgeItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...fridgeItems.map((item) => Dismissible(
                    key: ValueKey(item.id),
                    background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteItem(item.id!),
                    child: PantryItemTile(
                      category: item.category, // String?
                      itemName: item.name,
                      expiration: _formatExpiration(item.expirationDate),
                      quantity: item.quantity ?? 'N/A',
                    ),
                  )),
            const SizedBox(height: 24),
            _buildSectionHeader('Freezer'),
            const SizedBox(height: 12),
            if (dryGoodsItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...dryGoodsItems.map((item) => Dismissible(
                    key: ValueKey(item.id),
                    background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteItem(item.id!),
                    child: PantryItemTile(
                      category: item.category, // string key from supabase - matches the name of the svg.
                      itemName: item.name,
                      expiration: _formatExpiration(item.expirationDate),
                      quantity: item.quantity ?? 'N/A',
                    ),
                  )),
            const SizedBox(height: 24),
            _buildSectionHeader('Dry Storage'),
            const SizedBox(height: 12),
            if (cannedFoodItems.isEmpty)
              _noItemsPlaceholder()
            else
              ...cannedFoodItems.map((item) => Dismissible(
                    key: ValueKey(item.id),
                    background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteItem(item.id!),
                    child: PantryItemTile(
                      category: item.category,
                      itemName: item.name,
                      expiration: _formatExpiration(item.expirationDate),
                      quantity: item.quantity ?? 'N/A',
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _deleteItem(String itemId) {
    ref.read(pantryControllerProvider).removePantryItem(itemId);
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
    if (expiry == null) return '—';
    final diff = expiry.difference(DateTime.now()).inDays;
    return diff >= 0 ? '$diff d left' : '${-diff} d ago';
  }
}
