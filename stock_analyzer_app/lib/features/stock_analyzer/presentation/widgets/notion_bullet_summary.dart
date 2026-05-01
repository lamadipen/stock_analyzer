import 'package:flutter/material.dart';
import 'package:stock_analyzer_app/features/stock_analyzer/presentation/theme/analysis_colors.dart';

class NotionSummaryBullet {
  const NotionSummaryBullet({
    required this.label,
    required this.value,
    this.icon = Icons.circle,
    this.tone = AppSummaryTone.neutral,
  });

  final String label;
  final String value;
  final IconData icon;
  final AppSummaryTone tone;
}

enum AppSummaryTone { neutral, success, warning, risk, info }

class NotionBulletSummary extends StatelessWidget {
  const NotionBulletSummary({
    super.key,
    required this.title,
    required this.bullets,
    this.subtitle,
    this.emptyMessage = 'No saved notes yet.',
  });

  final String title;
  final String? subtitle;
  final List<NotionSummaryBullet> bullets;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final visibleBullets = bullets
        .where((bullet) => bullet.value.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            SelectableText(
              subtitle!,
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (visibleBullets.isEmpty)
            Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: visibleBullets.map((bullet) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SummaryBulletRow(bullet: bullet),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class SectionReportModeToggle extends StatelessWidget {
  const SectionReportModeToggle({
    super.key,
    required this.showReportMode,
    required this.onChanged,
  });

  final bool showReportMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.edit_note),
          label: Text('Workspace'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.article_outlined),
          label: Text('Report'),
        ),
      ],
      selected: {showReportMode},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _SummaryBulletRow extends StatelessWidget {
  const _SummaryBulletRow({required this.bullet});

  final NotionSummaryBullet bullet;

  @override
  Widget build(BuildContext context) {
    final color = _colorForTone(bullet.tone);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(bullet.icon, size: 18, color: color.shade700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(color: Colors.grey.shade900, height: 1.35),
              children: [
                TextSpan(
                  text: '${bullet.label}: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: bullet.value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  MaterialColor _colorForTone(AppSummaryTone tone) {
    return switch (tone) {
      AppSummaryTone.success => AnalysisColors.favorable,
      AppSummaryTone.warning => AnalysisColors.caution,
      AppSummaryTone.risk => AnalysisColors.risk,
      AppSummaryTone.info => Colors.blue,
      AppSummaryTone.neutral => AnalysisColors.reference,
    };
  }
}
