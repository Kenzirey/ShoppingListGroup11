// lib/services/meal_planner_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_plan_entry.dart';

/// Service for handling meal planning operations with the database,
/// allows for fetching, adding, and deleting meal plans.
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
      debugPrint('Error fetching meal plans: ${e.message}');
      rethrow;
    }
  }

  /// Insert a new meal plan row and return it with generated id.
  Future<MealPlanEntry> addPlan(MealPlanEntry entry) async {
    try {
      final resp =
          await _db.from('meal_plans').insert(entry.toMap()).select().single();

      return MealPlanEntry.fromMap(resp);
    } on PostgrestException catch (e) {
      debugPrint('Error adding meal plan: ${e.message}');
      rethrow;
    }
  }

  /// Delete meal plan by its id.
  Future<void> removePlan(String id) async {
    try {
      await _db.from('meal_plans').delete().eq('id', id);
    } on PostgrestException {
      rethrow;
    }
  }
}
