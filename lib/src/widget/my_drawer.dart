import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_g11/routes/routes.dart';

/// Drawer widget for the app.
class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(height: 40),

              // Login / Sign-up row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    AppRouter.isDrawerNavigation = true; // Mark navigation as from the drawer
                    context.goNamed('loginPage');
                    AppRouter.isDrawerNavigation = false; // Reset after navigation
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
              ),

              const SizedBox(height: 20),

              // Filter
              ListTile(
                leading: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Filter',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {},
              ),

              // Wishlist
              ListTile(
                leading: Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Wishlist',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {},
              ),

              // Chat
              ListTile(
                leading: Icon(Icons.chat, color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Chat',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  AppRouter.isDrawerNavigation = true; // Mark navigation as from the drawer
                  context.goNamed('chat');
                  AppRouter.isDrawerNavigation = false;
                },
              ),

              // Meal planner
              ListTile(
                leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Meal planner',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  AppRouter.isDrawerNavigation = true;
                  context.goNamed('mealPlanner');
                  AppRouter.isDrawerNavigation = false;
                },
              ),

              // Scan Receipt
              ListTile(
                leading: Icon(Icons.receipt, color: Theme.of(context).colorScheme.tertiary),
                title: Text(
                  'Scan Receipt',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  AppRouter.isDrawerNavigation = true;
                  context.goNamed('scanReceipt');
                  AppRouter.isDrawerNavigation = false;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
