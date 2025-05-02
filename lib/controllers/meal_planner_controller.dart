// lib/controllers/meal_planner_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_plan_entry.dart';
import '../services/meal_planner_service.dart';
import '../providers/meal_planner_provider.dart';

class MealPlannerController {
  final Ref ref;
  final MealPlannerService _svc;
  MealPlannerController(this.ref, this._svc);

  Future<void> fetchPlans(String userId, int week) async {
    final plans = await _svc.fetchWeekPlans(userId, week);
    ref.read(mealPlannerProvider.notifier).setPlans(week, plans);
  }

  Future<void> addPlan(MealPlanEntry entry) async {
    final saved = await _svc.addPlan(entry);
    ref.read(mealPlannerProvider.notifier).insert(entry.week, saved);
  }

  Future<void> removePlan(String id, int week) async {
    await _svc.removePlan(id);
    ref.read(mealPlannerProvider.notifier).remove(week, id);
  }
}
