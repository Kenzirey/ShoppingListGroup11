import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/widget/charts/legend_piechart.dart';
import 'package:shopping_list_g11/widget/charts/spending_line_chart.dart';
import 'package:shopping_list_g11/widget/charts/spending_piechart.dart';

import '../../models/purchase_statistics.dart';
import '../../providers/purchase_statistics_provider.dart';

/// Screen for displaying the purchase habits / statistics of a user.
/// From monthly spent per category, to yearly spending on groceries.
class PurchaseStatistics extends ConsumerStatefulWidget {
  const PurchaseStatistics({super.key});

  @override
  ConsumerState<PurchaseStatistics> createState() => _PurchaseStatisticsState();
}

class _PurchaseStatisticsState extends ConsumerState<PurchaseStatistics> {
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

  // Colors for the line chart.
  final Color mainLineColor = Colors.blue;
  final Color belowLineColor = Colors.green;
  final Color aboveLineColor = Colors.purple.withOpacity(0.7);

  double? _touchedValue;

  @override
  Widget build(BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    final statisticsState = ref.watch(purchaseStatisticsProvider);
    return Scaffold(
      body: statisticsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Error loading data')),
        data: (data) {
          final monthlyData = data['monthlyData'] as MonthlySpending;
          final yearlyData = data['yearlyData'] as YearlySpending;

          // Transform data for pie chart
          final totalAmount = monthlyData.categories.fold(0.0, (sum, cat) => sum + cat.amount);
          final purchaseData = monthlyData.categories
              .map((cat) => {
            'category': cat.name,
            'value': ((cat.amount / totalAmount) * 100).roundToDouble(),
            'color': cat.color,
          }).toList();

          // Transform data for line chart
          final spendingSpots = yearlyData.monthlyAmounts
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
              .toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and header (unchanged)
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

                  // Month picker with reload
                  DropdownButton<int>(
                    isExpanded: true,
                    value: selectedMonth,
                    style: TextStyle(color: tertiaryColor, fontSize: 18),
                    items: List.generate(
                      months.length,
                          (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(months[index]),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedMonth = value;
                          ref.read(purchaseStatisticsProvider.notifier)
                              .loadData(selectedYear, selectedMonth);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // Pie chart
                  PurchaseHabitPieChart(
                    purchaseData: purchaseData,
                    maxSize: 400,
                  ),
                  const SizedBox(height: 2),

                  // Legend
                  PieChartLegend(
                    purchaseData: purchaseData,
                    textColor: tertiaryColor,
                  ),
                  const SizedBox(height: 20),

                  // Yearly data section
                  Text(
                    'Money spent on groceries',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: tertiaryColor,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Year dropdown
                  DropdownButton<int>(
                    isExpanded: true,
                    value: selectedYear,
                    style: TextStyle(color: tertiaryColor, fontSize: 16),
                    items: years
                        .map((year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedYear = value;
                          ref.read(purchaseStatisticsProvider.notifier)
                              .loadData(selectedYear, selectedMonth);
                        });
                      }
                    },
                  ),

                  // Touched value display
                  if (_touchedValue != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Value: ${_touchedValue!.toStringAsFixed(1)}k',
                        style: TextStyle(
                          fontSize: 16,
                          color: mainLineColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Line chart
                  SpendingLineChart(
                    spendingSpots: spendingSpots,
                    mainLineColor: mainLineColor,
                    belowLineColor: belowLineColor,
                    aboveLineColor: aboveLineColor,
                    selectedYear: selectedYear,
                    onValueTouched: (value) {
                      setState(() => _touchedValue = value);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}