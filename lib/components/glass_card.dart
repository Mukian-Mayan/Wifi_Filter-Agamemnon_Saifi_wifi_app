import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final VoidCallback? onTap;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
    this.onTap,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              decoration: BoxDecoration(
                color: p.surface.withOpacity(p.dark ? 0.62 : 0.86),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: accent?.withOpacity(0.5) ?? p.border,
                  width: accent != null ? 1.2 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: p.glow, blurRadius: 22, offset: const Offset(0, 10)),
                  if (accent != null) BoxShadow(color: accent!.withOpacity(0.18), blurRadius: 26, spreadRadius: -6),
                ],
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
