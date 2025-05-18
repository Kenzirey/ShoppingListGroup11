import 'package:flutter/material.dart';

/// A widget for displaying a legend for a pie chart, showing the categories, amounts, and percentages.
class PieChartLegend extends StatelessWidget {
  final List<Map<String, dynamic>> purchaseData;
  final Color textColor;

  const PieChartLegend({
    super.key,
    required this.purchaseData,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: purchaseData.map((data) {
        final amount = data['amount'] as double?;
        final percentage = data['value'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: data['color'],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['category'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              const SizedBox(width: 8),
              if (amount != null) ...[
                Text(
                  "${amount.toStringAsFixed(2)} kr",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '|',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                "$percentage%",
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}