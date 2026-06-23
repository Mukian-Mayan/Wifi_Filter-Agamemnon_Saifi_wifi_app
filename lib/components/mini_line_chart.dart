import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme.dart';

class MiniLineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final bool showAxis;
  const MiniLineChart({
    super.key,
    required this.data,
    this.color = AppColors.cyan,
    this.height = 120,
    this.showAxis = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('No data yet', style: AppText.label(p.textDim))),
      );
    }
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.2).clamp(1, double.infinity).toDouble();
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: showAxis,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: showAxis,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showAxis,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: AppText.micro(p.textDim)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2.6,
              color: color,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.32), color.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
