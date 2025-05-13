import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopping_list_g11/services/gemini_service.dart';
import 'package:shopping_list_g11/utils/recipe_prompt.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/chat_recipe_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/models/recipe.dart';

/// Controller for handling chat messages and recipe generation using Gemini API
class GeminiController {
  final WidgetRef ref;
  final TextEditingController controller;

  GeminiController({ required this.ref, required this.controller });

  Future<void> sendMessage() async {
    final userMessage = controller.text.trim();
    if (userMessage.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text: userMessage, isUser: true);
    controller.clear();
    ref.read(chatProvider.notifier)
       .sendMessage(text: 'Thinking of recipe...', isUser: false);

    final prompt = buildRecipePrompt(userMessage);
    final rawJson = await geminiRaw(prompt: prompt, query: userMessage);
    String markdown;
  try {
    markdown = extractRecipeText(rawJson);
  } catch (e, st) {
    debugPrint(' Error extracting recipe text: $e\n$st');
    ref.read(chatProvider.notifier).updateLastBotMessage(
      'Something went wrong parsing the recipe. Please try again.'
    );
    return;
  }
    debugPrint('Gemini raw output:\n$markdown');

    final parsed = Recipe.fromString(markdown);
    if (parsed.name.isNotEmpty &&
        parsed.ingredients.isNotEmpty &&
        parsed.instructions.isNotEmpty) {
      ref.read(recipeProvider.notifier).state = parsed;
      ref.read(chatRecipeProvider.notifier).update((_) => parsed);
      ref.read(chatProvider.notifier).updateLastBotMessage(markdown);
    } else {
      debugPrint("Error: Recipe parsing failed.");
      ref.read(chatProvider.notifier)
         .updateLastBotMessage("Something went wrong. Please try again.");
    }
  }
}
