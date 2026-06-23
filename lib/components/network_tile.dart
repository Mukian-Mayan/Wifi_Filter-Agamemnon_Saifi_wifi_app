import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'badges.dart';

class NetworkTile extends StatelessWidget {
  final WifiNetwork network;
  final RiskReport risk;
  final VoidCallback onTap;
  const NetworkTile({super.key, required this.network, required this.risk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final color = riskColor(risk.score);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: p.surface.withOpacity(p.dark ? 0.6 : 0.92),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: network.isConnected ? AppColors.cyan.withOpacity(0.6) : p.border),
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Icon(
                    network.isHidden ? Icons.visibility_off : Icons.wifi,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              network.displayName,
                              style: AppText.h2(p.text).copyWith(fontSize: 15.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (network.isConnected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, size: 14, color: AppColors.cyan),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SecurityPill(network: network),
                          const SizedBox(width: 6),
                          Text(network.band, style: AppText.micro(p.textDim)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SignalBars(strength: network.strength),
                    const SizedBox(height: 8),
                    RiskPill(level: risk.level),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
