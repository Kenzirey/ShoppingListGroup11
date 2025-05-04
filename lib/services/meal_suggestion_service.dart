import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/utils/recipe_prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

/// Service for generating meal suggestions based on pantry items close to expiration.
/// Integrates with Supabase and Gemini API.
class MealSuggestionService {
  MealSuggestionService({required this.supabase, required this.gemini});
  final SupabaseClient supabase;
  final Gemini gemini;

  /// Helper - returns the profile ID of the currently authenticated user.
  Future<String?> _profileId() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select('id')
        .eq('auth_id', user.id)
        .single();

    return data['id'] as String?;
  }


  /// Suggests recipes based on items in user's pantry that are expiring soon.
  Future<List<Recipe>> suggestionsBasedOnExpiring() async {
    try {
      // 1) current profile
      final profileId = await _profileId();
      if (profileId == null) {
        debugPrint('User not logged in'); // should never even get here 👌
        return const [];
      }

      // items that expire within 7 days
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final in7Iso =
          DateTime.now().toUtc().add(const Duration(days: 7)).toIso8601String();

      final expiringRes = await supabase
          .from('receipt_items')
          .select('name, receipts!inner(user_id)')
          .eq('receipts.user_id', profileId)
          .gte('expiration_date', nowIso)
          .lte('expiration_date', in7Iso);

      if (expiringRes.isEmpty) return const [];

      final expiringNames = (expiringRes as List<dynamic>)
          .map((expiringItem) => expiringItem['name'] as String)
          .toList();
      debugPrint('Expiring names = $expiringNames');

      // normalize norwegian brand names to generic cooking ingredients, so that it works with recipe screen
      Map<String, String> normalized;
      try {
        normalized = await _normalizeItems(expiringNames);
      } catch (_) {
        normalized = {for (final names in expiringNames) names: names.toLowerCase()};
      }
      final genericExpiring = normalized.values.toSet();
      debugPrint('Generic names = $genericExpiring');

      // fetch all of the recipes from sup
      final recipeRows = await supabase
          .from('recipes')
          .select('name, ingredients, yields')
          .limit(50);

      // Map each ingredient to a list of potentially matching recipes, but can be empty.
      final Map<String, List<Recipe>> byIngredient = {
        for (final genericName in genericExpiring) genericName: []
      };

      for (final row in recipeRows) {
        final ing = (row['ingredients'] as List<dynamic>).cast<String>();
        for (final g in genericExpiring) {
          if (ing.any((i) => i.toLowerCase().trim() == g)) {
            byIngredient[g]!.add(
              Recipe(
                name: row['name'] as String,
                ingredients: ing,
                yields: row['yields'] as String? ?? '1',
                summary: 'Saved recipe that uses $g.',
                instructions: const [],
                prepTime: '',
                cookTime: '',
                totalTime: '',
              ),
            );
            break;
          }
        }
      }

      // fallback for every ingredient that has no recipe yet
      for (final genericIngredient in genericExpiring) {
        if (byIngredient[genericIngredient]!.isEmpty) {
          final req =
              'Create ONE simple recipe (metric units) whose key ingredient is $genericIngredient '
              'and that can be prepared with common pantry items.';
          final raw = await generateRecipeWithPrompt(req);
          final parsed = Recipe.fromString(raw);

          if (parsed.name.isNotEmpty) {
            // Add it to suggestions
            byIngredient[genericIngredient]!.add(parsed);

            // store it in the database to grow our recipe collection.
            try {
              await supabase.from('recipes').insert({
                'name': parsed.name,
                'ingredients': parsed.ingredients,
                'instructions': parsed.instructions,
                'yields': parsed.yields,
                'prep_time': parsed.prepTime,
                'cook_time': parsed.cookTime,
                'total_time': parsed.totalTime,
              });
              debugPrint('Saved new recipe: ${parsed.name}');
            } catch (e) {
              debugPrint('Failed to save recipe: ${parsed.name}\n$e');
            }
          }
        }
      }

      // one recipe per ingredient, could expand later.
      final suggestions = [
        for (final g in byIngredient.keys) byIngredient[g]!.first
      ];

      debugPrint('Total suggestions = ${suggestions.length}'); // temporary debugging.
      return suggestions;
    } catch (e, st) {
      debugPrint('ERROR $e\n$st');
      return const [];
    }
  }


  final Map<String, String> _normCache = {};
  /// Normalises a list of grocery items using Gemini.
  /// Turns specific norwegian brand names into generic cooking ingredients.
  Future<Map<String, String>> _normalizeItems(List<String> items) async {
    final uncached = items.where((i) => !_normCache.containsKey(i)).toList();
    if (uncached.isNotEmpty) {
      final quoted = uncached.map((e) => '"$e"').join(', ');
      final prompt = '''
        You are an AI that converts branded Norwegian grocery product names
        into short, generic English cooking ingredients.

        Return ONLY JSON in this shape:
        [
          {"original":"<input>", "generic":"<english word>"}
        ]

        Items: [$quoted]
        JSON:
        ''';

      final res = await gemini.prompt(parts: [Part.text(prompt)]);
      var body = res?.output ?? '[]';

      body = body.replaceAll('```json', '').replaceAll('```', '').trim();

      for (final m in jsonDecode(body) as List<dynamic>) {
        _normCache[m['original']] =
            (m['generic'] as String).toLowerCase().trim();
      }
    }

    // mapping for requested items only
    return {for (final i in items) i: _normCache[i]!};
  }
}
