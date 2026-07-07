import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/badges.dart';
import '../components/feedback.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  bool _frequentOnly = false;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final state = context.watch<AppState>();
    var list = [...state.saved]..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    if (_frequentOnly) list = list.where((s) => s.timesSeen >= 3).toList();

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
                    Expanded(child: Text('Saved networks', style: AppText.h1(p.text))),
                    GestureDetector(
                      onTap: () => setState(() => _frequentOnly = !_frequentOnly),
                      child: Pill(
                        text: _frequentOnly ? 'FREQUENT' : 'ALL',
                        color: _frequentOnly ? AppColors.cyan : p.textDim,
                        icon: Icons.filter_alt,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Icon(Icons.bookmark_border_rounded, size: 60, color: p.faint),
                              const SizedBox(height: 14),
                              Text('No saved networks yet', style: AppText.h2(p.text)),
                              const SizedBox(height: 6),
                              Text('Run a few scans and Saifi will remember and rate the ones you meet again.', textAlign: TextAlign.center, style: AppText.body(p.textDim)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _SavedTile(saved: list[i]),
                      ),
              ),
              if (list.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: GhostButtonWrap(
                    label: 'Clear saved history',
                    onTap: () async {
                      await state.clearData();
                      if (context.mounted) showToast(context, 'Saved history cleared', color: AppColors.coral, icon: Icons.delete_sweep);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GhostButtonWrap extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const GhostButtonWrap({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.coral.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_outline_rounded, color: AppColors.coral, size: 18),
              const SizedBox(width: 8),
              Text(label, style: AppText.label(AppColors.coral)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTile extends StatelessWidget {
  final SavedNetwork saved;
  const _SavedTile({required this.saved});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final color = riskColor((saved.rating * 20).round());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        accent: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.history_rounded, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(saved.ssid, style: AppText.h2(p.text).copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                      Text('Seen ${saved.timesSeen} time(s)', style: AppText.micro(p.textDim)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.cyan, size: 16),
                        const SizedBox(width: 3),
                        Text(saved.rating.toStringAsFixed(1), style: AppText.label(p.text)),
                      ],
                    ),
                    if (saved.lastSpeed > 0)
                      Text('${saved.lastSpeed.toStringAsFixed(0)} Mbps', style: AppText.micro(p.textDim)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(saved.comment, style: AppText.body(p.text).copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.surface2.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.violet, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(saved.recommendation, style: AppText.body(p.textDim).copyWith(fontSize: 12.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
