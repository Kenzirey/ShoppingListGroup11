import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/widget/charts/legend_piechart.dart';
import 'package:shopping_list_g11/widget/charts/spending_piechart.dart';

/// Screen for displaying the purchase habits / statistics of a user.
class PurchaseStatistics extends ConsumerStatefulWidget {
  const PurchaseStatistics({super.key});

  @override
  ConsumerState<PurchaseStatistics> createState() => _PurchaseStatisticsState();
}

class _PurchaseStatisticsState extends ConsumerState<PurchaseStatistics> {
  // TEMPORARY DUMMY DATA for Pie Chart.
  final List<Map<String, dynamic>> purchaseData = [
    {'category': 'Romsdaling shenanigans', 'value': 69.0, 'color': Colors.blue},
    {'category': 'Laks', 'value': 15.0, 'color': Colors.green},
    {'category': 'Barneting', 'value': 8.0, 'color': Colors.orange},
    {'category': 'Honning', 'value': 8.0, 'color': Colors.purple},
  ];

  // Dropdowns for month/year.
  int selectedMonth = DateTime.now().month - 1; // zero-based index.
  int selectedYear = DateTime.now().year;

  final List<String> months = List<String>.generate(
    12,
    (index) => DateFormat('MMMM', 'en_US').format(DateTime(2000, index + 1)),
  );
  final List<int> years = List<int>.generate(
    DateTime.now().year - 2020 + 1,
    (index) => 2020 + index,
  );

  @override
  Widget build(BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Purchase Habits',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: tertiaryColor,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Month dropdown section here.
              DropdownButton<int>(
                isExpanded: true,
                value: selectedMonth,
                style: TextStyle(color: tertiaryColor, fontSize: 18),
                items: List.generate(
                  months.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(months[index]),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMonth = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              // Pie chart section.
              PurchaseHabitPieChart(
                purchaseData: purchaseData,
                maxSize: 400, // Absolute maximum size for the chart, to restrict if for example table or the like.
              ),
              const SizedBox(height: 2),
              // Legend.
              PieChartLegend(
                purchaseData: purchaseData,
                textColor: tertiaryColor,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}