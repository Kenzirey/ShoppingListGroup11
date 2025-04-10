import 'package:flutter/material.dart';
import 'package:shopping_list_g11/models/receipt_data.dart';

/// Screen for displaying the scanned receipt data.
/// This screen is shown after the receipt has been scanned and processed.
class ReceiptDisplayScreen extends StatelessWidget {
  final ReceiptData receiptData;

  const ReceiptDisplayScreen({required this.receiptData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Scanned Receipt',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 8),
              
              // Receipt Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiptData.storeName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${receiptData.date}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...receiptData.items.map((item) {
                        final displayName = item.allergy == null
                            ? item.name
                            : '${item.name} (Allergy: ${item.allergy})';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.tertiary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4), // to keep some distance between the item name and the price section.
                              Text(
                                '${(item.quantity * item.price).toStringAsFixed(2)} kr',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1, color: Colors.black26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${receiptData.total.toStringAsFixed(2)} kr',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
