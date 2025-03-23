import 'package:flutter/material.dart';

/// Shows the purchase history of the user, separated by month.
class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  // Dummy items
  final List<String> shoppingItems = [
    'Apples',
    'Bananas',
    'Carrots',
    'Eggs',
    'Milk',
    'Bread',
    'Cheese',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manually set Month, will be made dynamic later.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement sort or filter toggle logic
                  },
                  icon: Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56.0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120.0),
                  itemCount: shoppingItems.length,
                  itemBuilder: (context, index) {
                    final item = shoppingItems[index];

                    // Example "quantity" and "price" placeholders
                    // Manually written, will be replaced with dynamic values.
                    final quantity = (index % 2 == 0) ? '500g' : '5';
                    const price = 500;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_grocery_store,
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Item name (top) + quantity (bottom) (temporary)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: $quantity',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price to the very right
                          Text(
                            '$price NOK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
