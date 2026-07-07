import 'package:flutter/material.dart';
import '../components/storage.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(Icons.radar_rounded, 'Scan the airwaves', 'Saifi finds every network around you and reads its signal, band and security in seconds.', AppColors.cyan),
    _Slide(Icons.shield_rounded, 'Spot the bad ones', 'Open networks, evil twins and weak encryption get flagged before they can bite.', AppColors.coral),
    _Slide(Icons.speed_rounded, 'Measure what matters', 'Real speed, strength, reliability and traffic, charted live the way you expect.', AppColors.violet),
    _Slide(Icons.auto_awesome_rounded, 'Smarter over time', 'Networks you use often get rated and remembered, so Saifi recommends the safe ones.', AppColors.cyan),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await Storage.setOnboarded(true);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Skip', style: AppText.label(p.textDim)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _slides.length,
                  itemBuilder: (_, i) {
                    final s = _slides[i];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: s.color.withOpacity(0.14),
                              shape: BoxShape.circle,
                              border: Border.all(color: s.color.withOpacity(0.4), width: 1.5),
                              boxShadow: [BoxShadow(color: s.color.withOpacity(0.3), blurRadius: 40, spreadRadius: -8)],
                            ),
                            child: Icon(s.icon, size: 64, color: s.color),
                          ),
                          const SizedBox(height: 44),
                          Text(s.title, textAlign: TextAlign.center, style: AppText.display(p.text).copyWith(fontSize: 27)),
                          const SizedBox(height: 16),
                          Text(s.body, textAlign: TextAlign.center, style: AppText.body(p.textDim)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: active ? 26 : 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.cyan : p.faint,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  label: _page == _slides.length - 1 ? 'Enter Saifi' : 'Next',
                  icon: _page == _slides.length - 1 ? Icons.arrow_forward_rounded : null,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Slide(this.icon, this.title, this.body, this.color);
}
