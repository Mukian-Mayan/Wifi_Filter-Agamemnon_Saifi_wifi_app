import 'package:flutter/material.dart';
import 'theme.dart';

void showToast(BuildContext context, String message, {Color? color, IconData icon = Icons.bolt}) {
  final p = Palette.of(context);
  final c = color ?? AppColors.cyan;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.surface,
      elevation: 0,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: c.withOpacity(0.5)),
      ),
      content: Row(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppText.body(p.text).copyWith(fontSize: 13.5))),
        ],
      ),
    ),
  );
}

class PulseLoader extends StatefulWidget {
  final String label;
  final Color color;
  const PulseLoader({super.key, required this.label, this.color = AppColors.cyan});

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) => SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Opacity(
                    opacity: (1 - ((_c.value + i / 3) % 1)).clamp(0.0, 1.0),
                    child: Container(
                      height: 24 + ((_c.value + i / 3) % 1) * 46,
                      width: 24 + ((_c.value + i / 3) % 1) * 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color.withOpacity(0.6), width: 2),
                      ),
                    ),
                  ),
                Icon(Icons.wifi_tethering, color: widget.color, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.label, style: AppText.label(p.textDim)),
      ],
    );
  }
}
