import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information'),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Waste not',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version: ?? :D',
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
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Phasellus id vestibulum neque. Pellentesque habitant morbi '
                'tristique senectus et netus et malesuada fames ac turpis egestas. '
                'Donec ultricies justo sit amet nibh fermentum vulputate.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Email: support@example.com'),
              const SizedBox(height: 16),
              const Text(
                'Legal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Aliquam sodales, massa non viverra sodales, sem elit pharetra '
                'ligula, et fringilla orci purus eu sapien.\n\n'
                'Terms of Service: [Link]\nPrivacy Policy: [Link]',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
