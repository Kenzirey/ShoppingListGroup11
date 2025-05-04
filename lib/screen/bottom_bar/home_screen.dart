import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/providers/meal_suggestions.dart';
import 'package:shopping_list_g11/providers/recipe_provider.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import 'package:shopping_list_g11/widget/user_feedback/regular_custom_snackbar.dart';
import '../../providers/home_screen_provider.dart';

/// Home screen for the app.
/// Displays "Expiring Soon" items and "Meal Suggestions" upon the above items.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Trigger a refresh once when the screen is created (so we can get the suggestions)
    Future.microtask(() async {
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
    final pantryItemsAsync = ref.watch(homeScreenProvider);
    int servingsFromYield(String yields) {
      final m = RegExp(r'\d+').firstMatch(yields);
      return m != null ? int.parse(m.group(0)!) : 1;
    }

    return pantryItemsAsync.when(
        loading: () => Scaffold(
              backgroundColor: theme.surface,
              body: const Center(child: CircularProgressIndicator()),
            ),
        error: (error, stack) => Scaffold(
              backgroundColor: theme.surface,
              body: Center(child: Text('Error loading items: $error')),
            ),
        data: (pantryItems) {
          final expiringItems = pantryItems.where((item) {
            if (item.expirationDate == null) return false;
            final diff = item.expirationDate!.difference(DateTime.now()).inDays;
            return diff >= -4 &&
                diff <= 7; // 7 days before and 4 days after expiration
          }).map((item) {
            final diff = item.expirationDate!.difference(DateTime.now()).inDays;
            return {
              'name': item.name,
              'days': diff.toString(),
              'category': item.category?.toLowerCase(),
              'id': item.id ?? '',
            };
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
                  ...expiringItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rec = entry.value;
                    final name = rec['name']!;
                    final days = rec['days']!;
                    final category = rec['category']!;

                    return Dismissible(
                      key: ValueKey(name),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                              8), // match tile border type
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        final removed = expiringItems[index];
                        setState(() => expiringItems.removeAt(index));
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            CustomSnackbar.buildSnackBar(
                              title: 'Removed',
                              message: '$name removed',
                              innerPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              actionText: 'Undo',
                              onAction: () {
                                setState(
                                    () => expiringItems.insert(index, removed));
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    CustomSnackbar.buildSnackBar(
                                      title: 'Restored',
                                      message: '$name restored successfully',
                                      innerPadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                  );
                              },
                            ),
                          );
                      },
                      child: Container(
                        height: 56, // ⬅️ consistent tile height
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: theme.tertiary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 20,
                                    color: theme.tertiary.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  days,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.tertiary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                            height: 56,
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
                                  height: 56,
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: theme.tertiary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
