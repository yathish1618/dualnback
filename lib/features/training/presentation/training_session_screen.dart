import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../state/training_provider.dart';
import '../domain/training_models.dart';
import '../../stats/domain/game_session.dart';
import '../../stats/domain/score_sheet_item.dart';

class TrainingSessionScreen extends ConsumerWidget {
  const TrainingSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayAsync = ref.watch(trainingDayProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Training'),
        centerTitle: true,
        // Always go home — back from /results pushes a new /training, pop() goes to /results
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: dayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (day) {
          final profile = profileAsync.value ?? const UserProfile();
          final completed = day.completedBlocks;
          final total = AppTrainingConstants.blocksPerSession;
          final isAllDone = day.isComplete;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row: title + N-badge ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAllDone
                              ? 'Session Complete! 🎉'
                              : 'Block ${completed + 1} of $total',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // N-badge (same as elsewhere)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'N',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${profile.currentNLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // ── Block grid ─────────────────────────────────────────
                  Text(
                    'Blocks',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                  const Gap(8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 500;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 10 : 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: total,
                        itemBuilder: (context, index) {
                          final blockNum = index + 1;
                          BlockResult? result;
                          if (index < day.blocks.length) {
                            result = day.blocks[index];
                          }
                          final isNext = index == completed && !isAllDone;

                          return _BlockTile(
                            blockNumber: blockNum,
                            result: result,
                            isNext: isNext,
                          );
                        },
                      );
                    },
                  ),
                  const Gap(20),

                  // ── Block history (all completed blocks, with score sheet link) ──
                  if (day.blocks.isNotEmpty) ...[
                    Text(
                      'Block History',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                    const Gap(6),
                    Expanded(
                      child: ListView(
                        children:
                            day.blocks.reversed
                                .map(
                                  (b) => _BlockHistoryRow(
                                    block: b,
                                    onScoreSheet: () {
                                      // Build a minimal GameSession for score sheet viewing
                                      final session = GameSession(
                                        id: 'block_${b.blockNumber}',
                                        date: b.completedAt,
                                        nLevel: b.nLevel,
                                        score: 0,
                                        totalTrials: 0,
                                        correctPosition: 0,
                                        correctAudio: 0,
                                        mistakes:
                                            b.positionMistakes +
                                            b.audioMistakes,
                                        scoreSheet:
                                            b.trialData
                                                .map(
                                                  (t) => ScoreSheetItem(
                                                    trialNumber:
                                                        t['trialNumber']
                                                            as int? ??
                                                        0,
                                                    positionIndex:
                                                        t['positionIndex']
                                                            as int? ??
                                                        0,
                                                    audioLetter:
                                                        t['audioLetter']
                                                            as String? ??
                                                        '',
                                                    isPositionMatch:
                                                        t['isPositionMatch']
                                                            as bool? ??
                                                        false,
                                                    isAudioMatch:
                                                        t['isAudioMatch']
                                                            as bool? ??
                                                        false,
                                                    userPositionPressed:
                                                        t['userPositionPressed']
                                                            as bool? ??
                                                        false,
                                                    userAudioPressed:
                                                        t['userAudioPressed']
                                                            as bool? ??
                                                        false,
                                                    positionScore:
                                                        t['positionScore']
                                                            as int? ??
                                                        0,
                                                    audioScore:
                                                        t['audioScore']
                                                            as int? ??
                                                        0,
                                                    totalScore:
                                                        t['totalScore']
                                                            as int? ??
                                                        0,
                                                  ),
                                                )
                                                .toList(),
                                      );
                                      context.push(
                                        '/stats/details',
                                        extra: session,
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // ── CTA button ─────────────────────────────────────────
                  const Gap(12),
                  if (!isAllDone)
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          'START BLOCK ${completed + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 15,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          context.push(
                            '/game',
                            extra: {
                              'nLevel': profile.currentNLevel,
                              'mode': 'training',
                              'blockNumber': completed + 1,
                            },
                          );
                        },
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton(
                        onPressed: () => context.go('/'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'BACK TO HOME',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  final int blockNumber;
  final BlockResult? result;
  final bool isNext;

  const _BlockTile({
    required this.blockNumber,
    this.result,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    Widget child;

    if (result != null) {
      final mistakes = result!.positionMistakes + result!.audioMistakes;
      bg =
          mistakes < 6
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.15);
      fg = mistakes < 6 ? Colors.green : Colors.orange;
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$blockNumber',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Icon(Icons.check_circle_outline, color: fg, size: 14),
        ],
      );
    } else if (isNext) {
      bg = cs.primary.withValues(alpha: 0.15);
      fg = cs.primary;
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$blockNumber',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Icon(Icons.play_arrow, color: fg, size: 14),
        ],
      );
    } else {
      bg = cs.surfaceContainerHighest.withValues(alpha: 0.4);
      fg = cs.onSurface.withValues(alpha: 0.3);
      child = Text(
        '$blockNumber',
        style: TextStyle(color: fg, fontWeight: FontWeight.w500, fontSize: 13),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border:
            isNext
                ? Border.all(color: cs.primary, width: 2)
                : Border.all(color: Colors.transparent),
      ),
      child: Center(child: child),
    );
  }
}

class _BlockHistoryRow extends StatelessWidget {
  final BlockResult block;
  final VoidCallback onScoreSheet;

  const _BlockHistoryRow({required this.block, required this.onScoreSheet});

  @override
  Widget build(BuildContext context) {
    final total = block.positionMistakes + block.audioMistakes;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${block.blockNumber}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Gap(10),
          Text(
            'N-${block.nLevel}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.secondary),
          ),
          const Gap(8),
          Text(
            '$total mistakes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: total < 6 ? Colors.green : Colors.orange,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onScoreSheet,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Score Sheet', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
