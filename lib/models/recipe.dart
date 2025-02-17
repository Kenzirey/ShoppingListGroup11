import 'package:flutter/material.dart';

/// Represents a recipe for a meal, with both serving size, time, ingredients and instructions for the user.
class Recipe {
  final String name;
  final String summary;
  final String yields;
  final String totalTime;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.name,
    required this.summary,
    required this.yields,
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

    /// Helper method for extracting the minutes from prep + cook time.
    int extractMinutes(String text) {
      final match = RegExp(r"(\d+)").firstMatch(text);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
      return 0;
    }

    // Name of the recipe, such as Pasta Carbonara
    final nameMatch = RegExp(
      r"\*\*Recipe Name:\*\*\s*(.*?)\s*\*\*Summary:",
      dotAll: true,
    ).firstMatch(response);
    final name = cleanText(nameMatch?.group(1) ?? "Unknown Recipe");

    // Summary of the recipe, is shown in the chat.
    final summaryMatch = RegExp(
      r"\*\*Summary:\*\*\s*(.*?)\s*\*\*Yields:",
      dotAll: true,
    ).firstMatch(response);
    final summary = cleanText(summaryMatch?.group(1) ?? "No summary available.");

    // Yields aka servings, so for how many people.
    final yieldsMatch = RegExp(
      r"\*\*Yields:\*\*\s*(.+?)(?=\n\*\*Prep Time:|\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final yieldsRaw = cleanText(yieldsMatch?.group(1) ?? "Unknown");

    // Prep + cook time.
    final prepTimeMatch = RegExp(
      r"\*\*Prep Time:\*\*\s*(.+?)(?=\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final prepRaw = cleanText(prepTimeMatch?.group(1) ?? "0 minutes");

    final cookTimeMatch = RegExp(
      r"\*\*Cook Time:\*\*\s*(.+?)(?=\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final cookRaw = cleanText(cookTimeMatch?.group(1) ?? "0 minutes");

    // Convert times to numeric minutes.
    final prepInt = extractMinutes(prepRaw);
    final cookInt = extractMinutes(cookRaw);
    final totalMinutes = prepInt + cookInt;

    // Total time, so prep + cooking.
    final totalTime = "$totalMinutes minutes";

    // Keep yields as just the raw number
    final yields = yieldsRaw;

    // Extract Ingredients (Stop at "**Instructions:")
    final ingredientsMatch = RegExp(
      r"\*\*Ingredients:\*\*(.+?)\*\*Instructions:",
      dotAll: true,
    ).firstMatch(response);

    final ingredients = ingredientsMatch?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith("*"))
            .map((e) => cleanText(e.replaceAll("*", "").trim()))
            .toList()
        ?? [];

    // Extract Instructions (Only numbered steps)
    final instructionsMatch = RegExp(
      r"\*\*Instructions:\*\*(.+)",
      dotAll: true,
    ).firstMatch(response);

    final instructions = instructionsMatch?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith(RegExp(r"^\d+\.")))
            .map((e) => cleanText(e.trim()))
            .toList()
        ?? [];

    // Debug, temporary :)
    debugPrint("=== Parsed Recipe Data ===\n"
        "📌 Name: $name\n"
        "📜 Summary: $summary\n"
        "🍽️ Yields: $yields\n"
        "⏳ Total Time: $totalTime\n"
        "🛒 Ingredients Count: ${ingredients.length}\n"
        "📖 Instructions Count: ${instructions.length}\n"
        "🛒 Ingredients: $ingredients\n"
        "📖 Instructions: $instructions");

    // the now-parsed recipe
    return Recipe(
      name: name,
      summary: summary,
      yields: yields,
      totalTime: totalTime,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}
