import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class SpeedGauge extends StatelessWidget {
  final double value;
  final double max;
  final String unit;
  final String phase;
  const SpeedGauge({super.key, required this.value, this.max = 200, this.unit = 'Mbps', this.phase = ''});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final ratio = (value / max).clamp(0.0, 1.0);
    final color = ratio > 0.6 ? AppColors.cyan : (ratio > 0.3 ? AppColors.violet : AppColors.coral);
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.infinite, painter: _GaugePainter(ratio, color, p.surface2)),
          Padding(
            padding: const EdgeInsets.only(top: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value.toStringAsFixed(1), style: AppText.display(p.text).copyWith(fontSize: 44)),
                Text(unit, style: AppText.label(p.textDim)),
                if (phase.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(phase.toUpperCase(), style: AppText.micro(color)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color track;
  _GaugePainter(this.ratio, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.82);
    final radius = size.width * 0.42;
    const startAngle = pi * 0.85;
    const sweep = pi * 1.3;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, base);

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [AppColors.violet, AppColors.cyan],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep * ratio, false, fg);

    final needleAngle = startAngle + sweep * ratio;
    final needle = Offset(center.dx + cos(needleAngle) * radius, center.dy + sin(needleAngle) * radius);
    final dot = Paint()..color = color;
    canvas.drawCircle(needle, 7, dot);
    canvas.drawCircle(needle, 12, Paint()..color = color.withOpacity(0.25));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.ratio != ratio;
}
