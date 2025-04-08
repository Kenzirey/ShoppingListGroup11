import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
// Based on https://github.com/imaNNeo/fl_chart/blob/main/example/lib/presentation/samples/line/line_chart_sample4.dart
/// A widget for displaying a line chart with gesture feedback.
///
/// This widget builds the chart using [FlChart] and uses the provided
/// [spendingSpots] data along with styling properties to render the chart.
class SpendingHabitLineChart extends StatelessWidget {
  final List<FlSpot> spendingSpots;
  final Color mainLineColor;
  final Color belowLineColor;
  final Color aboveLineColor;
  final int selectedYear;

  const SpendingHabitLineChart({
    super.key,
    required this.spendingSpots,
    required this.mainLineColor,
    required this.belowLineColor,
    required this.aboveLineColor,
    required this.selectedYear,
  });

  /// the bottom widget part with the titles of each category (with color).
  Widget lineBottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) return Container();
    final month = DateTime(2000, value.toInt() + 1);
    final text = DateFormat('MMM', 'en_US').format(month);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: mainLineColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Left side which shows values for Y-axis.
  Widget lineLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 12);
    if (value == 0 || value % 5 != 0) return Container();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value.toInt()}k', style: style),
    );
  }

  /// Calculate how much space left the left title has.
  double _calculateLeftReservedSize() {
    // THese labels need to be made dynamic later.
    final List<String> labels = ['5k', '10k', '15k', '20k', '25k'];
    double maxWidth = 0;
    const TextStyle style = TextStyle(color: Colors.grey, fontSize: 12);
    for (String label in labels) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: ui.TextDirection.ltr,
      );
      tp.layout();
      if (tp.width > maxWidth) {
        maxWidth = tp.width;
      }
    }
    return maxWidth + 8;
  }

  /// Generates the chart configuration used by [LineChart].
  LineChartData getLineChartData(BuildContext context) {
    const double cutOffYValue = 15.0;
    return LineChartData(
      minX: 0,
      maxX: 11,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tooltipMargin: 24,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipHorizontalOffset: 0,
          maxContentWidth: 120,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.y.toStringAsFixed(1)}k',
                TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
          getTooltipColor: (LineBarSpot touchedSpot) =>
              Theme.of(context).colorScheme.primaryContainer,
          fitInsideHorizontally: false,
          fitInsideVertically: false,
          showOnTopOfTheChartBoxArea: false,
          rotateAngle: 0.0,
          tooltipBorder: BorderSide.none,
        ),
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((int index) {
            return TouchedSpotIndicatorData(
              FlLine(color: mainLineColor, strokeWidth: 2),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: mainLineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spendingSpots,
          isCurved: true,
          barWidth: 8,
          color: mainLineColor,
          belowBarData: BarAreaData(
            show: true,
            color: belowLineColor,
            cutOffY: cutOffYValue,
            applyCutOffY: true,
          ),
          aboveBarData: BarAreaData(
            show: true,
            color: aboveLineColor,
            cutOffY: cutOffYValue,
            applyCutOffY: true,
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
      minY: 0,
      maxY: 25,
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          axisNameWidget: Text(
            selectedYear.toString(),
            style: TextStyle(
              fontSize: 14,
              color: mainLineColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: lineBottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: _calculateLeftReservedSize(),
            getTitlesWidget: lineLeftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5, // how tall it is compared to wide etc
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 22, bottom: 12), // added some to allow "dec" to actually be shown.
        child: LineChart(getLineChartData(context)),
      ),
    );
  }
}