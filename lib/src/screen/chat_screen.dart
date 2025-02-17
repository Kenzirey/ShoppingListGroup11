import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/models/recipe.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

/// Screen for asking AI for a specific recipe.
/// Allows user to save a recipe for later, ask for a new one, or view recipe in recipe screen.
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

  Future<String> _getGeminiResponse(String message) async {
    StringBuffer fullResponseBuffer = StringBuffer();

    // So that the response is predictable, and user doesn't need to specify things.
    String systemPrompt = """
You are an AI assistant that provides recipes. Please structure your response as follows:

**Recipe Name:** [Insert name here]
**Summary:** [Insert brief summary here]
**Yields:** [Insert servings]
**Prep Time:** [Insert time]
**Cook Time:** [Insert time]

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

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    ref
        .read(chatProvider.notifier)
        .sendMessage(text: userMessage, isUser: true);

    _controller.clear();

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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final recipe = ref.watch(recipeProvider);
    final hasRecipe = recipe != null &&
        recipe.name.isNotEmpty &&
        recipe.ingredients.isNotEmpty;

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
                            //temporary
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
                                      const SizedBox(width: 12),
                                      // Circle is now actually round
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
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

            // Show recipe section, temporary setup.
            if (hasRecipe)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.goNamed('recipe');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("View Full Recipe",
                      style: TextStyle(fontSize: 18)),
                ),
              ),

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
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
