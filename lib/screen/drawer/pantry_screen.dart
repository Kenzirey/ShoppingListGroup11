import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/pantry_item.dart';
import 'package:shopping_list_g11/widget/pantry_tile.dart';
import 'package:shopping_list_g11/providers/pantry_items_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';

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

  void _updateExpiryDate(String itemId, DateTime newDate) {
    ref.read(pantryControllerProvider).updatePantryItem(
          itemId,
          name: ref
              .read(pantryItemsProvider)
              .firstWhere((item) => item.id == itemId)
              .name,
          expirationDate: newDate,
        );
  }

  @override
  Widget build(BuildContext context) {
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
            ..._buildCategorySection('Fridge', showColumnLabels: true),
            ..._buildCategorySection('Freezer'),
            ..._buildCategorySection('Dry Storage'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showColumnLabels = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const Spacer(),
        if (showColumnLabels) ...[
          SizedBox(
            width: 50,
            child: Text(
              'Quantity',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              'Days left',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
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

  /// Returns the difference in pure day difference,
  /// to remove the off by 1 problem we've had.
  String _formatExpiration(DateTime? expiry) {
    if (expiry == null) return '—';

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfExpiry = DateTime(expiry.year, expiry.month, expiry.day);

    final diffDays = startOfExpiry.difference(startOfToday).inDays;

    return diffDays >= 0 ? '$diffDays d left' : '${-diffDays} d ago';
  }

  // Build entire pantry category section, with dismissible items.
  List<Widget> _buildCategorySection(
    String category, {
    bool showColumnLabels = false,
  }) {
    final allItems = ref.watch(pantryItemsProvider);
    final items = allItems.where((p) => p.category == category).toList();

    return [
      _buildSectionHeader(category, showColumnLabels: showColumnLabels),
      const SizedBox(height: 12),
      if (items.isEmpty)
        _noItemsPlaceholder()
      else
        ...items.map(_buildDismissible),
      const SizedBox(height: 24),
    ];
  }

  // the dismissible (delete with swiping)
  Widget _buildDismissible(PantryItem item) {
    final pantryItems = ref.read(pantryItemsProvider);
    final globalIndex = pantryItems.indexWhere((i) => i.id == item.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,

          background: const SizedBox.shrink(),

          // added the cherry red from the design guide by Solwr
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF9A0007),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          onDismissed: (_) {
            if (item.id != null) {
              ref.read(pantryControllerProvider).removePantryItem(item.id!);
            }
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar.buildSnackBar(
                  title: 'Removed',
                  message: '${item.name} removed',
                  innerPadding: const EdgeInsets.symmetric(horizontal: 16),
                  actionText: 'Undo',
                  onAction: () {
                    ref
                        .read(pantryControllerProvider)
                        .restorePantryItem(globalIndex, item);
                  },
                ),
              );
          },

          child: PantryItemTile(
            category: item.category,
            itemName: item.name,
            unit: item.unit ?? '',
            quantity: item.quantity?.toString() ?? 'N/A',
            expiration: _formatExpiration(item.expirationDate),
            expiryDate: item.expirationDate,
            itemId: item.id!,
            onExpiryChanged: _updateExpiryDate,
          ),
        ),
      ),
    );
  }
}
