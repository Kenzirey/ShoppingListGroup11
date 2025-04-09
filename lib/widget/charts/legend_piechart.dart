import 'package:flutter/material.dart';

/// A widget for displaying a legend for a pie chart, showing the categories and their corresponding values.
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
              Text(
                "${data['value']}%",
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}