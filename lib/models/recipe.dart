import 'package:flutter/material.dart';

/// Represents a recipe for a meal, with serving size, time, ingredients and instructions.
class Recipe {
  final String name;
  final String summary;
  final String yields;
  final String prepTime;
  final String cookTime;
  final String totalTime; // In case we want to use it.
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.name,
    required this.summary,
    required this.yields,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.ingredients,
    required this.instructions,
  });

  /// Factory constructor to get the whole chunked response into one piece.
  factory Recipe.fromChunks(List<String> chunks) {
    // JOIN US
    String response = chunks.join(" ").replaceAll("\n\n", "\n").trim();

    // Removes the ** from the gemini response.
    String cleanText(String text) {
      return text.replaceAllMapped(
        RegExp(r"\*\*(.*?)\*\*"),
        (match) => match.group(1) ?? "",
      ).trim();
    }

    /// Helper method for extracting the minutes from a time string.
    /// Now handles hours (e.g. "1.5 hours" or "1 hr") and minutes (e.g. "30 min").
    int extractMinutes(String text) {
      text = text.toLowerCase();
      int total = 0;
      // Check for hours (e.g. "1.5 hours" or "1 hr")
      final hourMatch = RegExp(r'([\d\.]+)\s*(hour|hr)').firstMatch(text);
      if (hourMatch != null) {
        double hours = double.tryParse(hourMatch.group(1)!) ?? 0.0;
        total += (hours * 60).round();
      }
      // Check for minutes (e.g. "30 min")
      final minuteMatch = RegExp(r'(\d+)\s*min').firstMatch(text);
      if (minuteMatch != null) {
        int minutes = int.tryParse(minuteMatch.group(1)!) ?? 0;
        total += minutes;
      }
      // Fallback: if no explicit "hour" or "min" words, extract any number.
      if (total == 0) {
        final fallback = RegExp(r"([\d\.]+)").firstMatch(text);
        if (fallback != null) {
          total = (double.tryParse(fallback.group(1)!) ?? 0).round();
        }
      }
      return total;
    }

    // Extract name.
    final nameMatch = RegExp(
      r"\*\*Recipe Name:\*\*\s*(.*?)\s*\*\*Summary:",
      dotAll: true,
    ).firstMatch(response);
    final name = cleanText(nameMatch?.group(1) ?? "Unknown Recipe");

    // Extract summary.
    final summaryMatch = RegExp(
      r"\*\*Summary:\*\*\s*(.*?)\s*\*\*Yields:",
      dotAll: true,
    ).firstMatch(response);
    final summary =
        cleanText(summaryMatch?.group(1) ?? "No summary available.");

    // Extract yields.
    final yieldsMatch = RegExp(
      r"\*\*Yields:\*\*\s*(.+?)(?=\n\*\*Prep Time:|\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final yieldsRaw = cleanText(yieldsMatch?.group(1) ?? "Unknown");

    // Extract prep time.
    final prepTimeMatch = RegExp(
      r"\*\*Prep Time:\*\*\s*(.+?)(?=\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final prepRaw = cleanText(prepTimeMatch?.group(1) ?? "0 minutes");

    // Extract cook time.
    final cookTimeMatch = RegExp(
      r"\*\*Cook Time:\*\*\s*(.+?)(?=\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final cookRaw = cleanText(cookTimeMatch?.group(1) ?? "0 minutes");

    // Convert times to numeric minutes.
    final prepInt = extractMinutes(prepRaw);
    final cookInt = extractMinutes(cookRaw);

    // Create string representations.
    final prepTimeStr = "$prepInt minutes";
    final cookTimeStr = "$cookInt minutes";
    final totalMinutesStr = "${prepInt + cookInt} minutes";

    // Extract Ingredients (Stop at "**Instructions:")
    final ingredientsMatch = RegExp(
      r"\*\*Ingredients:\*\*(.+?)\*\*Instructions:",
      dotAll: true,
    ).firstMatch(response);
    final ingredients = ingredientsMatch?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith("*"))
            .map((e) => cleanText(e.replaceAll("*", "").trim()))
            .toList() ??
        [];

    // Extract Instructions (Only numbered steps)
    final instructionsMatch = RegExp(
      r"\*\*Instructions:\*\*(.+)",
      dotAll: true,
    ).firstMatch(response);
    final instructions = instructionsMatch?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith(RegExp(r"^\d+\.")))
            .map((e) => cleanText(e.trim()))
            .toList() ??
        [];

    // Debug output.
    debugPrint("=== Parsed Recipe Data ===\n"
        "📌 Name: $name\n"
        "📜 Summary: $summary\n"
        "🍽️ Yields: $yieldsRaw\n"
        "⏳ Prep Time: $prepTimeStr\n"
        "⏳ Cook Time: $cookTimeStr\n"
        "⏳ Total Time: $totalMinutesStr\n"
        "🛒 Ingredients Count: ${ingredients.length}\n"
        "📖 Instructions Count: ${instructions.length}\n"
        "🛒 Ingredients: $ingredients\n"
        "📖 Instructions: $instructions");

    // Return the parsed recipe.
    return Recipe(
      name: name,
      summary: summary,
      yields: yieldsRaw,
      prepTime: prepTimeStr,
      cookTime: cookTimeStr,
      totalTime: totalMinutesStr,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}
