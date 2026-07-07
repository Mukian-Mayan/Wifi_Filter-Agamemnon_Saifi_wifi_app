import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_state.dart';
import '../components/models.dart';
import '../components/theme.dart';
import '../components/animated_background.dart';
import '../components/glass_card.dart';
import '../components/badges.dart';
import '../components/section_header.dart';
import '../components/score_ring.dart';
import '../components/metric_radar.dart';
import '../components/primary_button.dart';
import '../components/feedback.dart';

class NetworkDetailPage extends StatelessWidget {
  const NetworkDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final network = ModalRoute.of(context)!.settings.arguments as WifiNetwork;
    final state = context.watch<AppState>();
    final metrics = computeMetrics(network, state.networks);
    final risk = assessRisk(network, state.networks);
    final saved = state.saved.where((s) => s.bssid == network.bssid).toList();
    final rating = saved.isNotEmpty ? saved.first.rating : autoRating(metrics, risk.level);
    final comment = saved.isNotEmpty ? saved.first.comment : autoComment(metrics, risk.level);
    final recommendation = saved.isNotEmpty ? saved.first.recommendation : 'Connect a few times so Saifi can learn this network.';

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(title: network.displayName),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        accent: riskColor(risk.score),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ScoreRing(score: risk.score, size: 96, caption: 'TRUST'),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(risk.headline, style: AppText.h2(p.text)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          SecurityPill(network: network),
                                          RiskPill(level: risk.level),
                                          Pill(text: network.band, color: AppColors.violet, icon: Icons.router),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _RatingRow(rating: rating),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SectionHeader(title: 'Performance profile', icon: Icons.donut_large),
                      GlassCard(
                        child: Column(
                          children: [
                            MetricRadar(metrics: metrics),
                            const SizedBox(height: 8),
                            _metricLegend(context, metrics),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SectionHeader(title: 'Auto review', icon: Icons.rate_review),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.format_quote_rounded, color: AppColors.cyan, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(comment, style: AppText.body(p.text))),
                              ],
                            ),
                            const Divider(height: 26),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.violet, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(recommendation, style: AppText.body(p.textDim).copyWith(fontSize: 13.5))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SectionHeader(title: 'Risk findings (${risk.issues.length})', icon: Icons.policy),
                      ...risk.issues.map((i) => _IssueRow(issue: i)),
                      const SizedBox(height: 20),
                      const SectionHeader(title: 'Technical details', icon: Icons.memory),
                      GlassCard(
                        child: Column(
                          children: [
                            _detail(context, 'MAC / BSSID', network.bssid),
                            _detail(context, 'Vendor', network.vendor),
                            _detail(context, 'Security', network.securityLabel),
                            _detail(context, 'Band', network.band),
                            _detail(context, 'Channel', network.channel == 0 ? 'Unknown' : '${network.channel}'),
                            _detail(context, 'Frequency', '${network.frequency} MHz'),
                            _detail(context, 'Signal', '${network.rssi} dBm  (${network.strength}%)'),
                            if (network.latitude != null)
                              _detail(context, 'Seen near', '${network.latitude!.toStringAsFixed(4)}, ${network.longitude!.toStringAsFixed(4)}'),
                            _detail(context, 'Times seen', '${saved.isNotEmpty ? saved.first.timesSeen : 1}', last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Test this network',
                        icon: Icons.speed_rounded,
                        onTap: () => Navigator.pushReplacementNamed(context, '/speed'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricLegend(BuildContext context, MetricSet m) {
    final p = Palette.of(context);
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(MetricSet.labels.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${MetricSet.labels[i]} ', style: AppText.micro(p.textDim)),
            Text('${m.asList[i]}', style: AppText.micro(riskColor(m.asList[i]))),
          ],
        );
      }),
    );
  }

  Widget _detail(BuildContext context, String label, String value, {bool last = false}) {
    final p = Palette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppText.label(p.textDim))),
          Expanded(child: Text(value, style: AppText.body(p.text).copyWith(fontSize: 13.5), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back_rounded, color: p.text),
          ),
          Expanded(child: Text(title, style: AppText.h1(p.text), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface2.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text('Auto rating', style: AppText.label(p.textDim)),
          const Spacer(),
          ...List.generate(5, (i) {
            final filled = i < rating.floor();
            final half = i == rating.floor() && rating - rating.floor() >= 0.5;
            return Icon(
              half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
              size: 20,
              color: AppColors.cyan,
            );
          }),
          const SizedBox(width: 8),
          Text(rating.toStringAsFixed(1), style: AppText.h2(p.text).copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final RiskIssue issue;
  const _IssueRow({required this.issue});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    Color c;
    IconData icon;
    switch (issue.severity) {
      case RiskLevel.safe:
        c = AppColors.cyan;
        icon = Icons.check_circle_rounded;
        break;
      case RiskLevel.caution:
        c = AppColors.violet;
        icon = Icons.error_outline_rounded;
        break;
      case RiskLevel.danger:
        c = AppColors.coral;
        icon = Icons.warning_amber_rounded;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surface.withOpacity(p.dark ? 0.55 : 0.9),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(issue.title, style: AppText.label(p.text)),
                  const SizedBox(height: 3),
                  Text(issue.detail, style: AppText.body(p.textDim).copyWith(fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
