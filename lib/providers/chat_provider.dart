import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/message.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:flutter/material.dart';

/// Holds both chat messages and parsed recipe.
class ChatState {
  final List<Message> messages;
  final Recipe? recipe;

  ChatState({required this.messages, this.recipe});
}

/// StateNotifier to manage chat messages and recipe.
/// TODO: create a separate service/controller for this.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: []));

  /// Adds user or bot message.
  void sendMessage({required String text, required bool isUser}) {
    state = ChatState(
      messages: [...state.messages, Message(text: text, isUser: isUser)],
      recipe: state.recipe, // save the existing recipe.
    );
  }

  /// Updates the last bot message, attempt to parse a recipe.
  void updateLastBotMessage(String newText) {
    List<String> chunks = newText.split("\n\n");

    final parsedRecipe = Recipe.fromChunks(chunks);

    if (parsedRecipe.name.isEmpty ||
        parsedRecipe.ingredients.isEmpty ||
        parsedRecipe.instructions.isEmpty) {
      debugPrint("⚠️ Error: Parsed recipe is missing critical data.");
      return;
    }

    final summaryText = parsedRecipe
        .summary; // As we only want the summary shown in the chat screen.

    final newMessages = [...state.messages];

    if (newMessages.isNotEmpty && !newMessages.last.isUser) {
      newMessages.removeLast();
    }

    newMessages.add(Message(text: summaryText, isUser: false));

    state = ChatState(messages: newMessages, recipe: parsedRecipe);
  }
}

/// Chat provider with both messages and parsed recipe.
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
