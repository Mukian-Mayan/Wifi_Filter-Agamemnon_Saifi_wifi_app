import 'package:flutter/material.dart';
import 'theme.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String route;
  const NavItem(this.icon, this.label, this.route);
}

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.index, required this.onTap});

  static const items = [
    NavItem(Icons.dashboard_rounded, 'Home', '/home'),
    NavItem(Icons.radar_rounded, 'Scan', '/scan'),
    NavItem(Icons.speed_rounded, 'Speed', '/speed'),
    NavItem(Icons.shield_rounded, 'Guard', '/security'),
    NavItem(Icons.insights_rounded, 'Stats', '/analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: p.surface.withOpacity(p.dark ? 0.78 : 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: p.border),
        boxShadow: [BoxShadow(color: p.glow, blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: active ? AppColors.brand : null,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, size: 21, color: active ? Colors.white : p.textDim),
                    if (active) ...[
                      const SizedBox(height: 3),
                      Text(items[i].label, style: AppText.micro(Colors.white)),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
