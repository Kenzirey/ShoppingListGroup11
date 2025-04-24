import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final purchaseHistoryProvider = StateNotifierProvider<PurchaseHistoryNotifier, AsyncValue<List<Product>>>(
      (ref) => PurchaseHistoryNotifier(PurchaseHistoryService()),
);