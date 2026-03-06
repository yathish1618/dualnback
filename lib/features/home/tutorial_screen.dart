import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../game/presentation/widgets/grid_cell.dart';
import '../game/services/platform_audio/mobile_player.dart'
    if (dart.library.html) '../game/services/platform_audio/web_player.dart';

// ---------------------------------------------------------------------------
// Demo trial data  (N = 2, 5 trials)
// Trial 3 → position match (vs Trial 1)
// Trial 4 → audio   match  (vs Trial 2)
// Trial 5 → neither
// ---------------------------------------------------------------------------
class _Trial {
  final int position; // 0-8 grid index
  final String letter;
  final String positionLabel;
  const _Trial({
    required this.position,
    required this.letter,
    required this.positionLabel,
  });
}

const List<_Trial> _demo = [
  _Trial(position: 0, letter: 'C', positionLabel: 'Top-Left'),
  _Trial(position: 5, letter: 'H', positionLabel: 'Middle-Right'),
  _Trial(position: 0, letter: 'K', positionLabel: 'Top-Left'), // pos match T1
  _Trial(
    position: 6,
    letter: 'H',
    positionLabel: 'Bottom-Left',
  ), // aud match T2
  _Trial(position: 2, letter: 'R', positionLabel: 'Top-Right'), // no match
];
const int _nLevel = 2;

// ---------------------------------------------------------------------------
// Phase definitions
// Each phase has a narration message and an action to perform (optional).
// ---------------------------------------------------------------------------
enum _PhaseAction { none, highlightN, showGrid, showTrialExplain, trial, wrap }

class _Phase {
  final String narration;
  final _PhaseAction action;
  final int? trialIndex; // only when action == trial
  final bool emphasizeButtons; // pulse the pos/aud buttons
  const _Phase({
    required this.narration,
    this.action = _PhaseAction.none,
    this.trialIndex,
    this.emphasizeButtons = false,
  });
}

const List<_Phase> _phases = [
  // 0 – N-level intro
  _Phase(
    narration:
        "Welcome! Let's walk through a real Dual N-Back game together.\n\n"
        "You will see a badge in the top-right. That's your **N-level** — the key number of this game.",
    action: _PhaseAction.highlightN,
  ),
  // 1 – N = 2 example
  _Phase(
    narration:
        "**Game Summary:**\n"
        "• Each game (also called as block) consists of **N + 2** trials.\n"
        "• In each trial, you will simultaneously see a position flashing along with the sound of a letter.\n"
        "• Your goal is to memorise and compare the current trial with what happened **N** trials ago.\n"
        "\nWe'll use **N = 2** for this demo.",
    action: _PhaseAction.highlightN,
  ),
  // 2 – Grid intro
  _Phase(
    narration:
        "Here's the game board — a **3 × 3 grid**.\n\n"
        "• The centre square is always empty.\n"
        "• That leaves us with **8 active cells**.\n\n",
    action: _PhaseAction.showGrid,
  ),
  // 3 – Trial concept
  _Phase(
    narration:
        "In each trial - \n\n"
        "• A square **flashes** on the grid (position).\n"
        "• You simultaneously **hear a letter** (audio).\n\n"
        "• For **N = 2**, your job is to remember what happened **2 trials ago** and compare it with the current trial.",
    action: _PhaseAction.showTrialExplain,
  ),
  // 4 – Trial 1
  _Phase(
    narration:
        "**Trial 1** — watch the grid and listen.\n"
        "Nothing to compare yet, just memorise the position and letter.\n"
        "A score sheet is given at the bottom to help you remember during this demo.",
    action: _PhaseAction.trial,
    trialIndex: 0,
  ),
  // 5 – Trial 2
  _Phase(
    narration:
        "**Trial 2** — another flash, another letter.\n"
        "You now have 2 trials in memory. Starting from the next trial, you'll need to decide!",
    action: _PhaseAction.trial,
    trialIndex: 1,
  ),
  // 6 – Trial 3 intro (pre-flash)
  _Phase(
    narration:
        "**Trial 3** is coming up.\n\n"
        "Remember Trial 1? It was **Top-Left, letter C**.\n"
        "Now we'll compare **Trial 3** with **Trial 1** (because N = 2).\n"
        "• If position of Trial 3 is also Top-Left → tap **Position** i.e., Position has matched.\n"
        "• If letter of Trial 3 is also C → tap **Audio** i.e., Audio has matched.",
    action: _PhaseAction.showGrid,
    emphasizeButtons: false,
  ),
  // 7 – Trial 3 live
  _Phase(
    narration:
        "**Position matched Trial 1!** Both are Top-Left.\n\nTap the **Position** button when you see a match like this! ✅",
    action: _PhaseAction.trial,
    trialIndex: 2,
    emphasizeButtons: true,
  ),
  // 8 – Trial 4 live
  _Phase(
    narration:
        "**Trial 4** vs Trial 2 (Middle-Right, H).\n"
        "Watch and listen... 🎵\n\nThe **letter matched** — both say 'H'! Tap **Audio** when the sound repeats. ✅",
    action: _PhaseAction.trial,
    trialIndex: 3,
    emphasizeButtons: true,
  ),
  // 9 – Trial 5 live
  _Phase(
    narration:
        "**Trial 5** vs Trial 3 (Top-Left, K).\n"
        "Watch and listen...\n\nNeither position nor audio matches — **don't press anything**. Correct rejections count too! ✅",
    action: _PhaseAction.trial,
    trialIndex: 4,
    emphasizeButtons: false,
  ),
  // 10 – Wrap up
  _Phase(
    narration:
        "That's Dual N-Back! 🧠\n\n"
        "• Match trials correctly to increase your N-level.\n"
        "• Make mistakes and it drops.\n\n"
        "It's designed to always challenge your limits!",
    action: _PhaseAction.wrap,
  ),
  // 11 - Training
  _Phase(
    narration:
        "**Daily Training** is your main workout:\n\n"
        "• Complete **20 blocks** per day to build your streak.\n"
        "• Each block has **N + 2** trials.\n"
        "• Track your progress over time! 📈",
    action: _PhaseAction.wrap,
  ),
  // 12 - Practice
  _Phase(
    narration:
        "**Practice Mode**\n\n"
        "• Warm up or try a specific N-level.\n"
        "• It won't affect your daily stats or streak. 🧪",
    action: _PhaseAction.wrap,
  ),
  // 13 - Final
  _Phase(
    narration:
        "You're all set! ✅\n\n"
        "Start your first session on the home screen and begin upgrading your working memory.",
    action: _PhaseAction.wrap,
  ),
];

