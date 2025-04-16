import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/shopping_item.dart';
import '../providers/current_user_provider.dart';
import '../providers/recommendation_service_provider.dart';

class ShoppingSuggestionsScreen extends ConsumerStatefulWidget {
  const ShoppingSuggestionsScreen({super.key});

  @override
  ConsumerState<ShoppingSuggestionsScreen> createState() =>
      _ShoppingSuggestionsScreenState();
}

class _ShoppingSuggestionsScreenState
    extends ConsumerState<ShoppingSuggestionsScreen> {

  List<ShoppingItem> shoppingItems = [];
  final Set<String> selectedItems = {};

  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchShoppingItems();
  }

  Future<void> _fetchShoppingItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _errorMsg = 'No user is logged in.';
          _isLoading = false;
        });
        return;
      }

      final profileId = user.profileId!;
      final recommendationService = ref.read(recommendationServiceProvider);

      final recommendedNames = await recommendationService.fetchRecommendations(profileId);

      final recommendedItems = recommendedNames.map((itemName) => ShoppingItem(
        id: itemName,
        userId: profileId,
        itemName: itemName,
        quantity: '1 unit',
        category: 'Recommended',
        icon: Icons.star,
      )).toList();

      setState(() {
        if (!mounted) return;
        shoppingItems = [
          ...recommendedItems,
        ];
      });
    } catch (e) {
      setState(() {
         if (!mounted) return;
        _errorMsg = 'Error fetching recommendations: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (!mounted) return;
      if (selectedItems.length == shoppingItems.length) {
        selectedItems.clear();
      } else {
        selectedItems.addAll(shoppingItems.map((item) => item.id!));
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (selectedItems.contains(itemId)) {
        selectedItems.remove(itemId);
      } else {
        selectedItems.add(itemId);
      }
    });
  }

  void _onAddPressed() {
    final selected =
    shoppingItems.where((item) => selectedItems.contains(item.id)).toList();
    debugPrint(
        "Add pressed. Selected items: ${selected.map((i) => i.itemName).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final background = primaryContainer;

    final bool allSelected = selectedItems.length == shoppingItems.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMsg != null
            ? Center(child: Text(_errorMsg!))
            : ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'Shopping Suggestions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Add items to shopping list?',
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _onAddPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _toggleSelectAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: allSelected
                            ? primaryColor.withOpacity(0.3)
                            : primaryContainer,
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'Select all',
                          style: TextStyle(
                            fontSize: 16,
                            color: allSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Instead of weekly/monthly sections, display all items
            ...shoppingItems.map((item) {
              final isSelected = selectedItems.contains(item.id);
              final containerColor = isSelected
                  ? primaryColor.withOpacity(0.3)
                  : background;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _toggleItemSelection(item.id!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon ?? Icons.help_outline,
                            size: 20,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.itemName} | ${item.quantity ?? "1 unit"}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          isSelected
                              ? Icon(Icons.check_box_outlined,
                              size: 20, color: primaryColor)
                              : Icon(Icons.check_box_outline_blank,
                              size: 20, color: color),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
