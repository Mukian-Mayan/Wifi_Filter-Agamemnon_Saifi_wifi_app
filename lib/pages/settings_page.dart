import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/section_header.dart';
import '../components/feedback.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();

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
                    Expanded(child: Text('Settings', style: AppText.h1(p.text))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Appearance', icon: Icons.palette),
                      GlassCard(
                        child: _Toggle(
                          icon: state.dark ? Icons.dark_mode : Icons.light_mode,
                          label: 'Dark mode',
                          note: 'Switch the whole app theme',
                          value: state.dark,
                          onChanged: (_) {
                            state.toggleDark();
                            showToast(context, state.dark ? 'Light theme on' : 'Dark theme on', icon: Icons.palette);
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Data source', icon: Icons.science),
                      GlassCard(
                        child: _Toggle(
                          icon: Icons.bug_report_rounded,
                          label: 'Demo mode',
                          note: 'Always use sample networks instead of a real scan',
                          value: state.demoMode,
                          onChanged: (v) {
                            state.setDemo(v);
                            showToast(context, v ? 'Demo mode on' : 'Demo mode off', icon: Icons.science);
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'About', icon: Icons.info_outline),
                      GlassCard(
                        onTap: () => Navigator.pushNamed(context, '/tips'),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: AppColors.cyan, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Safety tips and guide', style: AppText.h2(p.text).copyWith(fontSize: 15)),
                                  Text('Learn how Saifi judges a network', style: AppText.micro(p.textDim)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: p.textDim),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassCard(
                        onTap: () => Navigator.pushNamed(context, '/radar'),
                        child: Row(
                          children: [
                            const Icon(Icons.radar_rounded, color: AppColors.violet, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Signal radar', style: AppText.h2(p.text).copyWith(fontSize: 15)),
                                  Text('See networks as live blips', style: AppText.micro(p.textDim)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: p.textDim),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Storage', icon: Icons.storage),
                      GlassCard(
                        accent: AppColors.coral,
                        onTap: () async {
                          await state.clearData();
                          if (context.mounted) showToast(context, 'All saved data cleared', color: AppColors.coral, icon: Icons.delete_sweep);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.delete_forever_rounded, color: AppColors.coral, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Clear saved data', style: AppText.h2(p.text).copyWith(fontSize: 15)),
                                  Text('Wipes saved networks and speed history', style: AppText.micro(p.textDim)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(child: Text('Saifi v1.0', style: AppText.micro(p.textDim))),
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
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String note;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.icon, required this.label, required this.note, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.h2(p.text).copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(note, style: AppText.micro(p.textDim)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.cyan,
          inactiveTrackColor: p.surface2,
        ),
      ],
    );
  }
}