// ---------------------------------------------------------------------------
// Letter audio timestamps (same as AudioService)
// ---------------------------------------------------------------------------
const Map<String, ({int startMs, int durationMs})> _letterTs = {
  'C': (startMs: 2192, durationMs: 1164),
  'H': (startMs: 8120, durationMs: 1164),
  'K': (startMs: 11507, durationMs: 1165),
  'R': (startMs: 19658, durationMs: 1270),
};

// ===========================================================================
// TutorialScreen
// ===========================================================================
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  int _phase = 0;
  bool _gridActive = false;
  int? _activeCell;
  String? _activeLetter;
  bool _trialRunning = false;

  // History of revealed trials for the debug table
  final List<_Trial> _history = [];
  // Which rows have match status computed (trial index >= nLevel)
  bool _showButtons = false;
  bool _pulseButtons = false;

  Timer? _trialTimer;
  Timer? _stopTimer;

  final PlatformAudioPlayer _player = PlatformAudioPlayer();
  bool _audioLoaded = false;

  late AnimationController _nBadgePulse;

  @override
  void initState() {
    super.initState();
    _nBadgePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // Preload audio immediately
    _player
        .load()
        .then((_) {
          if (mounted) _audioLoaded = true;
        })
        .catchError((e) {
          debugPrint('[Tutorial] audio preload error: $e');
        });
  }

  @override
  void dispose() {
    _trialTimer?.cancel();
    _stopTimer?.cancel();
    _nBadgePulse.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  bool get _isLastPhase => _phase == _phases.length - 1;

  void _next() {
    if (_trialRunning) return;
    if (_isLastPhase) {
      context.pop();
      return;
    }
    final nextPhase = _phase + 1;
    final p = _phases[nextPhase];
    setState(() {
      _phase = nextPhase;
      _showButtons = p.emphasizeButtons || nextPhase >= 7;
      _pulseButtons = p.emphasizeButtons;
    });
    if (p.action == _PhaseAction.trial && p.trialIndex != null) {
      _runTrial(p.trialIndex!);
    }
  }

  void _skip() {
    _trialTimer?.cancel();
    _stopTimer?.cancel();
    context.pop();
  }

  // ── Trial playback ────────────────────────────────────────────────────────

  Future<void> _runTrial(int index) async {
    if (_trialRunning) return;
    final trial = _demo[index];

    setState(() {
      _trialRunning = true;
      _gridActive = true;
      _activeCell = trial.position;
      _activeLetter = trial.letter;
      // Add to history immediately (row appears at trial start)
      if (!_history.contains(trial)) _history.add(trial);
    });

    // Play letter audio
    await _playLetter(trial.letter);

    // Keep grid lit for 1.5 s then dim
    _trialTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _gridActive = false;
          _trialRunning = false;
        });
      }
    });
  }

  Future<void> _playLetter(String letter) async {
    final ts = _letterTs[letter.toUpperCase()];
    if (ts == null) return;
    _stopTimer?.cancel();
    try {
      if (!_audioLoaded) {
        await _player.load();
        _audioLoaded = true;
      }
      await _player.playFromMs(ts.startMs, ts.durationMs, letter);
      if (!kIsWeb) {
        _stopTimer = Timer(Duration(milliseconds: ts.durationMs), () {
          _player.stopAfterMs(0, letter);
        });
      }
    } catch (e) {
      debugPrint('[Tutorial] audio error: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final phase = _phases[_phase];
    final isHighlightN = phase.action == _PhaseAction.highlightN;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Close + Skip bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _skip,
                    tooltip: 'Exit tutorial',
                  ),
                  const Spacer(),
                  Text(
                    'How to Play  •  ${_phase + 1} / ${_phases.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _skip, child: const Text('SKIP')),
                ],
              ),
            ),

            // ── Progress bar ──────────────────────────────────────────────
            LinearProgressIndicator(
              value: (_phase + 1) / _phases.length,
              minHeight: 3,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Narration card ─────────────────────────────────────
                    _NarrationCard(phase: _phase, phases: _phases),

                    const Gap(16),

                    // ── Mini game area ─────────────────────────────────────
                    if (_phase < 10)
                      _buildGameArea(context, cs, isHighlightN)
                    else if (_phase == 11)
                      _buildTrainingPreview(context, cs),

                    const Gap(16),

                    // ── History table ──────────────────────────────────────
                    if (_history.isNotEmpty && _phase < 10)
                      _buildHistoryTable(context, cs),

                    const Gap(12),
                  ],
                ),
              ),
            ),

            // ── Next button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _trialRunning ? null : _next,
                  icon: Icon(
                    _isLastPhase
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _isLastPhase ? "LET'S PLAY!" : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    ColorScheme cs,
    bool isHighlightN,
  ) {
    final phase = _phases[_phase];
    final showGrid =
        phase.action != _PhaseAction.highlightN &&
        phase.action != _PhaseAction.none;
    final totalTrials = _demo.length;
    final currentTrial = _history.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // ── Header row: N badge + letter display ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // N-level badge (pulsing when highlighted)
              ScaleTransition(
                scale:
                    isHighlightN
                        ? _nBadgePulse
                        : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:
                        isHighlightN
                            ? [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.5),
                                blurRadius: 16,
                              ),
                            ]
                            : null,
                  ),
                  child: Row(
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
                      const Gap(4),
                      const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (showGrid) const Gap(24),

              // Trial Counter
              if (showGrid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Trial $currentTrial / $totalTrials',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

              if (_activeLetter != null && showGrid) ...[
                const Gap(24),
                // Current letter
                Column(
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: cs.secondary,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _gridActive ? _activeLetter! : '?',
                        key: ValueKey('$_gridActive$_activeLetter'),
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: _gridActive ? cs.secondary : cs.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (showGrid && _activeLetter == null) ...[
                const Gap(24),
                Column(
                  children: [
                    Icon(Icons.volume_up_rounded, size: 20, color: cs.outline),
                    Text(
                      '?',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: cs.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // ── Grid ──────────────────────────────────────────────────────
          if (showGrid) ...[
            const Gap(16),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9, (i) {
                    if (i == 4) {
                      return const SizedBox.shrink(); // Middle center is empty
                    }
                    final isActive = _gridActive && i == _activeCell;
                    return GridCell(
                      index: i,
                      isActive: isActive,
                      activeColor: cs.primary,
                    );
                  }),
                ),
              ),
            ),
          ],

          // ── Control buttons (disabled, just for show) ──────────────
          if (_showButtons) ...[const Gap(16), _buildControlButtons(cs)],
        ],
      ),
    );
  }

  Widget _buildControlButtons(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          label: 'Position',
          icon: Icons.grid_on_rounded,
          isPulsing: _pulseButtons,
          color: cs.primary,
        ),
        const Gap(16),
        _ControlButton(
          label: 'Audio',
          icon: Icons.volume_up_rounded,
          isPulsing: _pulseButtons,
          color: cs.secondary,
        ),
      ],
    );
  }

  Widget _buildHistoryTable(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.table_chart_outlined, size: 16, color: cs.primary),
            const Gap(6),
            Text(
              'Trial history  (N = $_nLevel)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 32,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            columnSpacing: 18,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: cs.onSurface,
            ),
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Position')),
              DataColumn(label: Text('Letter')),
              DataColumn(label: Text('Pos Match?')),
              DataColumn(label: Text('Audio Match?')),
            ],
            rows: List.generate(_history.length, (i) {
              final t = _history[i];
              final canCompare = i >= _nLevel;
              String posMatch = '–';
              String audMatch = '–';
              Color? rowColor;

              // The relevant target to highlight matches against
              final targetIndex =
                  (_history.isNotEmpty && _trialRunning)
                      ? _history.length - 1
                      : -1;

              if (canCompare) {
                final ref = _history[i - _nLevel];
                final pm = t.position == ref.position;
                final am = t.letter == ref.letter;
                posMatch = pm ? '✅ Yes' : '❌ No';
                audMatch = am ? '✅ Yes' : '❌ No';
              }

              // Highlight rows involved in a match comparison for the *current* trial
              if (targetIndex >= _nLevel) {
                final refIndex = targetIndex - _nLevel;
                if ((i == targetIndex || i == refIndex)) {
                  final targetTrial = _history[targetIndex];
                  final refTrial = _history[refIndex];
                  if (targetTrial.position == refTrial.position ||
                      targetTrial.letter == refTrial.letter) {
                    rowColor = cs.primaryContainer.withValues(alpha: 0.35);
                  }
                }
              }

              // Highlight the current (latest) trial row lightly if it's not strongly highlighted above
              final isCurrent = i == _history.length - 1 && _trialRunning;
              if (isCurrent && rowColor == null) {
                rowColor = cs.primary.withValues(alpha: 0.12);
              }

              return DataRow(
                color: WidgetStateProperty.all(rowColor),
                cells: [
                  DataCell(
                    Text(
                      '${i + 1}',
                      style:
                          isCurrent
                              ? TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              )
                              : null,
                    ),
                  ),
                  DataCell(Text(t.positionLabel)),
                  DataCell(
                    Text(
                      t.letter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.secondary,
                      ),
                    ),
                  ),
                  DataCell(Text(posMatch)),
                  DataCell(Text(audMatch)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingPreview(BuildContext context, ColorScheme cs) {
    // A mock block grid preview matching training_session_screen's styling
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Daily Blocks',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const Gap(16),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 500 ? 10 : 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final blockNum = index + 1;
                  // Mock first 3 blocks as done, 4 as running, rest as pending
                  Color bg;
                  Color fg;
                  Widget child;
                  bool isNext = false;

                  if (index < 3) {
                    // completed
                    bg = Colors.green.withValues(alpha: 0.2);
                    fg = Colors.green;
                    child = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$blockNum',
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Icon(Icons.check_circle_outline, color: fg, size: 14),
                      ],
                    );
                  } else if (index == 3) {
                    isNext = true;
                    bg = cs.primary.withValues(alpha: 0.15);
                    fg = cs.primary;
                    child = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$blockNum',
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
                      '$blockNum',
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    );
                  }

                  return Container(
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
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narration card with animated text transitions
// ---------------------------------------------------------------------------
class _NarrationCard extends StatelessWidget {
  final int phase;
  final List<_Phase> phases;
  const _NarrationCard({required this.phase, required this.phases});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = phases[phase].narration;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder:
          (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
      child: Container(
        key: ValueKey(phase),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.6),
              cs.secondaryContainer.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: _RichNarration(text: text),
      ),
    );
  }
}

// Renders `**bold**` markdown-style inline
class _RichNarration extends StatelessWidget {
  final String text;
  const _RichNarration({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(
        TextSpan(
          text: parts[i],
          style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      );
    }
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 15),
        children: spans,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Control button (disabled, pulsing highlight for guidance)
// ---------------------------------------------------------------------------
class _ControlButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPulsing;
  final Color color;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.isPulsing,
    required this.color,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.93,
      upperBound: 1.0,
    );
    _scale = _ctrl;
    if (widget.isPulsing) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ControlButton old) {
    super.didUpdateWidget(old);
    if (widget.isPulsing && !old.isPulsing) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPulsing && old.isPulsing) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              widget.isPulsing
                  ? widget.color.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                widget.isPulsing
                    ? widget.color.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.outlineVariant,
            width: widget.isPulsing ? 2 : 1,
          ),
          boxShadow:
              widget.isPulsing
                  ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Icon(widget.icon, color: widget.color, size: 22),
            const Gap(4),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (widget.isPulsing) ...[
              const Gap(4),
              Text(
                'TAP THIS!',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
