import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

/// Screen for asking AI for a specific recipe.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Debugs and prints are there until I have parsing complete.
  Future<String> _getGeminiResponse(String message) async {
    String geminiResponse = 'Error: Could not get response.';
    try {
      String fullResponseText = ""; // To save the entire response into one String.
      await Gemini.instance.promptStream(
        parts: [
          Part.text(message),
        ],
      ).listen((value) {
        debugPrint('--- Stream Value BELOW: ---');
        //print(value); // print entire object
        debugPrint('Output: ${value?.output}');
        fullResponseText += value?.output ?? ''; // append full response
      }).asFuture();

      geminiResponse = fullResponseText.isNotEmpty
          ? fullResponseText
          : 'Error: No output from Gemini.';
      debugPrint(
          '--- Final _getGeminiResponse: ---');
      debugPrint(geminiResponse); // final response.
      return geminiResponse;
    } catch (exception) {
      debugPrint('Gemini Error: $exception');
      return 'Error: Could not get response.';
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    ref
        .read(chatProvider.notifier)
        .sendMessage(text: userMessage, isUser: true);

    _controller.clear();

    // Placeholder "Thinking of recipe..." message to give user visual feedback that request is being processed.
    ref.read(chatProvider.notifier).sendMessage(
          text: 'Thinking of recipe...',
          isUser: false,
        );

    // Fetch Gemini Response
    final geminiResponse = await _getGeminiResponse(userMessage);

    // Replace placeholder with the actual response.
    ref.read(chatProvider.notifier).updateLastBotMessage(geminiResponse);

    // Scroll to the new msg
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hello User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ask chat for a recipe',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? Colors.blue
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: message.text == 'Thinking of recipe...'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ],
                                  )
                                : Text(
                                    message.text,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        // Send button inside textfield
                        // https://api.flutter.dev/flutter/material/InputDecoration/suffixIcon.html
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).colorScheme.tertiary,
                          onPressed: _sendMessage,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
            // adds distance between bottom nav bar and the text field.
            const SizedBox(height: 12,),
          ],
        ),
      ),
    );
  }
}
