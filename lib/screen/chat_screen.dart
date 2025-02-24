import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_g11/controllers/gemini_controller.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/widget/styles/chat_button_styles.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/saved_recipe_controller.dart';
import '../models/saved_recipe.dart';
import '../providers/current_user_provider.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // TODO: make sure user is actually logged in, user feedback / checks.
                        final currentRecipe = ref.read(recipeProvider);
                        final currentUser = ref.read(currentUserProvider);
                        final router = GoRouter.of(context);
                        if (currentRecipe != null) {
                          await RecipeController(ref: ref)
                              .addRecipe(currentRecipe);
                        }
                        if (currentRecipe != null && currentUser != null) {
                          final savedRecipe = SavedRecipe(
                              recipe: currentRecipe,
                              userId: currentUser.authId);
                          SavedRecipesController(ref: ref)
                              .addRecipe(savedRecipe);
                        }
                        if (!mounted) return;
                        router.goNamed('savedRecipes');
                      },
                      style: ButtonStyles.addForLater(
                          Theme.of(context).colorScheme.primaryContainer),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              size: 20,
                              color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            "Add for later",
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                      width:
                          16), // Space between the buttons above the textform
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // to not use context in async gap with unrelated mount check :).
                        final router = GoRouter.of(context);
                        final currentRecipe = ref.read(recipeProvider);
                        if (currentRecipe != null) {
                          await RecipeController(ref: ref)
                              .addRecipe(currentRecipe);
                        }
                        if (!mounted) return;
                        router.goNamed('recipe');
                      },
                      style: ButtonStyles.viewRecipe(
                          Theme.of(context).colorScheme.primaryContainer),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant_menu,
                              size: 20,
                              color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Text(
                            "View Recipe",
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            Row(
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
                        onPressed: () =>
                            GeminiController(ref: ref, controller: _controller)
                                .sendMessage(),
                      ),
                    ),
                    onSubmitted: (_) =>
                        GeminiController(ref: ref, controller: _controller)
                            .sendMessage(),
                  ),
                ),
              ],
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
