import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import '../models/product.dart';
import '../services/purchase_history_service.dart';

/// This provider fetches the purchase history of a user and exposes it as a state notifier.
class PurchaseHistoryNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final PurchaseHistoryService _service;

  PurchaseHistoryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPurchaseHistory();
  }

  Future<void> loadPurchaseHistory() async {
    state = const AsyncValue.loading();
    try {
      final products = await _service.fetchPurchaseHistory();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final purchaseHistoryProvider = StateNotifierProvider
    .autoDispose<PurchaseHistoryNotifier, AsyncValue<List<Product>>>(
  (ref) {
    // watch auth stream (user), on logout / new login dispose old notifier and build fresh
    ref.watch(currentUserProvider);

    return PurchaseHistoryNotifier(PurchaseHistoryService());
  },
);