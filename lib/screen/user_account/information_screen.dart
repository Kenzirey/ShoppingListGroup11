import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goNamed('accountPage');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Information',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'ShelfAware - May 2025',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version: 1.0',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'About This App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This app was designed by Emma, Sten and Jonas to help reduce food waste, and simplify your meal planning.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Legal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Plan on deleting all user data after grade is registered. ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
