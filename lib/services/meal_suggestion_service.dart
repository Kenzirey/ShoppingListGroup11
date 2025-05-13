import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/services/gemini_service.dart';
import 'package:shopping_list_g11/utils/recipe_prompt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for generating meal suggestions based on pantry items close to expiration.
class MealSuggestionService {
  final SupabaseClient supabase;

  /// Helper - returns the profile ID of the currently authenticated user.
  MealSuggestionService({required this.supabase});

  Future<String?> _profileId() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await supabase
          .from('profiles')
          .select('id')
          .eq('auth_id', user.id)
          .single();
      return data['id'] as String?;
    } catch (e) {
      debugPrint("Error fetching profileId: $e");
      return null;
    }
  }

  // Cache for normalized items
  final Map<String, String> _normCache = {};

  /// Normalises a list of grocery items using Gemini via an Edge Function.
  Future<Map<String, String>> _normalizeItems(List<String> items) async {
    final uncached = items.where((i) => !_normCache.containsKey(i)).toList();
    if (uncached.isNotEmpty) {
      final quoted = uncached.map((e) => '"$e"').join(', ');

      // System part of the prompt: instructs Gemini on the task and JSON output format
      const String systemNormalizationPrompt = '''
      You are an AI that converts branded Norwegian grocery product names
      into short, generic English cooking ingredients.
      Return ONLY JSON in this shape:
      [ {"original":"<input>", "generic":"<english word>"} ]
      JSON:
      '''; // The "Items: [$quoted]" will be part of the query

      // User-specific part of the prompt: the actual items to normalize
      final String queryForNormalization = 'Items: [$quoted]';

      debugPrint(
          "Normalization: Sending to geminiRaw. System Prompt: \"$systemNormalizationPrompt\", Query: \"$queryForNormalization\"");

      try {
        Map<String, dynamic> rawGeminiResponse = await geminiRaw(
          prompt: systemNormalizationPrompt,
          query: queryForNormalization,
        );
        debugPrint(
            "Normalization: Received map from geminiRaw: $rawGeminiResponse"); // temporary debug

        // Extract the JSON STRING from Gemini's standard response structure
        String? jsonStringFromGemini = rawGeminiResponse['candidates']?[0]
            ?['content']?['parts']?[0]?['text'];

        if (jsonStringFromGemini != null && jsonStringFromGemini.isNotEmpty) {
          debugPrint(
              "Normalization: Extracted JSON string: $jsonStringFromGemini");
          // Remove markdown code block if gemini adds that.
          jsonStringFromGemini = jsonStringFromGemini
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          try {
            List<dynamic> normalizationList =
                jsonDecode(jsonStringFromGemini) as List<dynamic>;
            for (final m in normalizationList) {
              if (m is Map<String, dynamic> &&
                  m.containsKey('original') &&
                  m.containsKey('generic')) {
                _normCache[m['original'] as String] =
                    (m['generic'] as String).toLowerCase().trim();
              } else {
                debugPrint(
                    "Normalization: Skipped invalid item in decoded JSON list: $m");
              }
            }
            debugPrint("Normalization: Cache updated: $_normCache");
          } catch (e, stackTrace) {
            debugPrint(
                "Normalization: CRITICAL - Failed to jsonDecode extracted string: $e\n$stackTrace\nString was: \"$jsonStringFromGemini\"");
          }
        } else {
          debugPrint(
              "Normalization: CRITICAL - Gemini did not return text or the expected structure for normalization. Full response: $rawGeminiResponse");
        }
      } catch (e, stackTrace) {
        debugPrint(
            "Error during _normalizeItems calling geminiRaw: $e\n$stackTrace");
      }
    }

    final Map<String, String> result = {};
    for (final i in items) {
      final genericName = _normCache[i];
      if (genericName != null && genericName.isNotEmpty) {
        result[i] = genericName;
      } else {
        // If not found in cache or generic name is empty, fallback to lowercased original
        result[i] = i.toLowerCase();
        debugPrint(
            "Normalization: No valid generic name found for '$i', using fallback '${result[i]}'");
      }
    }
    debugPrint("Normalization: Final result map: $result");
    return result;
  }

  Future<List<Recipe>> suggestionsBasedOnExpiring() async {
    try {
      // find user :)
      final profileId = await _profileId();
      if (profileId == null) {
        debugPrint('User not logged in for suggestionsBasedOnExpiring');
        return const [];
      }

      final nowUtc = DateTime.now().toUtc();
      final in7DaysUtc = nowUtc.add(const Duration(days: 7)); 

      final expiringRes = await supabase
          .from('inventory')
          .select('name')
          .eq('user_id', profileId)
          .gte('expiration_date', nowUtc.toIso8601String())
          .lte('expiration_date', in7DaysUtc.toIso8601String());

      if (expiringRes.isEmpty) {
        debugPrint('No expiring inventory items found.');
        return const [];
      }

      final expiringNames = (expiringRes as List<dynamic>)
          .map((row) => row['name'] as String)
          .where((s) => s.trim().isNotEmpty)
          .toSet()      // remove duplicates in case you have like 7 milk cartons like some sort of loon
          .toList();

      debugPrint('Expiring names from DB = $expiringNames');
      if (expiringNames.isEmpty) return const [];

      Map<String, String> normalized;
      try {
        normalized = await _normalizeItems(expiringNames);
      } catch (e) {
        debugPrint('Normalization step failed: $e. Falling back.');
        normalized = { for (final n in expiringNames) n: n.toLowerCase() };
      }

      final genericExpiring = normalized.values
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      if (genericExpiring.isEmpty) return const [];

      final recipeRows = await supabase
          .from('recipes')
          .select(
              'name, summary, yields, prep_time, cook_time, total_time, ingredients, instructions, dietary_classification')
          .limit(100);

      final Map<String, List<Recipe>> byIngredient = {
        for (final genericName in genericExpiring) genericName: []
      };

      for (final row in recipeRows) {
        final recipeIngredients = (row['ingredients'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase().trim())
                .toList() ??
            [];
        for (final g in genericExpiring) {
          if (recipeIngredients
              .any((recipeIng) => recipeIng.contains(g.toLowerCase().trim()))) {
            byIngredient[g]!.add(
              Recipe(
                name: row['name'] as String? ?? 'Unnamed Recipe',
                summary: row['summary'] as String? ?? 'Uses $g.',
                yields: row['yields'] as String? ?? '1 serving',
                prepTime: row['prep_time'] as String? ?? '',
                cookTime: row['cook_time'] as String? ?? '',
                totalTime: row['total_time'] as String? ?? '',
                ingredients:
                    (row['ingredients'] as List<dynamic>?)?.cast<String>() ??
                        [],
                instructions:
                    (row['instructions'] as List<dynamic>?)?.cast<String>() ??
                        [],
                dietaryClassification: row['dietary_classification'] as String?,
              ),
            );
            break;
          }
        }
      }

      for (final genericIngredient in genericExpiring) {
        // Ensure we are checking against actual generic ingredients that might need a recipe
        if (genericIngredient.isEmpty) {
          continue;
        }

        if (byIngredient[genericIngredient]!.isEmpty) {
          debugPrint(
              'Recipe Gen: No stored recipe for "$genericIngredient". Generating...');

          final String userQueryForRecipe =
              'Create ONE simple recipe (metric units) whose key ingredient is "$genericIngredient" '
              'and that can be prepared with common pantry items. Adhere strictly to the output format defined in the system prompt.';

          Map<String, dynamic> rawGeminiResponse;
          try {
            rawGeminiResponse = await geminiRaw(
              prompt: kRecipeSystemPrompt,
              query: userQueryForRecipe,
            );
            debugPrint(
                "Recipe Gen: Received map from geminiRaw for '$genericIngredient': $rawGeminiResponse");
          } catch (e, stackTrace) {
            debugPrint(
                "Recipe Gen: CRITICAL - Error calling geminiRaw for '$genericIngredient': $e\n$stackTrace");
            continue;
          }

          String? geminiFormattedText = rawGeminiResponse['candidates']?[0]
              ?['content']?['parts']?[0]?['text'];

          if (geminiFormattedText != null &&
              geminiFormattedText.trim().isNotEmpty) {
            debugPrint(
                "Recipe Gen: Extracted text for '$genericIngredient'. Length: ${geminiFormattedText.length}.");

            Recipe parsedRecipe;
            try {
              parsedRecipe = Recipe.fromString(geminiFormattedText.trim());
            } catch (e, stackTrace) {
              debugPrint(
                  "Recipe Gen: CRITICAL - Recipe.fromString failed for '$genericIngredient': $e\nStackTrace: $stackTrace\nText was: \"$geminiFormattedText\"");
              continue;
            }

            if (parsedRecipe.name.isNotEmpty &&
                parsedRecipe.name != "Unknown Recipe") {
              byIngredient[genericIngredient]!.add(parsedRecipe);
              debugPrint(
                  'Recipe Gen: Successfully parsed recipe for "$genericIngredient": ${parsedRecipe.name}');

              try {
                await supabase.from('recipes').insert({
                  'name': parsedRecipe.name,
                  'summary': parsedRecipe.summary,
                  'yields': parsedRecipe.yields,
                  'prep_time': parsedRecipe.prepTime,
                  'cook_time': parsedRecipe.cookTime,
                  'total_time': parsedRecipe.totalTime,
                  'ingredients': parsedRecipe.ingredients,
                  'instructions': parsedRecipe.instructions,
                  'dietary_classification': parsedRecipe.dietaryClassification,
                });
                debugPrint(
                    'Recipe Gen: Saved new recipe "${parsedRecipe.name}" to DB.');
              } catch (e) {
                debugPrint(
                    'Recipe Gen: Failed to save new recipe "${parsedRecipe.name}" to DB. Error: $e.');
                debugPrint(
                    'Recipe Gen: Data attempted to insert: name(${parsedRecipe.name.runtimeType}), summary(${parsedRecipe.summary.runtimeType}), yields(${parsedRecipe.yields.runtimeType}), prepTime(${parsedRecipe.prepTime.runtimeType}), cookTime(${parsedRecipe.cookTime.runtimeType}), totalTime(${parsedRecipe.totalTime.runtimeType}), ingredients(${parsedRecipe.ingredients.runtimeType}), instructions(${parsedRecipe.instructions.runtimeType}), dietaryClassification(${parsedRecipe.dietaryClassification.runtimeType})');
              }
            } else {
              debugPrint(
                  "Recipe Gen: Parsing for '$genericIngredient' resulted in 'Unknown Recipe'. Original text: \"$geminiFormattedText\""); // unown the pokemon?
            }
          } else {
            debugPrint(
                "Recipe Gen: CRITICAL - Gemini did not return text or the expected structure via geminiRaw for '$genericIngredient'. Response: $rawGeminiResponse");
          }
        }
      }

      final List<Recipe> suggestions = [];
      for (final g in genericExpiring) {
        if (byIngredient.containsKey(g) && byIngredient[g]!.isNotEmpty) {
          suggestions.add(byIngredient[g]!.first);
        }
      }

      debugPrint('Total suggestions compiled: ${suggestions.length}'); //all of these debugs are just for testing.
      return suggestions;
    } catch (e, st) {
      debugPrint('FATAL ERROR in suggestionsBasedOnExpiring: $e\n$st');
      return const [];
    }
  }
}
