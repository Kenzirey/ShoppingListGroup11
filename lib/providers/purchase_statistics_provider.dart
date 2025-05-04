import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/purchase_statistics_controller.dart';
import '../services/purchase_statistics_service.dart';
import 'current_user_provider.dart';

/// This provider fetches the purchase statistics of a user and exposes it as a state notifier.
class PurchaseStatisticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final PurchaseStatisticsService _service;

  PurchaseStatisticsNotifier(this._service) : super(const AsyncValue.loading()) {
    // Initialize with current month and year
    final now = DateTime.now();
    loadData(now.year, now.month);
  }

  Future<void> loadData(int year, int month) async {
    state = const AsyncValue.loading();

    try {
      final monthlyData = await _service.getMonthlySpending(year, month);
      final yearlyData = await _service.getYearlySpending(year);

      state = AsyncValue.data({
        'monthlyData': monthlyData,
        'yearlyData': yearlyData,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final purchaseStatisticsControllerProvider = Provider<PurchaseStatisticsController>((ref) {
  final supabase = Supabase.instance.client;
  final user = ref.watch(currentUserProvider).value;
  final profileId = user?.profileId;

  return PurchaseStatisticsController(
    supabase: supabase,
    profileId: profileId,
  );
});

final purchaseStatisticsServiceProvider = Provider<PurchaseStatisticsService>((ref) {
  final statisticsController = ref.watch(purchaseStatisticsControllerProvider);
  return PurchaseStatisticsService(statisticsController: statisticsController);
});

final purchaseStatisticsProvider = StateNotifierProvider<PurchaseStatisticsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final service = ref.watch(purchaseStatisticsServiceProvider);
  return PurchaseStatisticsNotifier(service);
});