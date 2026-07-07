import 'package:flutter/material.dart';
import '../components/storage.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();
    Future.delayed(const Duration(milliseconds: 2100), _go);
  }

  void _go() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Storage.onboarded ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      gradient: AppColors.brand,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.5), blurRadius: 40, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.wifi_protected_setup, size: 58, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _c,
                  child: Column(
                    children: [
                      Text('Saifi', style: AppText.display(p.text).copyWith(fontSize: 40)),
                      const SizedBox(height: 6),
                      Text('Know your network before you trust it', style: AppText.label(p.textDim)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 130,
                  child: LinearProgressIndicator(
                    backgroundColor: p.surface2,
                    color: AppColors.cyan,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
