import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models.dart';
import 'theme.dart';

class MetricRadar extends StatelessWidget {
  final MetricSet metrics;
  const MetricRadar({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return AspectRatio(
      aspectRatio: 1.15,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.cyan.withOpacity(0.22),
              borderColor: AppColors.cyan,
              borderWidth: 2,
              entryRadius: 2.5,
              dataEntries: metrics.asList.map((v) => RadarEntry(value: v.toDouble())).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(color: p.border, width: 1),
          gridBorderData: BorderSide(color: p.border, width: 1),
          tickBorderData: BorderSide(color: p.border, width: 1),
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
          tickCount: 4,
          titlePositionPercentageOffset: 0.16,
          titleTextStyle: AppText.micro(p.textDim),
          getTitle: (index, angle) => RadarChartTitle(text: MetricSet.labels[index % MetricSet.labels.length]),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}