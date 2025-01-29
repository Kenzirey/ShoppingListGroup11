import 'package:flutter/material.dart';

/// Home screen for the app.
/// Items about to expire is visible, Work in progress.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Expiring Soon
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'About to expire',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Item 2',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary,
                      fontSize: 16),
                ),
              ),
            ),

            /// Shopping List
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Shopping List',
                  style: TextStyle(color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}