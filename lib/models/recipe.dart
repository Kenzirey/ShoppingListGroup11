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
  final String? dietaryClassification;

  Recipe(
      {required this.name,
      required this.summary,
      required this.yields,
      required this.prepTime,
      required this.cookTime,
      required this.totalTime,
      required this.ingredients,
      required this.instructions,
      this.dietaryClassification});

  /// Removes any ***...
  static String cleanText(String text) {
    return text
        .replaceAllMapped(
          RegExp(r"\*\*(.*?)\*\*"),
          (match) => match.group(1) ?? "",
        )
        .trim();
  }

  static int extractMinutes(String text) {
    text = text.toLowerCase();
    int total = 0;

    // Check for hours such as 1 hour or 1.5 hour
    final hourMatch = RegExp(r'([\d\.]+)\s*(hour|hr)').firstMatch(text);
    if (hourMatch != null) {
      double hours = double.tryParse(hourMatch.group(1)!) ?? 0;
      total += (hours * 60).round();
    }

    // Check for minutes such as 30 min.
    final minuteMatch = RegExp(r'(\d+)\s*min').firstMatch(text);
    if (minuteMatch != null) {
      int minutes = int.tryParse(minuteMatch.group(1)!) ?? 0;
      total += minutes;
    }

    // Fallback: no hr or min, parse any nubmer it has.
    if (total == 0) {
      final fallback = RegExp(r"([\d\.]+)").firstMatch(text);
      if (fallback != null) {
        total = (double.tryParse(fallback.group(1)!) ?? 0).round();
      }
    }
    return total;
  }

  /// Parse entire response as one string.
  factory Recipe.fromString(String response) {
    response = response.replaceAll("\n\n", "\n").trim();

    // Extract name of the dish (Pasta Carbonara).
    final nameMatch = RegExp(
      r"\*\*Recipe Name:\*\*\s*(.*?)\s*\*\*Summary:",
      dotAll: true,
    ).firstMatch(response);
    final name = cleanText(nameMatch?.group(1) ?? "Unknown Recipe");

    // Extract summary.
    final summaryMatch = RegExp(
      r"\*\*Summary:\*\*\s*(.*?)(?=\s*\*\*(?:Dietary Classification|Yields):)",
      dotAll: true,
    ).firstMatch(response);
    final summary =
        cleanText(summaryMatch?.group(1) ?? "No summary available.");

    // Extract yields aka serving size (how many people).
    final yieldsMatch = RegExp(
      r"\*\*Yields:\*\*\s*(.+?)(?=\n\*\*Prep Time:|\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final yieldsRaw = cleanText(yieldsMatch?.group(1) ?? "Unknown");

    // Extract prep time here.
    final prepTimeMatch = RegExp(
      r"\*\*Prep Time:\*\*\s*(.+?)(?=\n\*\*Cook Time:|\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final prepRaw = cleanText(prepTimeMatch?.group(1) ?? "0 minutes");

    // Extract cook time. To separate it from the prep time
    final cookTimeMatch = RegExp(
      r"\*\*Cook Time:\*\*\s*(.+?)(?=\n\*\*Ingredients:|\n|$)",
      dotAll: true,
    ).firstMatch(response);
    final cookRaw = cleanText(cookTimeMatch?.group(1) ?? "0 minutes");

    // Convert times.
    final prepInt = extractMinutes(prepRaw);
    final cookInt = extractMinutes(cookRaw);
    final totalTimeStr = "${prepInt + cookInt} minutes";

    final prepTimeStr = "$prepInt minutes";
    final cookTimeStr = "$cookInt minutes";

// Extract dietary classification
    final dietMatch = RegExp(
      r"\*\*Dietary Classification:\*\*\s*(.*?)(?=\s*\*\*(?:Yields|Prep Time):)",
      dotAll: true,
    ).firstMatch(response);
    final dietaryClassification = cleanText(dietMatch?.group(1) ?? "Unknown");

    // Extract the ingredients here into a list (as there are multiple)
    final ingredientsMatch = RegExp(
      r"\*\*Ingredients:\*\*(.+?)\*\*Instructions:",
      dotAll: true,
    ).firstMatch(response);
    final ingredients = ingredientsMatch
            ?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith("*"))
            .map((e) => cleanText(e.replaceAll("*", "").trim()))
            .toList() ??
        [];

    // Extract instructions (also list)
    final instructionsMatch = RegExp(
      r"\*\*Instructions:\*\*(.+)",
      dotAll: true,
    ).firstMatch(response);
    final instructions = instructionsMatch
            ?.group(1)
            ?.split("\n")
            .where((line) => line.trim().startsWith(RegExp(r"^\d+\.")))
            .map((e) => cleanText(e.trim()))
            .toList() ??
        [];

    return Recipe(
      name: name,
      summary: summary,
      yields: yieldsRaw,
      prepTime: prepTimeStr,
      cookTime: cookTimeStr,
      totalTime: totalTimeStr,
      ingredients: ingredients,
      instructions: instructions,
      dietaryClassification: dietaryClassification,
    );
  }
}
