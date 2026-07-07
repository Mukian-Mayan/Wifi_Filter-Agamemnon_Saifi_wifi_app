import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/wifi_service.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/network_tile.dart';
import '../components/app_bottom_nav.dart';
import '../components/feedback.dart';
import '../components/primary_button.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  void _navTo(BuildContext context, int i) {
    final route = AppBottomNav.items[i].route;
    if (route != '/scan') Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    final list = state.visibleNetworks;
    final scanning = state.phase == ScanPhase.scanning;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    Expanded(child: Text('Nearby networks', style: AppText.h1(p.text))),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/filter'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: state.filter.isActive ? AppColors.cyan.withOpacity(0.16) : p.surface2.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: state.filter.isActive ? AppColors.cyan.withOpacity(0.5) : p.border),
                        ),
                        child: Icon(Icons.tune_rounded, size: 20, color: state.filter.isActive ? AppColors.cyan : p.textDim),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SearchBar(onChanged: state.setQuery),
              ),
              const SizedBox(height: 12),
              _SourceBanner(state: state),
              Expanded(
                child: scanning
                    ? Center(child: PulseLoader(label: state.statusMessage))
                    : list.isEmpty
                        ? _empty(context, state)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final n = list[i];
                              return NetworkTile(
                                network: n,
                                risk: assessRisk(n, state.networks),
                                onTap: () => Navigator.pushNamed(context, '/detail', arguments: n),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: PrimaryButton(
                  label: scanning ? 'Scanning' : 'Rescan networks',
                  icon: Icons.radar_rounded,
                  busy: scanning,
                  onTap: () async {
                    await state.runScan();
                    if (context.mounted) showToast(context, state.statusMessage);
                  },
                ),
              ),
              AppBottomNav(index: 1, onTap: (i) => _navTo(context, i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, AppState state) {
    final p = Palette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: p.faint),
            const SizedBox(height: 16),
            Text('Nothing matches', style: AppText.h2(p.text)),
            const SizedBox(height: 6),
            Text('Try clearing the search or filter', textAlign: TextAlign.center, style: AppText.body(p.textDim)),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.surface.withOpacity(p.dark ? 0.6 : 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: p.textDim, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppText.body(p.text),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search name, MAC or vendor',
                hintStyle: AppText.body(p.textDim).copyWith(fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBanner extends StatelessWidget {
  final AppState state;
  const _SourceBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.phase != ScanPhase.ready) return const SizedBox.shrink();
    final p = Palette.of(context);
    Color color;
    IconData icon;
    switch (state.source) {
      case ScanSource.live:
        color = AppColors.cyan;
        icon = Icons.sensors;
        break;
      case ScanSource.connectedOnly:
        color = AppColors.violet;
        icon = Icons.wifi_tethering;
        break;
      case ScanSource.demo:
        color = AppColors.violet;
        icon = Icons.science;
        break;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(state.statusMessage, style: AppText.micro(p.text).copyWith(letterSpacing: 0.2))),
          ],
        ),
      ),
    );
  }
}
