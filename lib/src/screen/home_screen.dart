import 'package:flutter/material.dart';

/// Home screen for the app.
/// Displays "Expiring Soon" items and "Meal Suggestions" upon the above items.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  // THese are only temporary for testing and showing the ui look.
  final Map<String, String> expiringItems = {
    'Milk': '2 days',
    'Cheese': '3 days',
    'Yogurt': '5 days',
  };

  final List<String> mealSuggestions = [
    'Pasta with tomato sauce',
    'Grilled cheese sandwich',
    'Vegetable stir-fry',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Expiring Soon Section**
            Text(
              'Expiring Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: expiringItems.length,
                itemBuilder: (context, index) {
                  final item = expiringItems.keys.elementAt(index);
                  final expiryTime = expiringItems[item];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color:
                          Colors.red.withOpacity(0.2), // Red-tinted background, need to tweak this.
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Icon & Item Name (Left)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.warning,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  item, // (the item name here due to index)
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expiration Time (Right)
                        Text(
                          expiryTime ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Meal Suggestions section, to suggest meals based on the stuff expiring above.
            const SizedBox(height: 16),
            Text(
              'Meal Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32.0),
                itemCount: mealSuggestions.length,
                itemBuilder: (context, index) {
                  final meal = mealSuggestions[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant,
                            size: 20,
                            color: Theme.of(context).colorScheme.tertiary),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            meal,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
