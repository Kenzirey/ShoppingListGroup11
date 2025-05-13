import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/providers/meal_suggestions.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/home_screen_provider.dart';
import '../../providers/pantry_items_provider.dart';

/// Home screen for the app.
/// Displays "Expiring Soon" items and "Meal Suggestions" based upon the above items.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch pantry items when the screen is opened
    Future.microtask(() async {
      final currentUser = ref.read(currentUserValueProvider);
      if (currentUser != null && currentUser.profileId != null) {
        await ref
            .read(pantryControllerProvider)
            .fetchPantryItems(currentUser.profileId!);
      }

      final service = ref.read(mealSuggestionServiceProvider);
      final suggestions = await service.suggestionsBasedOnExpiring();
      ref.read(mealSuggestionsProvider.notifier).setSuggestions(suggestions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    // get meal changes:
    final mealSuggestions = ref.watch(mealSuggestionsProvider);
    // Get access to controller methods (add, remove etc)
    final mealNotifier = ref.read(mealSuggestionsProvider.notifier);
    // Get access to the pantry items
    final pantryController = ref.read(pantryControllerProvider);

    final pantryItemsAsync = ref.watch(homeScreenProvider);

    int servingsFromYield(String yields) {
      final m = RegExp(r'\d+').firstMatch(yields);
      return m != null ? int.parse(m.group(0)!) : 1;
    }

    return pantryItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error loading pantry: $err')),
        data: (pantryItems) {
          final expiringItems = pantryItems.where((item) {
            if (item.expirationDate == null) return false;
            final diff = item.expirationDate!.difference(DateTime.now()).inDays;
            return diff >= -4 && diff <= 7;
          }).toList();

          return Scaffold(
            backgroundColor: theme.surface,
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ListView(
                children: [
                  // Title
                  Text(
                    'ShelfAware',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 8),

                  Text('Expiring Soon',
                      style: TextStyle(fontSize: 18, color: theme.tertiary)),
                  const SizedBox(height: 12),

                  if (expiringItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No expiring items within 7 days.',
                        style: TextStyle(color: theme.onSurfaceVariant),
                      ),
                    )
                  else
                    ...expiringItems.map((item) {
                      final diff = item.expirationDate!
                          .difference(DateTime.now())
                          .inDays;
                      final days = diff.toString();
                      final category = item.category?.toLowerCase() ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12), // external spacing
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,

                            background: const SizedBox.shrink(),

                            // keep it same size as the tile itselfbr
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),

                            onDismissed: (_) {
                              final removedItem = item;
                              pantryController.removePantryItem(item.id!);

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  CustomSnackbar.buildSnackBar(
                                    title: 'Removed',
                                    message: '${item.name} removed',
                                    innerPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    actionText: 'Undo',
                                    onAction: () {
                                      pantryController
                                          .addPantryItem(removedItem);
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          CustomSnackbar.buildSnackBar(
                                            title: 'Restored',
                                            message:
                                                '${item.name} restored successfully',
                                            innerPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16),
                                          ),
                                        );
                                    },
                                  ),
                                );
                            },

                            // the tile itself; no internal margin, fixed 56 px height & clipped
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 56),
                              color: theme.primaryContainer,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        PantryIcons(
                                          category: category,
                                          size: 20,
                                          color: theme.tertiary,
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: theme.tertiary,
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: theme.tertiary.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        days,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              theme.tertiary.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // Meal Suggestions section
                  Text('Meal Suggestions',
                      style: TextStyle(fontSize: 18, color: theme.tertiary)),
                  const SizedBox(height: 12),
                  // Fallback if no meal suggestions are available (no expiring items) etc
                  if (mealSuggestions.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No meal suggestions available, no expiring items within 7 days to use!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ...mealSuggestions.asMap().entries.map(
                      (entry) {
                        final idx = entry.key;
                        final recipe = entry.value;
                        final servings = servingsFromYield(recipe.yields);

                        return Dismissible(
                          key: ValueKey(recipe.name),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red, // what color should we use?
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            final removed = recipe;
                            mealNotifier.removeAt(idx);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                CustomSnackbar.buildSnackBar(
                                  title: 'Removed',
                                  message: '${recipe.name} removed',
                                  innerPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  actionText: 'Undo',
                                  onAction: () =>
                                      mealNotifier.insertAt(idx, removed),
                                ),
                              );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: const BoxConstraints(minHeight: 56),
                            child: Material(
                              color: theme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  ref
                                      .read(recipeProvider.notifier)
                                      .update((_) => recipe);
                                  context.goNamed('recipe');
                                },
                                child: Container(
                            constraints: const BoxConstraints(minHeight: 56),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        servings > 1
                                            ? Icons.people
                                            : Icons.person,
                                        size: 20,
                                        color: theme.tertiary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$servings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: theme.tertiary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          
                                          recipe.name,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: theme.tertiary,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        });
  }
}
