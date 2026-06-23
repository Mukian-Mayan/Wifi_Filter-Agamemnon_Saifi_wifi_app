// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/badges.dart';
import '../components/section_header.dart';
import '../components/app_bottom_nav.dart';
import '../components/mini_line_chart.dart';
import '../components/score_ring.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.networks.isEmpty && state.phase == ScanPhase.idle) {
        state.runScan();
      }
    });
  }

  void _navTo(int i) {
    final route = AppBottomNav.items[i].route;
    if (route != '/home') Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final connected = state.connected;

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
                      _Header(state: state),
                      const SizedBox(height: 20),
                      _ConnectionCard(state: state, connected: connected),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: StatChip(icon: Icons.wifi, value: '${state.networks.length}', label: 'NETWORKS', color: AppColors.cyan)),
                          const SizedBox(width: 12),
                          Expanded(child: StatChip(icon: Icons.verified_user, value: '${state.safeCount}', label: 'SAFE', color: AppColors.violet)),
                          const SizedBox(width: 12),
                          Expanded(child: StatChip(icon: Icons.gpp_bad, value: '${state.riskyCount}', label: 'RISKY', color: AppColors.coral)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Quick actions', icon: Icons.bolt),
                      _quickGrid(context),
                      const SizedBox(height: 22),
                      SectionHeader(
                        title: 'Speed history',
                        icon: Icons.show_chart,
                        action: 'Test now',
                        onAction: () => Navigator.pushReplacementNamed(context, '/speed'),
                      ),
                      GlassCard(child: MiniLineChart(data: state.speedHistory, height: 130)),
                    ],
                  ),
                ),
              ),
              AppBottomNav(index: 0, onTap: _navTo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickGrid(BuildContext context) {
    final actions = [
      _Action(Icons.radar_rounded, 'Scan now', AppColors.cyan, '/scan'),
      _Action(Icons.speed_rounded, 'Speed test', AppColors.violet, '/speed'),
      _Action(Icons.tune_rounded, 'Filter', AppColors.cyan, '/filter'),
      _Action(Icons.bookmark_rounded, 'Saved', AppColors.violet, '/saved'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: actions.map((a) {
        return GlassCard(
          accent: a.color,
          padding: const EdgeInsets.all(14),
          onTap: () => Navigator.pushReplacementNamed(context, a.route),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(a.icon, color: a.color, size: 26),
              Text(a.label, style: AppText.label(Palette.of(context).text)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _Action(this.icon, this.label, this.color, this.route);
}

class _Header extends StatelessWidget {
  final AppState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(gradient: AppColors.brand, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.wifi_protected_setup, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saifi', style: AppText.h1(p.text)),
              Text('Network guardian', style: AppText.micro(p.textDim)),
            ],
          ),
        ),
        Pill(
          text: state.online ? 'ONLINE' : 'OFFLINE',
          color: state.online ? AppColors.cyan : AppColors.coral,
          icon: state.online ? Icons.cloud_done : Icons.cloud_off,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          child: Icon(Icons.settings_rounded, color: p.textDim, size: 24),
        ),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final AppState state;
  final WifiNetwork? connected;
  const _ConnectionCard({required this.state, this.connected});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    if (connected == null) {
      return GlassCard(
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.coral, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Not connected', style: AppText.h2(p.text)),
                  Text(state.statusMessage, style: AppText.micro(p.textDim)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final risk = assessRisk(connected!, state.networks);
    return GlassCard(
      accent: riskColor(risk.score),
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: connected),
      child: Row(
        children: [
          ScoreRing(score: risk.score, size: 86, caption: 'TRUST'),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected to', style: AppText.micro(p.textDim)),
                const SizedBox(height: 2),
                Text(connected!.displayName, style: AppText.h2(p.text), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    SecurityPill(network: connected!),
                    RiskPill(level: risk.level),
                    if (state.vpnOn) const Pill(text: 'VPN', color: AppColors.violet, icon: Icons.vpn_lock),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
