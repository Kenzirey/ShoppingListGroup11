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

  Future<String> _getGeminiResponse(String message) async {
    StringBuffer fullResponseBuffer = StringBuffer();
// TODO: set up prompt for lactose and vegan ? or how do we connect it with the kassal.app stuff
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
    [Insert ingredients]

    **Instructions:**
    [Insert step-by-step instructions]

    Ensure that the recipe name is a distinct section, separate from the summary.
    """;

    try {
      await for (var value in Gemini.instance.promptStream(
        parts: [Part.text("$systemPrompt\n\nUser request: $message")],
      )) {
        final textOutput = value?.output ?? "";
        fullResponseBuffer.write(textOutput);
      }

      final fullResponseText = fullResponseBuffer.toString().trim();

      return fullResponseText.isNotEmpty
          ? fullResponseText
          : "Error: No output from Gemini.";
    } catch (exception) {
      debugPrint("Gemini Error: $exception"); //temporary debug

      if (exception.toString().contains("Status Code: 429")) {
        // Should set up user feedback instead of exceptions later on. 429 is the rate exceeded code.
        return "Error: Rate limit exceeded. Please wait and try again.";
      }

      return "Error: Could not get response.";
    }
  }

  /// Handles sending a message to the AI and processing it,
  /// with a temporary message while the request is processing.
  void sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final userMessage = controller.text;
    ref
        .read(chatProvider.notifier)
        .sendMessage(text: userMessage, isUser: true);

    controller.clear();
    // the temporary message while waiting for the full response :)
    ref.read(chatProvider.notifier).sendMessage(
          text: 'Thinking of recipe...',
          isUser: false,
        );

    final geminiResponse = await _getGeminiResponse(userMessage);

    // Parse response into a "Recipe" object.
    final parsedRecipe = Recipe.fromChunks(geminiResponse.split("\n\n"));

    if (parsedRecipe.name.isNotEmpty &&
        parsedRecipe.ingredients.isNotEmpty &&
        parsedRecipe.instructions.isNotEmpty) {
      ref.read(recipeProvider.notifier).state = parsedRecipe;
      ref.read(chatProvider.notifier).updateLastBotMessage(geminiResponse);
    } else {
      debugPrint("Error: Recipe parsing failed.");
    }
  }
}
