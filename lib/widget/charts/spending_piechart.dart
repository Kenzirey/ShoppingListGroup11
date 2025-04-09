import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A widget that displays a pie chart representing purchase habits.
/// Dynamically generates sections based on the provided purchase data.
/// Colored box, category text and percentages are displayed.
class PurchaseHabitPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> purchaseData;
  // Maximum size in pixels (default is 400).
  final double maxSize;

  const PurchaseHabitPieChart({
    super.key,
    required this.purchaseData,
    this.maxSize = 400,
  });

  @override
  _PurchaseHabitPieChartState createState() => _PurchaseHabitPieChartState();
}

class _PurchaseHabitPieChartState extends State<PurchaseHabitPieChart> {
  int touchedIndex = -1;

  // Use the passed-in baseRadius to calculate section sizes, for "dynamic" sizing.
  List<PieChartSectionData> getSections(double baseRadius) {
    return List.generate(widget.purchaseData.length, (i) {
      final data = widget.purchaseData[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? baseRadius * 0.22 : baseRadius * 0.18;
      final radius = isTouched ? baseRadius * 1.1 : baseRadius;
      return PieChartSectionData(
        value: data['value'],
        color: data['color'],
        title: "${data['value']}%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.tertiary, // text
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 20;
        // Clamp to widget.maxSize
        final chartSize = availableWidth.clamp(0.0, widget.maxSize);
        final baseRadius = chartSize * 0.38;
        final dynamicSections = getSections(baseRadius);
        final dynamicPieChartData = PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: dynamicSections,
        );

        return Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: PieChart(dynamicPieChartData),
          ),
        );
      },
    );
  }
}