import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'widgets/practice_mode_sheet.dart';
import '../../stats/domain/game_session.dart';
import '../../stats/domain/score_sheet_item.dart';
import '../../game/state/game_provider.dart';
import '../../training/state/training_provider.dart';
import '../../training/domain/training_models.dart';

/// Shown at the end of every block/session.
/// - Training mode: shows block stats + Next Block / Back to Training
/// - Practice mode: shows stats + N-level picker + One More Time
class GameResultScreen extends ConsumerWidget {
  final Object? extra; // route extra from /game (same map as GameScreen)
  const GameResultScreen({super.key, this.extra});

  String get _mode {
    final e = extra;
    if (e is Map) return (e['mode'] as String?) ?? 'practice';
    return 'practice';
  }

  int get _blockNumber {
    final e = extra;
    if (e is Map) return (e['blockNumber'] as int?) ?? 1;
    return 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameProvider);
    final theme = Theme.of(context);
    final isTraining = _mode == 'training';

    // Mistake counts for N-level adaptation info
    final posMistakes = gameState.falsePositionMatches;
    final posMisses = gameState.missedPositionMatches;
    final audMistakes = gameState.falseAudioMatches;
    final audMisses = gameState.missedAudioMatches;

    final nextN = adaptNLevel(
      currentN: gameState.currentNLevel,
      positionMistakes: posMistakes + posMisses,
      audioMistakes: audMistakes + audMisses,
    );
    final nChanged = nextN != gameState.currentNLevel;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Title ────────────────────────────────────────────────
                FadeInDown(
                  child: Text(
                    isTraining
                        ? 'BLOCK $_blockNumber COMPLETE'
                        : 'SESSION COMPLETE',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(28),

                // ── Score Card ───────────────────────────────────────────
                FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildScoreCard(
                    context,
                    gameState,
                    posMistakes,
                    posMisses,
                    audMistakes,
                    audMisses,
                  ),
                ),
                const Gap(20),

                // ── N-level adaptation banner (training only) ────────────
                if (isTraining)
                  FadeIn(
                    delay: const Duration(milliseconds: 350),
                    child: _NAdaptBanner(
                      currentN: gameState.currentNLevel,
                      nextN: nextN,
                      nChanged: nChanged,
                    ),
                  ),

                const Gap(28),

                // ── Action Buttons ───────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child:
                      isTraining
                          ? _TrainingActions(
                            blockNumber: _blockNumber,
                            currentN: gameState.currentNLevel,
                          )
                          : _PracticeActions(currentN: gameState.currentNLevel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    dynamic state,
    int posMistakes,
    int posMisses,
    int audMistakes,
    int audMisses,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BigStat(
                label: 'N-Level',
                value: '${state.currentNLevel}',
                accent: cs.primary,
              ),
              _BigStat(
                label: 'Score',
                value: '${state.score}',
                accent: cs.secondary,
              ),
            ],
          ),
          const Divider(height: 28),
          _statRow(context, 'Position Hits', '${state.correctPositionMatches}'),
          _statRow(context, 'Audio Hits', '${state.correctAudioMatches}'),
          const Gap(8),
          _statRow(
            context,
            'Position Mistakes',
            '$posMistakes',
            color: posMistakes > 0 ? Colors.red : Colors.green,
          ),
          _statRow(
            context,
            'Audio Mistakes',
            '$audMistakes',
            color: audMistakes > 0 ? Colors.red : Colors.green,
          ),
          const Gap(8),
          _statRow(
            context,
            'Position Misses',
            '$posMisses',
            color: posMisses > 0 ? Colors.red : Colors.green,
          ),
          _statRow(
            context,
            'Audio Misses',
            '$audMisses',
            color: audMisses > 0 ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── N-level adaptation banner ───────────────────────────────────────────────
class _NAdaptBanner extends StatelessWidget {
  final int currentN, nextN;
  final bool nChanged;
  const _NAdaptBanner({
    required this.currentN,
    required this.nextN,
    required this.nChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!nChanged) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.horizontal_rule, color: Colors.orange, size: 18),
            const Gap(8),
            Text(
              'N stays at N-$currentN',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    final up = nextN > currentN;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (up ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (up ? Colors.green : Colors.red).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            up ? Icons.arrow_upward : Icons.arrow_downward,
            color: up ? Colors.green : Colors.red,
            size: 18,
          ),
          const Gap(8),
          Text(
            up ? 'Great! N-level → N-$nextN' : 'N-level → N-$nextN',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: up ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Training-mode actions ────────────────────────────────────────────────────
class _TrainingActions extends ConsumerWidget {
  final int blockNumber;
  final int currentN;
  const _TrainingActions({required this.blockNumber, required this.currentN});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(trainingDayProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final day = dayAsync.value;
    final profile = profileAsync.value;
    final completedBlocks = day?.completedBlocks ?? blockNumber;
    final isSessionDone = day?.isComplete ?? false;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            icon: Icon(
              isSessionDone
                  ? Icons.check_circle_outline
                  : Icons.play_arrow_rounded,
            ),
            label: Text(
              isSessionDone
                  ? 'SESSION COMPLETE ✓'
                  : 'NEXT BLOCK (${completedBlocks + 1}/20)',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed:
                isSessionDone
                    ? () {
                      ref.read(gameProvider.notifier).stopGame();
                      context.go('/');
                    }
                    : () {
                      final nextN = profile?.currentNLevel ?? currentN;
                      final nextBlock = completedBlocks + 1;
                      ref.read(gameProvider.notifier).stopGame();
                      context.go(
                        '/game',
                        extra: {
                          'nLevel': nextN,
                          'mode': 'training',
                          'blockNumber': nextBlock,
                        },
                      );
                    },
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                ref.read(gameProvider.notifier).stopGame();
                context.pushReplacement('/training');
              },
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text('Progress'),
            ),
            const Gap(8),
            TextButton.icon(
              onPressed: () {
                // Use cached session from notifier — guaranteed to have full
                // scoreSheet data regardless of any provider rebuilds.
                final session = ref.read(gameProvider.notifier).lastSession;
                if (session == null) return;
                context.push('/stats/details', extra: session);
              },
              icon: const Icon(Icons.table_chart, size: 16),
              label: const Text('Score Sheet'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Practice-mode actions ────────────────────────────────────────────────────
class _PracticeActions extends ConsumerWidget {
  final int currentN;
  const _PracticeActions({required this.currentN});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // One More Time — opens practice mode picker
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            icon: const Icon(Icons.replay_rounded),
            label: const Text(
              'TRY AGAIN',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ref.read(gameProvider.notifier).stopGame();
              showPracticePickerDialog(context);
            },
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                ref.read(gameProvider.notifier).stopGame();
                context.go('/');
              },
              icon: const Icon(Icons.home, size: 16),
              label: const Text('Home'),
            ),
            const Gap(8),
            TextButton.icon(
              onPressed: () {
                final gameState = ref.read(gameProvider);
                final session = GameSession(
                  id: 'temp',
                  date: DateTime.now(),
                  nLevel: gameState.currentNLevel,
                  score: gameState.score,
                  totalTrials: gameState.totalTrials,
                  correctPosition: gameState.correctPositionMatches,
                  correctAudio: gameState.correctAudioMatches,
                  mistakes:
                      gameState.falsePositionMatches +
                      gameState.falseAudioMatches +
                      gameState.missedPositionMatches +
                      gameState.missedAudioMatches,
                  scoreSheet:
                      gameState.trialResults
                          .map(
                            (t) => ScoreSheetItem(
                              trialNumber: t.trialNumber,
                              positionIndex: t.positionIndex,
                              audioLetter: t.audioLetter,
                              isPositionMatch: t.isPositionMatch,
                              isAudioMatch: t.isAudioMatch,
                              userPositionPressed: t.userPositionPressed,
                              userAudioPressed: t.userAudioPressed,
                              positionScore: t.positionScore,
                              audioScore: t.audioScore,
                              totalScore: t.totalScore,
                            ),
                          )
                          .toList(),
                );
                context.push('/stats/details', extra: session);
              },
              icon: const Icon(Icons.table_chart, size: 16),
              label: const Text('Score Sheet'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label, value;
  final Color accent;
  const _BigStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
