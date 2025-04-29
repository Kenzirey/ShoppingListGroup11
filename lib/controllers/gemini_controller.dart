import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shopping_list_g11/main.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/chat_recipe_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';

/// Controller for handling user-interaction with the Gemini Api.
class GeminiController {
  final WidgetRef ref;
  final TextEditingController controller;

  GeminiController({required this.ref, required this.controller});

  /// Makes a single, non-streaming prompt call to Gemini, returning the entire response at once.
  Future<String> _getGeminiResponse(String message) async {
    String systemPrompt = """
    You are an AI assistant that provides recipes. Please use the metric system.
    Please structure your response as follows:

    **Recipe Name:** [Insert name here]  
    **Summary:** [Insert brief summary here]  
    **Dietary Classification:** [Vegetarian | Vegan | Non-vegetarian]  
    **Yields:** [Insert servings]  
    **Prep Time:** [Insert the time used for all tasks before the cooking process begins (e.g., chopping, marinating, gathering ingredients)]  
    **Cook Time:** [Insert the time from when the dish starts cooking until it is fully done]  
    **Total Time:** [Automatically calculate as Prep Time + Cook Time]

    **Ingredients:**
    [Insert ingredients],

    **Instructions:**
    [Insert step-by-step instructions]

    **Guidelines for Dietary Classification:**  
    - **Vegan:** No animal-derived ingredients (no dairy, eggs, honey, etc.).  
    - **Vegetarian:** May include dairy and/or eggs, but no meat, poultry, fish, or seafood.  
    - **Non-vegetarian:** Includes meat, poultry, fish, or seafood.

    Ensure that the recipe name is a distinct section, separate from the summary.
    When writing the **Instructions**, always restate each ingredient with its exact amount as you listed it (e.g., “Combine 250 ml water and a pinch of salt with the oats”).
    Do not assume the user knows any quantities beyond what you listed in the **Ingredients** section.
    When grouping ingredients into sub sections, always prefix the subgroup with “For the [subgroup name]:” (including the colon), then list its ingredients with “* ” bullets.
    """;

    try {
      final result = await Gemini.instance.prompt(
        parts: [
          Part.text("$systemPrompt\n\nUser request: $message"),
        ],
      );

      final fullResponse = result?.output ?? "";
      if (fullResponse.trim().isEmpty) {
        return "Error: No output from Gemini.";
      }
      debugPrint("Gemini Response: $fullResponse");
      return fullResponse.trim();
    } catch (exception) {
      debugPrint("Gemini Error: $exception");
      if (exception.toString().contains("Status Code: 429")) {
        return "Error: Rate limit exceeded. Please wait and try again.";
      }
      return "Error: Could not get response.";
    }
  }

  /// Sends a message to Gemini, gets the entire result at once, then parses.
  void sendMessage() async {
    // If user typed nothing, do nothing.
    if (controller.text.trim().isEmpty) return;

    final userMessage = controller.text;
    ref.read(chatProvider.notifier).sendMessage(
          text: userMessage,
          isUser: true,
        );
    controller.clear();

    // Temporary message while waiting
    ref.read(chatProvider.notifier).sendMessage(
          text: 'Thinking of recipe...',
          isUser: false,
        );

    // then parse it via the factory method
    final geminiResponse = await _getGeminiResponse(userMessage);
    final parsedRecipe = Recipe.fromString(geminiResponse);

    // only store it if it is valid
    if (parsedRecipe.name.isNotEmpty &&
        parsedRecipe.ingredients.isNotEmpty &&
        parsedRecipe.instructions.isNotEmpty) {
      ref.read(recipeProvider.notifier).state = parsedRecipe;
      ref.read(chatRecipeProvider.notifier).update((_) => parsedRecipe);
      ref.read(chatProvider.notifier).updateLastBotMessage(geminiResponse);
    } else {
      debugPrint("Error: Recipe parsing failed.");
      // update the temporary message with an error message.
      ref.read(chatProvider.notifier).updateLastBotMessage(
          "Something went wrong. Please try asking for a new recipe.");
    }
  }

  /// Fetches (currently all) receipt items (products) from the database, and sends them to Gemini for categorization.
  /// Returns a json array of objects, where each object has 'name', 'category', and 'type' keys.
  /// Where Category is the main product category (e.g., dry food, dairy, frozen meats) and the specific product type (e.g., milk, yogurt, chicken breast).
  /// Will be replaced later with a different type of product fetch.
  Future<List<Map<String, dynamic>>> processProducts() async {
    final response = await supabase.from('receipt_items').select('name');
    try {
      if (response.isEmpty) {
        debugPrint("No products found in the database.");
        return [];
      }

      List<String> productNames =
          response.map((item) => item['name'] as String).toList();

      if (productNames.isEmpty) {
        return [];
      }

      // Enclose product names in quotes, as some items in database has , in the name, which confused Gemini.
      List<String> quotedNames = productNames.map((name) => '"$name"').toList();

      final prompt = """
        Categorize the following product names. Provide the main product category (e.g., dry food, dairy, frozen meats) and the specific product type (e.g., milk, yogurt, chicken breast). 
        Also add what sort of storage typing it has, from these 3 storage types (fridge, freezer, dry storage)
        Return the response as a JSON array of objects, where each object has 'name', 'category', 'type', 'storage' keys.

        Products: ${quotedNames.join(", ")}

        JSON Response:
      """;

      debugPrint("Gemini Prompt: $prompt");

      final result = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      String? text = result?.output;

      debugPrint("Gemini Response Text: $text");

      if (text != null) {
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();

        try {
          List<dynamic> jsonResponse = jsonDecode(text);

          debugPrint("Parsed JSON Response: $jsonResponse");

          return jsonResponse.cast<Map<String, dynamic>>();
        } catch (e) {
          debugPrint('Error parsing Gemini JSON: $e, text: $text');
          return [];
        }
      } else {
        debugPrint("Gemini returned null response :().");
        return [];
      }
    } catch (e) {
      debugPrint('Error processing products: $e');
      return [];
    }
  }
}
