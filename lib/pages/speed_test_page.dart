import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/speed_gauge.dart';
import '../components/mini_line_chart.dart';
import '../components/section_header.dart';
import '../components/app_bottom_nav.dart';
import '../components/primary_button.dart';
import '../components/feedback.dart';

class SpeedTestPage extends StatefulWidget {
  const SpeedTestPage({super.key});

  @override
  State<SpeedTestPage> createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  double _value = 0;
  String _phase = '';
  bool _running = false;
  final List<double> _live = [];
  SpeedResult? _result;

  void _navTo(int i) {
    final route = AppBottomNav.items[i].route;
    if (route != '/speed') Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _start() async {
    final state = context.read<AppState>();
    setState(() {
      _running = true;
      _value = 0;
      _phase = 'starting';
      _live.clear();
      _result = null;
    });
    final result = await state.speed.run(
      online: state.online,
      onTick: (mbps, progress, phase) {
        if (!mounted) return;
        setState(() {
          _value = mbps;
          _phase = phase;
          if (phase == 'download') _live.add(mbps);
        });
      },
    );
    await state.recordSpeed(result, state.connected);
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = result;
      _value = result.download;
      _phase = 'done';
    });
    showToast(context, state.online ? 'Speed test complete' : 'Offline. Showing a simulated run.', icon: Icons.speed);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();

    return Scaffold(
      body: AnimatedBackground(
        tint: AppColors.violet,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Speed test', style: AppText.h1(p.text)),
                      Text(state.online ? 'Live measure against a global server' : 'Offline mode, simulated run', style: AppText.micro(p.textDim)),
                      const SizedBox(height: 18),
                      GlassCard(
                        accent: AppColors.violet,
                        child: Column(
                          children: [
                            SpeedGauge(value: _value, phase: _running ? _phase : (_result != null ? 'download' : '')),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 90,
                              child: MiniLineChart(data: _live, color: AppColors.violet, height: 90),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_result != null) _results(context, _result!),
                      const SizedBox(height: 18),
                      const SectionHeader(title: 'Past results', icon: Icons.history),
                      GlassCard(child: MiniLineChart(data: state.speedHistory, height: 120, showAxis: true)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: PrimaryButton(
                  label: _running ? 'Measuring' : 'Start test',
                  icon: Icons.play_arrow_rounded,
                  busy: _running,
                  danger: true,
                  onTap: _start,
                ),
              ),
              AppBottomNav(index: 2, onTap: _navTo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _results(BuildContext context, SpeedResult r) {
    return Row(
      children: [
        Expanded(child: _ResultCard(icon: Icons.download_rounded, label: 'DOWNLOAD', value: r.download.toStringAsFixed(1), unit: 'Mbps', color: AppColors.cyan)),
        const SizedBox(width: 10),
        Expanded(child: _ResultCard(icon: Icons.upload_rounded, label: 'UPLOAD', value: r.upload.toStringAsFixed(1), unit: 'Mbps', color: AppColors.violet)),
        const SizedBox(width: 10),
        Expanded(child: _ResultCard(icon: Icons.network_ping_rounded, label: 'PING', value: '${r.ping}', unit: 'ms', color: AppColors.coral)),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _ResultCard({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: p.surface.withOpacity(p.dark ? 0.6 : 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(child: Text(value, style: AppText.h1(p.text).copyWith(fontSize: 20))),
          Text(unit, style: AppText.micro(p.textDim)),
          const SizedBox(height: 4),
          Text(label, style: AppText.micro(color)),
        ],
      ),
    );
  }
}
