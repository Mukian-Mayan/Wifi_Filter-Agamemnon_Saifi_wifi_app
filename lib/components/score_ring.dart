import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class ScoreRing extends StatelessWidget {
  final int score;
  final double size;
  final String? caption;
  const ScoreRing({super.key, required this.score, this.size = 120, this.caption});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final color = riskColor(score);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: Size(size, size), painter: _RingPainter(value, color, p.surface2)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(value * 100).round()}', style: AppText.display(p.text).copyWith(fontSize: size * 0.3)),
                  if (caption != null) Text(caption!, style: AppText.micro(p.textDim)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  _RingPainter(this.value, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final stroke = size.width * 0.085;
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, base);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [color.withOpacity(0.5), color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}
