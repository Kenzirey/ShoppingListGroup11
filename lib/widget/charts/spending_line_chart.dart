import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SpendingLineChart extends StatelessWidget {
  final List<FlSpot> spendingSpots;
  final Color mainLineColor;
  final Color belowLineColor;
  final Color aboveLineColor;
  final int selectedYear;
  final Function(double)? onValueTouched;

  const SpendingLineChart({
    super.key,
    required this.spendingSpots,
    required this.mainLineColor,
    required this.belowLineColor,
    required this.aboveLineColor,
    required this.selectedYear,
    this.onValueTouched,
  });

  /// Get appropriate interval based on data range
  double get _yAxisInterval {
    double maxValue = 0;
    for (var spot in spendingSpots) {
      if (spot.y > maxValue) maxValue = spot.y;
    }

    if (maxValue <= 10) return 2.0;
    if (maxValue <= 20) return 5.0;
    if (maxValue <= 50) return 10.0;
    return 20.0;
  }

  /// Get maximum Y value rounded to nearest interval
  double get _maxY {
    double maxValue = 0;
    for (var spot in spendingSpots) {
      if (spot.y > maxValue) maxValue = spot.y;
    }

    return ((maxValue / _yAxisInterval).ceil() * _yAxisInterval);
  }

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

  Widget lineLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 12);

    // More reliable check for showing labels at intervals
    if (value == 0) return Container();

    // Round to nearest 0.1 to avoid floating point issues
    final roundedValue = (value * 10).round() / 10;
    final roundedInterval = (_yAxisInterval * 10).round() / 10;

    // Only show labels at interval points
    if ((roundedValue % roundedInterval).abs() > 0.01) return Container();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value.toInt()}k', style: style),
    );
  }

  double _calculateLeftReservedSize() {
    // Generate labels based on interval
    final roundedMax = _maxY.toInt();
    final interval = _yAxisInterval.toInt();

    final List<String> labels = [];
    for (int i = 0; i <= roundedMax; i += interval) {
      if (i > 0) {  // Skip zero
        labels.add('${i}k');
      }
    }

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

  LineChartData getLineChartData(BuildContext context) {
    final double cutOffYValue = _maxY / 2;

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
              if (onValueTouched != null) {
                onValueTouched!(touchedSpot.y);
              }
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
      maxY: _maxY,
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
            interval: _yAxisInterval,
            reservedSize: _calculateLeftReservedSize(),
            getTitlesWidget: lineLeftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _yAxisInterval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 22, bottom: 12),
        child: LineChart(getLineChartData(context)),
      ),
    );
  }
}