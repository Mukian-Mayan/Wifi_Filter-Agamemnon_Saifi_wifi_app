import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/section_header.dart';
import '../components/app_bottom_nav.dart';
import '../components/mini_line_chart.dart';
import '../components/badges.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  void _navTo(BuildContext context, int i) {
    final route = AppBottomNav.items[i].route;
    if (route != '/analytics') Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final counts = _securityCounts(state.networks);
    final bands = _bandCounts(state.networks);
    final avgSpeed = state.speedHistory.isEmpty ? 0.0 : state.speedHistory.reduce((a, b) => a + b) / state.speedHistory.length;
    final bestSpeed = state.speedHistory.isEmpty ? 0.0 : state.speedHistory.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: AnimatedBackground(
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
                      Text('Analytics', style: AppText.h1(p.text)),
                      Text('Patterns across your scans', style: AppText.micro(p.textDim)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: StatChip(icon: Icons.download_rounded, value: avgSpeed.toStringAsFixed(0), label: 'AVG Mbps', color: AppColors.cyan)),
                          const SizedBox(width: 12),
                          Expanded(child: StatChip(icon: Icons.bolt, value: bestSpeed.toStringAsFixed(0), label: 'BEST Mbps', color: AppColors.violet)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Speed trend', icon: Icons.timeline),
                      GlassCard(child: MiniLineChart(data: state.speedHistory, height: 150, showAxis: true)),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Security mix', icon: Icons.pie_chart),
                      GlassCard(
                        child: counts.isEmpty
                            ? SizedBox(height: 80, child: Center(child: Text('Scan first to see the mix', style: AppText.label(p.textDim))))
                            : Column(
                                children: [
                                  SizedBox(height: 170, child: _pie(counts)),
                                  const SizedBox(height: 14),
                                  _legend(context, counts),
                                ],
                              ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Band split', icon: Icons.cell_tower),
                      GlassCard(child: _bandBars(context, bands)),
                    ],
                  ),
                ),
              ),
              AppBottomNav(index: 4, onTap: (i) => _navTo(context, i)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _securityCounts(List<WifiNetwork> nets) {
    final m = <String, int>{};
    for (final n in nets) {
      final k = n.securityLabel;
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  Map<String, int> _bandCounts(List<WifiNetwork> nets) {
    final m = {'2.4 GHz': 0, '5 GHz': 0};
    for (final n in nets) {
      m[n.band] = (m[n.band] ?? 0) + 1;
    }
    return m;
  }

  Color _colorFor(String key) {
    if (key.contains('WPA3') || key.contains('WPA2')) return AppColors.cyan;
    if (key.contains('WEP') || key.contains('WPA')) return AppColors.violet;
    return AppColors.coral;
  }

  Widget _pie(Map<String, int> counts) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 42,
        sections: counts.entries.map((e) {
          final pct = total == 0 ? 0 : (e.value / total * 100).round();
          return PieChartSectionData(
            value: e.value.toDouble(),
            color: _colorFor(e.key),
            title: '$pct%',
            radius: 46,
            titleStyle: AppText.micro(Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _legend(BuildContext context, Map<String, int> counts) {
    final p = Palette.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: counts.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 10, width: 10, decoration: BoxDecoration(color: _colorFor(e.key), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${e.key} (${e.value})', style: AppText.micro(p.textDim)),
          ],
        );
      }).toList(),
    );
  }

  Widget _bandBars(BuildContext context, Map<String, int> bands) {
    final p = Palette.of(context);
    final total = bands.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return SizedBox(height: 60, child: Center(child: Text('No data yet', style: AppText.label(p.textDim))));
    }
    return Column(
      children: bands.entries.map((e) {
        final frac = total == 0 ? 0.0 : e.value / total;
        final color = e.key == '5 GHz' ? AppColors.cyan : AppColors.violet;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(e.key, style: AppText.label(p.text)),
                  const Spacer(),
                  Text('${e.value}', style: AppText.label(color)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: frac),
                  duration: const Duration(milliseconds: 700),
                  builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 9, backgroundColor: p.surface2, color: color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
