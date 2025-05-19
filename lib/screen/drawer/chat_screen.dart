import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/controllers/gemini_controller.dart';
import 'package:shopping_list_g11/providers/chat_provider.dart';
import 'package:shopping_list_g11/providers/chat_recipe_provider.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/controllers/saved_recipe_controller.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/providers/saved_recipe_provider.dart';
import 'package:shopping_list_g11/widget/styles/buttons/chat_button_styles.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../controllers/recipe_controller.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // clear if there are no messages so we don't have alien buttons belonging to NOTHING
      final msgs = ref.read(chatProvider).messages;
      if (msgs.isEmpty) {
        ref.read(chatRecipeProvider.notifier).update((_) => null);
      }
    });
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

    final recipe = ref.watch(chatRecipeProvider);

    final hasRecipe = messages.isNotEmpty &&
        !messages.last.isUser &&
        recipe != null &&
        recipe.name.isNotEmpty &&
        recipe.ingredients.isNotEmpty;

    final savedRecipes = ref.watch(savedRecipesProvider);
    final isSaved = recipe != null &&
        savedRecipes.any((sr) => sr.recipe.name == recipe.name);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chat Recipes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
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
                        final msg = messages[messages.length - 1 - index];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: msg.text == 'Thinking of recipe...'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ],
                                  )
                                : Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            if (hasRecipe)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isSaving || isSaved)
                          ? null
                          : () async {
                              final curr = ref.read(chatRecipeProvider)!;
                              final user = ref.watch(currentUserValueProvider);
                              if (user == null) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    CustomSnackbar.buildSnackBar(
                                      title: 'Not Logged In',
                                      message:
                                          'You must be logged in to save a recipe.',
                                    ),
                                  );
                                return;
                              }
                              setState(() => _isSaving = true);
                              await ref
                                  .read(savedRecipesControllerProvider)
                                  .addRecipeByAuthId(user.authId, curr);
                              if (!mounted) return;
                              setState(() => _isSaving = false);
                            },
                      style: ButtonStyles.addForLater(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : isSaved
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Saved',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add for later',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final curr = ref.read(chatRecipeProvider)!;
                        // need to populate the "global" recipe provider that the recipe screen uses here,
                        // fun fact: before I was just reading whatever that it had last, ops.
                        ref.read(recipeProvider.notifier).update((_) => curr);
                        // add the recipe to the database. // or should this be moved to the prompt itself when it has a succcess? hm.
                        await RecipeController(ref: ref).addRecipe(curr);
                        if (!mounted) return;
                        // PUUUSH
                        GoRouter.of(context).pushNamed('recipe');
                      },
                      style: ButtonStyles.viewRecipe(
                        Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Recipe',
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).colorScheme.tertiary,
                        onPressed: () {
                          ref
                              .read(chatRecipeProvider.notifier)
                              .update((_) => null);
                          GeminiController(ref: ref, controller: _controller)
                              .sendMessage();
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                      ref.read(chatRecipeProvider.notifier).update((_) => null);
                      GeminiController(ref: ref, controller: _controller)
                          .sendMessage();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
