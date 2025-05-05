// lib/services/meal_planner_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan_entry.dart';

class MealPlannerService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Fetch all entries for a given user/week.
  Future<List<MealPlanEntry>> fetchWeekPlans(String userId, int week) async {
    try {
      final resp = await _db
          .from('meal_plans')
          .select()
          .eq('user_id', userId)
          .eq('week', week)
          .order('day', ascending: true)
          .order('created_at', ascending: true);

      final list = (resp as List).cast<Map<String, dynamic>>();
      return list.map(MealPlanEntry.fromMap).toList();
    } on PostgrestException catch (e) {
      throw e;
    }
  }

  /// Insert a new meal plan row and return it with generated id.
  Future<MealPlanEntry> addPlan(MealPlanEntry entry) async {
    try {
      final resp =
          await _db.from('meal_plans').insert(entry.toMap()).select().single();

      return MealPlanEntry.fromMap(resp as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw e;
    }
  }

  /// Delete by id.
  Future<void> removePlan(String id) async {
    try {
      await _db.from('meal_plans').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw e;
    }
  }
}
