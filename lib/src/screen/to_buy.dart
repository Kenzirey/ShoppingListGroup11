import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToBuyScreen extends ConsumerStatefulWidget {
  const ToBuyScreen({super.key});

  @override
  ToBuyState createState() => ToBuyState();
}

class ToBuyState extends ConsumerState<ToBuyScreen> {
  int? _clickedIndex; // Track which item is being clicked

  @override
  Widget build(BuildContext context) {
    final shoppingItems = [
      'Apples',
      'Bananas',
      'Carrots',
      'Eggs',
      'Milk',
      'Bread',
      'Cheese',
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), // ✅ Matches LoginScreen padding
          child: Text(
            'To Buy List',
            style: TextStyle(
              fontSize: 24, // ✅ Matches "Log In" title size
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // ✅ Matches LoginScreen
        child: ListView.builder(
          itemCount: shoppingItems.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_grocery_store, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shoppingItems[index],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200), // ✅ Smooth animation
                        decoration: BoxDecoration(
                          color: _clickedIndex == index
                              ? Colors.red.withOpacity(0.2) // ✅ Background turns red when clicked
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _clickedIndex = index;
                            });

                            // TODO: Implement delete logic here

                            // Reset after delay for feedback effect
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (mounted) {
                                setState(() {
                                  _clickedIndex = null;
                                });
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.delete,
                              color: _clickedIndex == index
                                  ? Colors.red // ✅ Icon turns red when clicked
                                  : Theme.of(context).colorScheme.tertiary, // ✅ Default color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}
