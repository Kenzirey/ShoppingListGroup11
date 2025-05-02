// lib/providers/meal_planner_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/meal_plan_entry.dart';
import 'package:shopping_list_g11/services/meal_planner_service.dart';
import 'package:shopping_list_g11/controllers/meal_planner_controller.dart';

class MealPlannerNotifier extends StateNotifier<Map<int, List<MealPlanEntry>>> {
  MealPlannerNotifier() : super({});

  void setPlans(int week, List<MealPlanEntry> plans) {
    state = {...state, week: plans};
  }

  void insert(int week, MealPlanEntry plan) {
    final list = [...?state[week], plan];
    state = {...state, week: list};
  }

  void remove(int week, String id) {
    final list = state[week]!.where((p) => p.id != id).toList();
    state = {...state, week: list};
  }
}

final mealPlannerProvider =
    StateNotifierProvider<MealPlannerNotifier, Map<int, List<MealPlanEntry>>>(
        (ref) => MealPlannerNotifier());

final mealPlannerServiceProvider = Provider((ref) => MealPlannerService());
final mealPlannerControllerProvider = Provider((ref) {
  return MealPlannerController(ref, ref.watch(mealPlannerServiceProvider));
});
