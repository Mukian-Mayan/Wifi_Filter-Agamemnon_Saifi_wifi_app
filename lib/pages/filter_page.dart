import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/section_header.dart';
import '../components/primary_button.dart';
import '../components/feedback.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late bool _safeOnly;
  late bool _fiveOnly;
  late double _minStrength;
  late Set<SecurityLevel> _security;

  @override
  void initState() {
    super.initState();
    final f = context.read<AppState>().filter;
    _safeOnly = f.safeOnly;
    _fiveOnly = f.fiveGhzOnly;
    _minStrength = f.minStrength.toDouble();
    _security = {...f.security};
  }

  void _apply() {
    final f = WifiFilter(
      safeOnly: _safeOnly,
      fiveGhzOnly: _fiveOnly,
      minStrength: _minStrength.round(),
      security: _security,
    );
    context.read<AppState>().applyFilter(f);
    showToast(context, f.isActive ? 'Filter applied' : 'Filter cleared', icon: Icons.tune);
    Navigator.maybePop(context);
  }

  void _reset() {
    setState(() {
      _safeOnly = false;
      _fiveOnly = false;
      _minStrength = 0;
      _security = {...SecurityLevel.values};
    });
  }

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
                    Expanded(child: Text('Filter networks', style: AppText.h1(p.text))),
                    GestureDetector(onTap: _reset, child: Text('Reset', style: AppText.label(AppColors.coral))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Quick toggles', icon: Icons.toggle_on),
                      GlassCard(
                        child: Column(
                          children: [
                            _SwitchRow(
                              label: 'Safe networks only',
                              note: 'Hide open and weak networks',
                              value: _safeOnly,
                              onChanged: (v) => setState(() => _safeOnly = v),
                            ),
                            Divider(height: 22, color: p.border),
                            _SwitchRow(
                              label: '5 GHz only',
                              note: 'Faster, shorter range band',
                              value: _fiveOnly,
                              onChanged: (v) => setState(() => _fiveOnly = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Minimum signal', icon: Icons.network_cell),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('At least', style: AppText.body(p.textDim)),
                                const Spacer(),
                                Text('${_minStrength.round()}%', style: AppText.h2(AppColors.cyan)),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.cyan,
                                inactiveTrackColor: p.surface2,
                                thumbColor: AppColors.cyan,
                                overlayColor: AppColors.cyan.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _minStrength,
                                max: 100,
                                divisions: 20,
                                onChanged: (v) => setState(() => _minStrength = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader(title: 'Security types', icon: Icons.lock),
                      GlassCard(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: SecurityLevel.values.map((lvl) {
                            final on = _security.contains(lvl);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (on) {
                                  if (_security.length > 1) _security.remove(lvl);
                                } else {
                                  _security.add(lvl);
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: on ? AppColors.cyan.withOpacity(0.16) : p.surface2.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: on ? AppColors.cyan.withOpacity(0.5) : p.border),
                                ),
                                child: Text(_label(lvl), style: AppText.label(on ? AppColors.cyan : p.textDim)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: PrimaryButton(label: 'Apply filter', icon: Icons.check_rounded, onTap: _apply),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(SecurityLevel lvl) {
    switch (lvl) {
      case SecurityLevel.strong:
        return 'WPA3';
      case SecurityLevel.secure:
        return 'WPA2';
      case SecurityLevel.weak:
        return 'WEP / WPA';
      case SecurityLevel.open:
        return 'Open';
    }
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String note;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.label, required this.note, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.h2(p.text).copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(note, style: AppText.micro(p.textDim)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.cyan,
          inactiveTrackColor: p.surface2,
        ),
      ],
    );
  }
}
