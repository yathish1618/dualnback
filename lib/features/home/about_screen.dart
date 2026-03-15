import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Research basis ─────────────────────────────────────────────────
          _Section(
            title: 'Based on Research',
            icon: Icons.science_outlined,
            children: [
              Text(
                'This app implements the Dual N-Back training protocol from the seminal paper:',
                style: tc.bodyMedium,
              ),
              const Gap(8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => launchUrl(
                  Uri.parse('https://www.pnas.org/doi/10.1073/pnas.0801268105'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: cs.outline.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jaeggi, S. M., Buschkuehl, M., Jonides, J., & Perrig, W. J. (2008). '
                        'Improving fluid intelligence with training on working memory. '
                        'Proceedings of the National Academy of Sciences, 105(19), 6829–6833.',
                        style: tc.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Icon(Icons.open_in_new,
                              size: 13, color: cs.primary),
                          const Gap(4),
                          Text(
                            'View Paper',
                            style: tc.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── How the game works ─────────────────────────────────────────────
          _Section(
            title: 'How It Works',
            icon: Icons.grid_view_rounded,
            children: [
              _InfoRow(
                icon: Icons.grid_on,
                label: '3×3 grid',
                detail: '8 positions (centre excluded)',
              ),
              _InfoRow(
                icon: Icons.music_note,
                label: 'Letters',
                detail: '6 consonants per block, no vowels',
              ),
              _InfoRow(
                icon: Icons.timer,
                label: 'Each trial',
                detail: '500 ms stimulus + 2,500 ms gap = 3 s total',
              ),
              _InfoRow(
                icon: Icons.repeat,
                label: 'Trials per block',
                detail: '20 + N trials',
              ),
              const Gap(8),
              Text(
                'Each trial shows a square at one of 8 positions while playing a consonant letter simultaneously. '
                'Your job: press the POSITION button if the current position matches N steps ago, and/or press the AUDIO button if the current letter matches N steps ago.',
                style: tc.bodyMedium,
              ),
            ],
          ),

          // ── Target distribution ────────────────────────────────────────────
          _Section(
            title: 'Target Distribution per Block',
            icon: Icons.bar_chart_rounded,
            children: [
              _InfoRow(
                icon: Icons.compare_arrows,
                label: 'Visual targets',
                detail: '6 (4 visual-only + 2 dual)',
              ),
              _InfoRow(
                icon: Icons.hearing,
                label: 'Audio targets',
                detail: '6 (4 audio-only + 2 dual)',
              ),
              _InfoRow(
                icon: Icons.link,
                label: 'Dual targets',
                detail: '2 (both position AND audio match)',
              ),
              const Gap(4),
              Text(
                'Targets are distributed pseudo-randomly throughout each block to ensure the exact counts above are always maintained.',
                style: tc.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          // ── Daily Training Session ─────────────────────────────────────────
          _Section(
            title: 'Daily Training Session',
            icon: Icons.calendar_today_rounded,
            children: [
              _InfoRow(
                icon: Icons.format_list_numbered,
                label: 'Blocks per day',
                detail: '20',
              ),
              _InfoRow(
                icon: Icons.access_time,
                label: 'Daily time',
                detail: '≈ 25 minutes',
              ),
              const Gap(4),
              Text(
                'Complete 20 blocks each day to maintain your streak. Your progress is saved automatically after each block.',
                style: tc.bodyMedium,
              ),
            ],
          ),

          // ── N-level adaptation ─────────────────────────────────────────────
          _Section(
            title: 'Adaptive Difficulty (N-Level)',
            icon: Icons.trending_up,
            children: [
              _InfoRow(
                icon: Icons.arrow_upward,
                label: 'N increases by 1',
                detail: 'if mistakes < 3 per modality',
              ),
              _InfoRow(
                icon: Icons.arrow_downward,
                label: 'N decreases by 1',
                detail: 'if mistakes > 5 per modality',
              ),
              _InfoRow(
                icon: Icons.horizontal_rule,
                label: 'N stays the same',
                detail: 'if mistakes = 3–5',
              ),
              const Gap(8),
              Text(
                '"Mistakes" counts both missed matches (a match you didn\'t press) AND false presses (pressing when there was no match). '
                'The maximum of the two modalities is used to determine adaptation.',
                style: tc.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          // ── Sandbox mode ───────────────────────────────────────────────────
          _Section(
            title: 'Practice Mode',
            icon: Icons.science_outlined,
            children: [
              Text(
                'Practice lets you freely practice at any N-level without affecting your training session record or N-level progression. '
                'Use it to warm up or explore higher N-levels at your own pace.',
                style: tc.bodyMedium,
              ),
            ],
          ),

          // ── Tips ───────────────────────────────────────────────────────────
          _Section(
            title: 'Tips',
            icon: Icons.lightbulb_outline,
            children: [
              Text(
                '• Train daily — consistency matters more than intensity.',
                style: tc.bodyMedium,
              ),
              const Gap(4),
              Text(
                '• Don\'t worry about missing — the difficulty adapts automatically.',
                style: tc.bodyMedium,
              ),
              const Gap(4),
              Text(
                '• Keep sessions at a comfortable time — fatigue reduces gains.',
                style: tc.bodyMedium,
              ),
              const Gap(4),
              Text(
                '• Research shows benefits appear after 20+ days of training.',
                style: tc.bodyMedium,
              ),
            ],
          ),

          const Gap(32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(10),
          ...children,
          const Gap(8),
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, detail;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const Gap(10),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
