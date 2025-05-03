import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pantry_item.dart';
import '../providers/current_user_provider.dart';
import '../providers/pantry_items_provider.dart';

/// Auto-fetching provider that ensures pantry items are loaded
final homeScreenProvider = FutureProvider.autoDispose<List<PantryItem>>((ref) async {
  final currentUser = ref.watch(currentUserValueProvider);
  final pantryItems = ref.watch(pantryItemsProvider);

  // If we already have items, return them immediately
  if (pantryItems.isNotEmpty) {
    return pantryItems;
  }

  // Otherwise fetch them if we have a user
  if (currentUser != null && currentUser.profileId != null) {
    await ref.read(pantryControllerProvider).fetchPantryItems(currentUser.profileId!);
    return ref.read(pantryItemsProvider);
  }

  return [];
});