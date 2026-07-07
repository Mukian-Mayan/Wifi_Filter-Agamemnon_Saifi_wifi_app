import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/badges.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final blips = _buildBlips(state.networks);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 18, 4),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.maybePop(context), icon: Icon(Icons.arrow_back_rounded, color: p.text)),
                    Expanded(child: Text('Signal radar', style: AppText.h1(p.text))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Closer to the centre means a stronger signal. Colour shows risk.', style: AppText.body(p.textDim).copyWith(fontSize: 13)),
                      const SizedBox(height: 18),
                      GlassCard(
                        padding: const EdgeInsets.all(10),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: AnimatedBuilder(
                            animation: _c,
                            builder: (_, __) => CustomPaint(
                              painter: _RadarPainter(_c.value, blips, p.dark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const _Legend(color: AppColors.cyan, label: 'Safe'),
                          const SizedBox(width: 16),
                          const _Legend(color: AppColors.violet, label: 'Caution'),
                          const SizedBox(width: 16),
                          const _Legend(color: AppColors.coral, label: 'Risky'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...blips.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(height: 10, width: 10, decoration: BoxDecoration(color: b.color, shape: BoxShape.circle)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(b.name, style: AppText.body(p.text).copyWith(fontSize: 13.5), overflow: TextOverflow.ellipsis)),
                                Text('${b.strength}%', style: AppText.label(b.color)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_Blip> _buildBlips(List<WifiNetwork> nets) {
    final out = <_Blip>[];
    final rng = Random(42);
    for (final n in nets) {
      final risk = assessRisk(n, nets);
      final angle = rng.nextDouble() * pi * 2;
      out.add(_Blip(n.displayName, n.strength, riskColor(risk.score), angle));
    }
    return out;
  }
}

class _Blip {
  final String name;
  final int strength;
  final Color color;
  final double angle;
  const _Blip(this.name, this.strength, this.color, this.angle);
}

class _RadarPainter extends CustomPainter {
  final double t;
  final List<_Blip> blips;
  final bool dark;
  _RadarPainter(this.t, this.blips, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2 - 6;
    final grid = Paint()
      ..color = AppColors.cyan.withOpacity(dark ? 0.18 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxR * i / 4, grid);
    }
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), grid);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), grid);

    final sweepAngle = t * pi * 2;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle,
        endAngle: sweepAngle + pi / 2,
        colors: [AppColors.cyan.withOpacity(0.0), AppColors.cyan.withOpacity(0.35)],
      ).createShader(Rect.fromCircle(center: center, radius: maxR));
    canvas.drawCircle(center, maxR, sweepPaint);

    for (final b in blips) {
      final r = maxR * (1 - b.strength / 100).clamp(0.05, 0.95);
      final pos = Offset(center.dx + cos(b.angle) * r, center.dy + sin(b.angle) * r);
      final pulse = (sin(t * pi * 2 + b.angle) + 1) / 2;
      canvas.drawCircle(pos, 4 + pulse * 2, Paint()..color = b.color);
      canvas.drawCircle(pos, 9 + pulse * 4, Paint()..color = b.color.withOpacity(0.2));
    }

    canvas.drawCircle(center, 5, Paint()..color = AppColors.cyan);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 10, width: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppText.micro(p.textDim)),
      ],
    );
  }
}
