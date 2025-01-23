import 'package:flutter/material.dart';

/// Drawer widget for the app.
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.account_circle, color: Theme.of(context).colorScheme.tertiary,
                      size: 36),
                  const SizedBox(width: 12),
                  Text(
                    'Log in or sign up',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.tertiary),
              title: Text('Filter', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
              onTap: () {
              },
            ),

            ListTile(
              leading: Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary),
              title: Text('Wishlist', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
              onTap: () {
              },
            ),

            ListTile(
              leading: Icon(Icons.chat, color: Theme.of(context).colorScheme.tertiary),
              title: Text('Chat', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
              onTap: () {
              },
            ),

            ListTile(
              leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.tertiary),
              title: Text('Meal planner', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
