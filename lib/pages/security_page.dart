import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/badges.dart';
import '../components/section_header.dart';
import '../components/score_ring.dart';
import '../components/app_bottom_nav.dart';
import '../components/network_tile.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  void _navTo(BuildContext context, int i) {
    final route = AppBottomNav.items[i].route;
    if (route != '/security') Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final risky = state.networks.where((n) => assessRisk(n, state.networks).level != RiskLevel.safe).toList()
      ..sort((a, b) => assessRisk(a, state.networks).score.compareTo(assessRisk(b, state.networks).score));
    final total = state.networks.isEmpty ? 1 : state.networks.length;
    final overall = ((state.safeCount / total) * 100).round();

    return Scaffold(
      body: AnimatedBackground(
        tint: AppColors.coral,
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
                      Text('Guard', style: AppText.h1(p.text)),
                      Text('Your live security picture', style: AppText.micro(p.textDim)),
                      const SizedBox(height: 18),
                      GlassCard(
                        accent: riskColor(overall),
                        child: Row(
                          children: [
                            ScoreRing(score: overall, size: 96, caption: 'SAFE AIR'),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Airspace health', style: AppText.h2(p.text)),
                                  const SizedBox(height: 6),
                                  Text('${state.safeCount} safe and ${state.riskyCount} risky networks around you right now.', style: AppText.body(p.textDim).copyWith(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _GuardCard(
                              icon: state.vpnOn ? Icons.vpn_lock : Icons.vpn_key_off,
                              title: 'VPN',
                              value: state.vpnOn ? 'Active' : 'Off',
                              color: state.vpnOn ? AppColors.violet : p.textDim,
                              note: state.vpnOn ? 'Your traffic is tunnelled' : 'No tunnel detected',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GuardCard(
                              icon: Icons.lan_rounded,
                              title: 'Local IP',
                              value: state.localIp ?? 'Unknown',
                              color: AppColors.cyan,
                              note: 'Gateway ${state.gatewayIp ?? "n/a"}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ChecklistCard(state: state),
                      const SizedBox(height: 22),
                      SectionHeader(title: 'Flagged networks (${risky.length})', icon: Icons.gpp_maybe),
                      if (risky.isEmpty)
                        GlassCard(
                          accent: AppColors.cyan,
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.cyan, size: 26),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Nothing risky in range. The air looks clean.', style: AppText.body(p.text))),
                            ],
                          ),
                        )
                      else
                        ...risky.map((n) => NetworkTile(
                              network: n,
                              risk: assessRisk(n, state.networks),
                              onTap: () => Navigator.pushNamed(context, '/detail', arguments: n),
                            )),
                    ],
                  ),
                ),
              ),
              AppBottomNav(index: 3, onTap: (i) => _navTo(context, i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String note;
  final Color color;
  const _GuardCard({required this.icon, required this.title, required this.value, required this.note, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface.withOpacity(p.dark ? 0.6 : 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(title, style: AppText.micro(p.textDim)),
          const SizedBox(height: 2),
          Text(value, style: AppText.h2(p.text).copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(note, style: AppText.micro(p.textDim)),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final AppState state;
  const _ChecklistCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final connected = state.connected;
    final checks = <_Check>[
      _Check('Connected network is encrypted', connected == null ? null : connected.securityLevel != SecurityLevel.open),
      _Check('No open networks broadcasting', !state.networks.any((n) => n.securityLevel == SecurityLevel.open)),
      _Check('No duplicate network names', !_hasTwins(state.networks)),
      _Check('No weak WEP networks nearby', !state.networks.any((n) => n.securityLevel == SecurityLevel.weak)),
    ];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Safety checklist', style: AppText.h2(p.text)),
          const SizedBox(height: 14),
          ...checks.map((c) {
            final pass = c.pass;
            final color = pass == null ? p.textDim : (pass ? AppColors.cyan : AppColors.coral);
            final icon = pass == null ? Icons.remove_circle_outline : (pass ? Icons.check_circle_rounded : Icons.cancel_rounded);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 19),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.label, style: AppText.body(p.text).copyWith(fontSize: 13.5))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _hasTwins(List<WifiNetwork> all) {
    final names = <String, int>{};
    for (final n in all) {
      if (n.ssid.trim().isEmpty) continue;
      names[n.ssid] = (names[n.ssid] ?? 0) + 1;
    }
    return names.values.any((c) => c > 1);
  }
}

class _Check {
  final String label;
  final bool? pass;
  const _Check(this.label, this.pass);
}
