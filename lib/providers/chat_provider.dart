import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/message.dart';

/// StateNotifier to manage the list of messages from message bot.
/// TODO: move this to a controller?
class ChatNotifier extends StateNotifier<List<Message>> {
  ChatNotifier() : super([]);

  /// Handle user and bot messages.
  void sendMessage({required String text, required bool isUser}) {
    state = [...state, Message(text: text, isUser: isUser)];
  }

  void updateLastBotMessage(String newText) {
    if (state.isNotEmpty && !state.last.isUser) {
      state = [
        ...state.sublist(0, state.length - 1),
        Message(text: newText, isUser: false),
      ];
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) => ChatNotifier());