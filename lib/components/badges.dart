import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';

class SignalBars extends StatelessWidget {
  final int strength;
  final double size;
  const SignalBars({super.key, required this.strength, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final active = (strength / 25).ceil().clamp(0, 4);
    final color = strength >= 60 ? AppColors.cyan : (strength >= 35 ? AppColors.violet : AppColors.coral);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final on = i < active;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.2),
          child: Container(
            width: size * 0.18,
            height: size * (0.35 + i * 0.22),
            decoration: BoxDecoration(
              color: on ? color : p.faint.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill({super.key, required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 5)],
          Text(text, style: AppText.micro(color)),
        ],
      ),
    );
  }
}

class SecurityPill extends StatelessWidget {
  final WifiNetwork network;
  const SecurityPill({super.key, required this.network});

  @override
  Widget build(BuildContext context) {
    final lvl = network.securityLevel;
    final color = lvl == SecurityLevel.strong || lvl == SecurityLevel.secure
        ? AppColors.cyan
        : (lvl == SecurityLevel.weak ? AppColors.coral : AppColors.coral);
    final icon = lvl == SecurityLevel.open ? Icons.lock_open : Icons.lock;
    return Pill(text: network.securityLabel, color: color, icon: icon);
  }
}

class RiskPill extends StatelessWidget {
  final RiskLevel level;
  const RiskPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    switch (level) {
      case RiskLevel.safe:
        return const Pill(text: 'SAFE', color: AppColors.cyan, icon: Icons.verified_user);
      case RiskLevel.caution:
        return const Pill(text: 'CAUTION', color: AppColors.violet, icon: Icons.error_outline);
      case RiskLevel.danger:
        return const Pill(text: 'RISKY', color: AppColors.coral, icon: Icons.gpp_bad);
    }
  }
}

class StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const StatChip({super.key, required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: p.surface2.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.16), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppText.h2(p.text)),
              Text(label, style: AppText.micro(p.textDim)),
            ],
          ),
        ],
      ),
    );
  }
}
