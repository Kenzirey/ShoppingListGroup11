import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/providers/current_user_provider.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';

/// Left-side drawer widget for the app.
class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserValueProvider);
    final router = GoRouter.of(context);
    return SizedBox(
      width: 240,
      child: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(height: 40),

              // If no user, show Log in or sign up
              if (currentUser == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () {
                      final target = router.namedLocation('loginPage');
                      if (GoRouterState.of(context).uri.toString() != target) {
                        Navigator.of(context).pop();
                        context.goNamed('loginPage');
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Log in or sign up',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // If user IS logged in, show clickable avatar + name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goNamed('accountPage');
                    },
                    child: Row(
                      children: [
                        if (currentUser.avatarUrl?.isNotEmpty == true)
                          CircleAvatar(
                            backgroundImage:
                                currentUser.avatarUrl!.startsWith('assets/')
                                    ? AssetImage(currentUser.avatarUrl!)
                                        as ImageProvider
                                    : NetworkImage(currentUser.avatarUrl!),
                            radius: 18,
                          )
                        else
                          Icon(
                            Icons.account_circle,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 36,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          currentUser.name.isEmpty
                              ? 'No Name'
                              : currentUser.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Filter
              ListTile(
                leading: PantryIcons(
                  category:
                      'statistics',
                  size: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  'Statistics',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  true; // Mark navigation as from the drawer
                  context.goNamed('purchaseStatistics');
                },
              ),
              ListTile(
                leading: PantryIcons(
                  category:
                      'meal_planner',
                  size: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  'Meal Planner',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  final target = router.namedLocation('mealPlanner');
                  if (GoRouterState.of(context).uri.toString() != target) {
                    Navigator.of(context).pop();
                    context.goNamed('mealPlanner');
                  }
                },
              ),
              // Shopping suggestions (based on user purchase habits)
              ListTile(
                leading: PantryIcons(
                  category:
                      'shopping',
                  size: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  'Shopping Suggestions',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  final target = router.namedLocation('shoppingSuggestions');
                  if (GoRouterState.of(context).uri.toString() != target) {
                    Navigator.of(context).pop();
                    context.goNamed('shoppingSuggestions');
                  }
                },
              ),
              // Current stock of pantry items
              ListTile(
                leading: PantryIcons(
                  category:
                      'pantry',
                  size: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  'Pantry',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  final target = router.namedLocation('pantry');
                  if (GoRouterState.of(context).uri.toString() != target) {
                    Navigator.of(context).pop();
                    context.goNamed('pantry');
                  }
                },
              ),

              // Saved recipes
              ListTile(
                leading: PantryIcons(
                  category:
                      'recipes',
                  size: 24,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  'Saved Recipes',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  final target = router.namedLocation('savedRecipes');
                  if (GoRouterState.of(context).uri.toString() != target) {
                    Navigator.of(context).pop();
                    context.goNamed('savedRecipes');
                  }
                },
              ),

              // Chat
              ListTile(
                leading: Icon(Icons.chat,
                    color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Chat',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  true; // Mark navigation as from the drawer
                  context.goNamed('chat');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
