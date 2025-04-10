import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';

/// Controller for handling user-interaction with the Gemini Api.
class GeminiController {
  final WidgetRef ref;
  final TextEditingController controller;

  GeminiController({required this.ref, required this.controller});

  /// Makes a single, non-streaming prompt call to Gemini, returning the entire response at once.
  Future<String> _getGeminiResponse(String message) async {
    //TODO: set up more guards for users
    // So that the response is predictable, and user doesn't need to specify things.
    String systemPrompt = """
    You are an AI assistant that provides recipes. Please use the metric system.
    Please structure your response as follows:

    **Recipe Name:** [Insert name here]
    **Summary:** [Insert brief summary here]
    **Yields:** [Insert servings]
    **Prep Time:** [Insert the time used for all tasks before the cooking process begins (e.g., chopping, marinating, gathering ingredients)]
    **Cook Time:** [Insert the time from when the dish starts cooking until it is fully done]
    **Total Time:** [Automatically calculate as Prep Time + Cook Time]

    **Ingredients:**
    [Insert ingredients],

    **Instructions:**
    [Insert step-by-step instructions]

    Ensure that the recipe name is a distinct section, separate from the summary.
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
      ref.read(chatProvider.notifier).updateLastBotMessage(geminiResponse);
    } else {
      debugPrint("Error: Recipe parsing failed.");
      // update the temporary message with an error message.
      ref
          .read(chatProvider.notifier)
          .updateLastBotMessage("Something went wrong. Please try asking for a new recipe.");
    }
  }
}
