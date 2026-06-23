import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final Color tint;
  const AnimatedBackground({super.key, required this.child, this.tint = AppColors.cyan});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Dot> _dots;

  @override
  void initState() {
    super.initState();
    final rng = Random(7);
    _dots = List.generate(26, (i) {
      return _Dot(
        Offset(rng.nextDouble(), rng.nextDouble()),
        0.0008 + rng.nextDouble() * 0.0016,
        1.0 + rng.nextDouble() * 2.4,
        rng.nextDouble() * pi * 2,
      );
    });
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: p.dark
                    ? [const Color(0xFF0A1120), AppColors.black]
                    : [const Color(0xFFF7FAFF), const Color(0xFFE8EEF8)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _BgPainter(_c.value, _dots, widget.tint, p.dark),
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _Dot {
  Offset pos;
  final double speed;
  final double radius;
  final double phase;
  _Dot(this.pos, this.speed, this.radius, this.phase);
}

class _BgPainter extends CustomPainter {
  final double t;
  final List<_Dot> dots;
  final Color tint;
  final bool dark;
  _BgPainter(this.t, this.dots, this.tint, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [tint.withOpacity(dark ? 0.16 : 0.10), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.15), radius: size.width * 0.6));
    canvas.drawRect(Offset.zero & size, glow);

    final glow2 = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.violet.withOpacity(dark ? 0.14 : 0.08), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.1, size.height * 0.85), radius: size.width * 0.6));
    canvas.drawRect(Offset.zero & size, glow2);

    final dotPaint = Paint()..color = tint.withOpacity(dark ? 0.5 : 0.35);
    for (final d in dots) {
      final y = (d.pos.dy + t * d.speed * 40) % 1.0;
      final x = d.pos.dx + sin(t * pi * 2 + d.phase) * 0.02;
      final p = Offset(x * size.width, y * size.height);
      canvas.drawCircle(p, d.radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}
