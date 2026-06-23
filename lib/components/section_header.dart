import 'package:flutter/material.dart';
import 'theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final IconData? icon;
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.cyan),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title, style: AppText.h2(p.text))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: AppText.label(AppColors.cyan)),
            ),
        ],
      ),
    );
  }
}
