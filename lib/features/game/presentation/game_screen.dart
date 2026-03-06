import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../game/domain/game_state.dart';
import '../../settings/domain/game_settings_provider.dart';
import '../../game/state/game_provider.dart';
import '../../training/state/training_provider.dart';
import '../../training/domain/training_models.dart';
import '../services/audio_service.dart';
import 'widgets/grid_cell.dart';
import 'widgets/control_pad.dart';

class GameScreen extends ConsumerStatefulWidget {
  /// Route extra: `Map<String,dynamic>` with keys nLevel, mode, blockNumber
  /// OR legacy: plain int nLevel
  final Object? extra;

  const GameScreen({super.key, this.extra});

  int get nLevel {
    final e = extra;
    if (e is Map) return (e['nLevel'] as int?) ?? AppConstants.defaultNLabel;
    if (e is int) return e;
    return AppConstants.defaultNLabel;
  }

  String get mode {
    final e = extra;
    if (e is Map) return (e['mode'] as String?) ?? 'sandbox';
    return 'sandbox';
  }

  int get blockNumber {
    final e = extra;
    if (e is Map) return (e['blockNumber'] as int?) ?? 1;
    return 1;
  }

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(gameSettingsProvider);
      ref.read(audioServiceProvider).unlockAndPreload();
      ref
          .read(gameProvider.notifier)
          .startGame(
            widget.nLevel,
            debugMode: settings.debugModeEnabled,
            mode: widget.mode,
            blockNumber: widget.blockNumber,
            onBlockComplete:
                widget.mode == 'training'
                    ? (blockResult) async {
                      final profileNotifier = ref.read(
                        userProfileProvider.notifier,
                      );
                      final dayNotifier = ref.read(
                        trainingDayProvider.notifier,
                      );
                      final dayValue = ref.read(trainingDayProvider).value;
                      final isLast =
                          (dayValue?.blocks.length ?? 0) + 1 >=
                          AppConstants.blocksPerSession;
                      await profileNotifier.afterBlock(
                        positionMistakes: blockResult.positionMistakes,
                        audioMistakes: blockResult.audioMistakes,
                        isLastBlock: isLast,
                        today: dayValue?.date ?? '',
                      );
                      final updatedProfile =
                          ref.read(userProfileProvider).value ??
                          const UserProfile();
                      await dayNotifier.addBlockResult(
                        blockResult,
                        updatedProfile,
                      );
                    }
                    : null,
          );
    });
  }

  @override
  void dispose() {
    // AudioService is global/provider managed, or we could dispose it if we owned it.
    // Since it's a provider, we let access management handle it.
    // If we wanted to stop audio on exit, we could do it here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final audioService = ref.read(audioServiceProvider);
    final settings = ref.watch(gameSettingsProvider);

    // Audio Playback Listener
    ref.listen(gameProvider.select((s) => s.currentSignal), (prev, next) {
      if (next != null && next.audioLetter.isNotEmpty) {
        audioService.playLetter(next.audioLetter);
      }
    });

    // Vibration Feedback Listener
    ref.listen(gameProvider.select((s) => s.lastTrialCorrect), (prev, next) {
      if (next != null) {
        final settings = ref.read(gameSettingsProvider);
        if (settings.vibrationEnabled) {
          if (next == false) {
            HapticFeedback.heavyImpact();
          } else if (next == true) {
            HapticFeedback.lightImpact();
          }
        }
      }
    });

    // Per-button feedback — driven by independent timers in the notifier.
    // null = no feedback, true = correct (green), false = incorrect (red).
    final posFeedback = ref.watch(positionFeedbackProvider);
    final audFeedback = ref.watch(audioFeedbackProvider);
    final positionFeedbackColor =
        posFeedback == null ? null : (posFeedback ? Colors.green : Colors.red);
    final audioFeedbackColor =
        audFeedback == null ? null : (audFeedback ? Colors.green : Colors.red);

    // Listen for Game Status changes – navigate after the build frame completes
    ref.listen(gameProvider.select((s) => s.status), (prev, next) {
      if (next == GameStatus.finished) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pushReplacement('/results', extra: widget.extra);
          }
        });
      }
    });

    // Intercept back-navigation when a round is in progress
    final isActive =
        gameState.status == GameStatus.playing ||
        gameState.status == GameStatus.countdown;

    return PopScope(
      canPop: !isActive,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return; // already popped
        await _attemptPop(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, gameState),

                  const Gap(20),

                  // Game Grid
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            // Index 4 = center square — excluded per research paper
                            if (index == 4) {
                              return const SizedBox(); // invisible spacer
                            }
                            final isTarget =
                                gameState.currentSignal?.positionIndex == index;
                            return GridCell(
                              index: index,
                              isActive: isTarget,
                              activeColor: theme.colorScheme.secondary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  if (settings.debugModeEnabled)
                    SizedBox(
                      height: 220,
                      child: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 40,
                              dataRowMinHeight: 30,
                              dataRowMaxHeight: 30,
                              columnSpacing: 12,
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Pos')),
                                DataColumn(label: Text('Aud')),
                                DataColumn(label: Text('M-Pos')),
                                DataColumn(label: Text('M-Aud')),
                                DataColumn(label: Text('S-Pos')),
                                DataColumn(label: Text('S-Aud')),
                                DataColumn(label: Text('Total')),
                              ],
                              rows:
                                  [
                                    // ── Pending row (current trial, not yet evaluated) ──
                                    if (gameState.pendingSignal != null)
                                      () {
                                        final ps = gameState.pendingSignal!;
                                        final pRow = ps.positionIndex ~/ 3;
                                        final pCol = ps.positionIndex % 3;
                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                            theme.colorScheme.primary
                                                .withValues(alpha: 0.12),
                                          ),
                                          cells: [
                                            DataCell(
                                              Text(
                                                '${gameState.pendingTrialNumber}',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text('R${pRow + 1}:C${pCol + 1}'),
                                            ),
                                            DataCell(Text(ps.audioLetter)),
                                            DataCell(
                                              Text(
                                                '…',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '…',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '?',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '?',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '?',
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }(),
                                    // ── Completed trial rows ──────────────────────────
                                    ...gameState.trialResults.reversed.map((
                                      result,
                                    ) {
                                      final row = result.positionIndex ~/ 3;
                                      final col = result.positionIndex % 3;

                                      Color rowColor = Colors.transparent;
                                      if (result.positionScore == -1 ||
                                          result.audioScore == -1) {
                                        rowColor = Colors.red.withValues(
                                          alpha: 0.15,
                                        );
                                      } else if (result.positionScore == 1 ||
                                          result.audioScore == 1) {
                                        rowColor = Colors.green.withValues(
                                          alpha: 0.15,
                                        );
                                      }

                                      return DataRow(
                                        color: WidgetStateProperty.all(
                                          rowColor,
                                        ),
                                        cells: [
                                          DataCell(
                                            Text('${result.trialNumber}'),
                                          ),
                                          DataCell(
                                            Text('R${row + 1}:C${col + 1}'),
                                          ),
                                          DataCell(Text(result.audioLetter)),
                                          DataCell(
                                            Text(
                                              result.isPositionMatch
                                                  ? '✓'
                                                  : '–',
                                              style: TextStyle(
                                                color:
                                                    result.isPositionMatch
                                                        ? Colors.green
                                                        : theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              result.isAudioMatch ? '✓' : '–',
                                              style: TextStyle(
                                                color:
                                                    result.isAudioMatch
                                                        ? Colors.green
                                                        : theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.4,
                                                            ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            _buildScoreCell(
                                              result.positionScore,
                                              theme,
                                            ),
                                          ),
                                          DataCell(
                                            _buildScoreCell(
                                              result.audioScore,
                                              theme,
                                            ),
                                          ),
                                          DataCell(
                                            Text('${result.totalScore}'),
                                          ),
                                        ],
                                      );
                                    }),
                                  ].whereType<DataRow>().toList(),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Controls
                  ControlPad(
                    onPositionPressed:
                        () => ref.read(gameProvider.notifier).onPositionInput(),
                    onAudioPressed:
                        () => ref.read(gameProvider.notifier).onAudioInput(),
                    isPositionSelected: gameState.visualMatchPressed ?? false,
                    isAudioSelected: gameState.audioMatchPressed ?? false,
                    positionFeedbackColor: positionFeedbackColor,
                    audioFeedbackColor: audioFeedbackColor,
                  ),

                  const Gap(8),
                ],
              ),
            ),

            // Countdown Overlay
            if (gameState.status == GameStatus.countdown)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Text(
                  "${gameState.countdownValue}",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 120,
                  ),
                ),
              ),
          ],
        ),
      ),
    ); // end PopScope
  }

  Widget _buildHeader(BuildContext context, dynamic state) {
    final cs = Theme.of(context).colorScheme;
    final isTraining = widget.mode == 'training';
    final title = isTraining ? 'Block ${widget.blockNumber} / 20' : 'Practice';
    final settings = ref.read(gameSettingsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 12),
      child: Row(
        children: [
          // ── Back button ──────────
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final gameState = ref.read(gameProvider);
              final isActive =
                  gameState.status == GameStatus.playing ||
                  gameState.status == GameStatus.countdown;

              if (!isActive) {
                ref.read(gameProvider.notifier).stopGame();
                context.pop();
              } else {
                await _attemptPop(context);
              }
            },
          ),
          // ── Title ─────────────────────────────────────────────────────────
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // ── Trial counter ─────────────────────────────────────────────────
          Column(
            children: [
              Text(
                '${(state.currentTrial + 1).clamp(1, state.totalTrials)} / ${state.totalTrials}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${state.score}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // ── Debug pause button (was Positioned overlay — caused overlap) ───
          if (settings.debugModeEnabled)
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                state.isPaused ? Icons.play_arrow : Icons.pause,
                size: 26,
                color: cs.primary,
              ),
              onPressed: () {
                ref.read(gameProvider.notifier).togglePause();
              },
            ),
          const SizedBox(width: 4),
          // ── N-level badge ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${state.currentNLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCell(int score, ThemeData theme) {
    Color color = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    if (score == 1) color = Colors.green;
    if (score == -1) color = Colors.red;

    return Text(
      '$score',
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _attemptPop(BuildContext context) async {
    // Request confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Quit this round?'),
            content: const Text(
              'Your progress in this round will be lost. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Continue'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                child: const Text('Quit'),
              ),
            ],
          ),
    );

    if ((confirmed ?? false) && context.mounted) {
      ref.read(gameProvider.notifier).stopGame();
      context.pop();
    }
  }
}
