import 'package:flutter/material.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/section_header.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  static const _tips = [
    _Tip(Icons.lock_open_rounded, 'Avoid open networks', 'No password means no encryption. Anyone on the same network can watch your traffic.', AppColors.coral),
    _Tip(Icons.copy_rounded, 'Watch for twins', 'Two networks with the same name can mean a fake one is trying to copy a real hotspot.', AppColors.violet),
    _Tip(Icons.vpn_lock_rounded, 'Use a VPN on public WiFi', 'A VPN wraps your traffic so a snooping network cannot read it.', AppColors.cyan),
    _Tip(Icons.password_rounded, 'Prefer WPA2 or WPA3', 'These are the modern standards. WEP and old WPA break in minutes.', AppColors.cyan),
    _Tip(Icons.payments_rounded, 'No banking on weak WiFi', 'Save logins and payments for networks Saifi marks as safe.', AppColors.coral),
  ];

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
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
                    Expanded(child: Text('Safety guide', style: AppText.h1(p.text))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        accent: AppColors.cyan,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(gradient: AppColors.brand, borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.wifi_protected_setup, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text('How Saifi scores a network', style: AppText.h2(p.text))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Saifi mixes encryption type, signal strength, channel traffic and a set of risk checks into one trust score. A measured speed test makes the score sharper. The more often you meet a network, the better Saifi learns and rates it.',
                              style: AppText.body(p.textDim).copyWith(fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Stay safe out there', icon: Icons.tips_and_updates),
                      ..._tips.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(color: t.color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
                                    child: Icon(t.icon, color: t.color, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t.title, style: AppText.h2(p.text).copyWith(fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(t.body, style: AppText.body(p.textDim).copyWith(fontSize: 12.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 10),
                      Center(child: Text('Saifi keeps everything on your device. No accounts, no uploads.', textAlign: TextAlign.center, style: AppText.micro(p.textDim))),
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

class _Tip {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Tip(this.icon, this.title, this.body, this.color);
}
