import 'package:flutter/material.dart';
import 'theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  final bool danger;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.busy = false,
    this.danger = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = danger ? AppColors.alert : AppColors.brand;
    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: busy
          ? const SizedBox(
              key: ValueKey('busy'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              key: const ValueKey('idle'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 19, color: Colors.white), const SizedBox(width: 9)],
                Text(label, style: AppText.label(Colors.white).copyWith(fontSize: 14.5, fontWeight: FontWeight.w700)),
              ],
            ),
    );
    return Opacity(
      opacity: onTap == null && !busy ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: busy ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Container(
              width: expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const GhostButton({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: p.surface2.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: p.text), const SizedBox(width: 8)],
              Text(label, style: AppText.label(p.text)),
            ],
          ),
        ),
      ),
    );
  }
}
