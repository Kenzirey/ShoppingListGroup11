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

    final parsedRecipe = Recipe.fromString(newText);
    final newMessages = [...state.messages];

    // Remove the last bot message 
    if (newMessages.isNotEmpty && !newMessages.last.isUser) {
      newMessages.removeLast();
    }

    // If the recipe is valid, display the formatted summary; otherwise, just show the raw text.
    if (parsedRecipe.name.isNotEmpty &&
        parsedRecipe.ingredients.isNotEmpty &&
        parsedRecipe.instructions.isNotEmpty) {
      final summaryText = parsedRecipe.summary;
      newMessages.add(Message(text: summaryText, isUser: false));
      state = ChatState(messages: newMessages, recipe: parsedRecipe);
    } else {
      // Not a valid recipe
      newMessages.add(Message(text: newText, isUser: false));
      state = ChatState(messages: newMessages, recipe: null);
    }
  }
}

/// Chat provider with both messages and parsed recipe.
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
