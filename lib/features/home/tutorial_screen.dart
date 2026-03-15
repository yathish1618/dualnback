import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../game/presentation/widgets/grid_cell.dart';
import '../game/services/platform_audio/mobile_player.dart'
    if (dart.library.html) '../game/services/platform_audio/web_player.dart';

// ---------------------------------------------------------------------------
// Demo data – N = 1, 5 trials
// Trial 1 : pos=0  (Top-Left),     letter=C  → nothing to compare
// Trial 2 : pos=0  (Top-Left),     letter=H  → position match vs T1
// Trial 3 : pos=5  (Middle-Right), letter=H  → audio match vs T2
// Trial 4 : pos=5  (Middle-Right), letter=H  → BOTH match vs T3
// Trial 5 : pos=2  (Top-Right),    letter=K  → neither match vs T4
// ---------------------------------------------------------------------------
const int _n = 1;

class _Trial {
  final int position;
  final String letter;
  final String posLabel;
  const _Trial({
    required this.position,
    required this.letter,
    required this.posLabel,
  });
}

const List<_Trial> _demo = [
  _Trial(position: 0, letter: 'C', posLabel: 'Top-Left'),
  _Trial(position: 0, letter: 'H', posLabel: 'Top-Left'), // pos match T1
  _Trial(position: 5, letter: 'H', posLabel: 'Mid-Right'), // aud match T2
  _Trial(position: 5, letter: 'H', posLabel: 'Mid-Right'), // both T3
  _Trial(position: 2, letter: 'K', posLabel: 'Top-Right'), // neither T4
];

// ---------------------------------------------------------------------------
// Audio sprite offsets
// ---------------------------------------------------------------------------
// Female-voice timestamps (Alphabet_female.oga) – matches game default
const Map<String, ({int startMs, int durationMs})> _letterTs = {
  'C': (startMs: 4301, durationMs: 1131),
  'H': (startMs: 16848, durationMs: 1339),
  'K': (startMs: 24382, durationMs: 1979),
};
const String _audioAsset = 'audio/Alphabet_female.oga';

// ---------------------------------------------------------------------------
// Highlight regions
// ---------------------------------------------------------------------------
enum _Region {
  none,
  nBadge,
  trialCounter,
  grid,
  scoreSheet,
  gridAndScore, // grid + scoresheet together
  posButton,
  audButton,
  bothButtons,
  textBox, // only the callout card highlighted (everything else dimmed)
}

enum _ExpectedMatch { none, position, audio, both }

class _Step {
  final String narration;
  final _Region highlight;
  final int? trialIndex;
  final _ExpectedMatch expected;

  const _Step({
    required this.narration,
    this.highlight = _Region.none,
    this.trialIndex,
    this.expected = _ExpectedMatch.none,
  });
}

const List<_Step> _steps = [
  // 0 – N badge
  _Step(
    narration: 'This is your **N-level**.\nLet\'s begin with N = **1**.',
    highlight: _Region.nBadge,
  ),
  // 1 – Trial counter
  _Step(
    narration:
        'Each game has 20 + N trials.\nSince N = 1, this game has **21 trials**.\n\nThe number below it is your score.',
    highlight: _Region.trialCounter,
  ),
  // 2 – Grid intro
  _Step(
    narration:
        'In each trial, one of the 8 cells **flashes**. Simultaneously you\'ll hear a **letter**.\n\nMemorise both the **position** and the **letter**.',
    highlight: _Region.grid,
  ),
  // 3 – Run trial 1 – highlight grid + scoresheet area
  _Step(
    narration:
        '**Trial 1** — watch the grid and listen.\nNothing to compare yet, just memorise.',
    highlight: _Region.grid,
    trialIndex: 0,
  ),
  // 4 – Score sheet explanation – highlight grid + scoresheet
  _Step(
    narration:
        'In this **demo**, a score sheet appears so you can follow along easily.\n(It won\'t be there in the real game.)',
    highlight: _Region.scoreSheet,
  ),
  // 5 – Run trial 2 + highlight scoresheet only
  _Step(
    narration:
        '**Trial 2.** Since N = 1, compare this trial with the previous one (**1 trial ago**).',
    highlight: _Region.scoreSheet,
    trialIndex: 1,
  ),
  // 6 – Position match – highlight only pos button
  _Step(
    narration:
        'Trial 1 was **Top-Left**. Trial 2 is also **Top-Left**.\nPosition **matches** → tap **POSITION**!',
    highlight: _Region.posButton,
    expected: _ExpectedMatch.position,
  ),
  // 7 – Run trial 3 + audio match – highlight only aud button
  _Step(
    narration:
        '**Trial 3.** Trial 2\'s letter was **H**. This letter is also **H**.\nAudio **matches** → tap **AUDIO**!',
    highlight: _Region.audButton,
    trialIndex: 2,
    expected: _ExpectedMatch.audio,
  ),
  // 8 – Run trial 4 + both match
  _Step(
    narration:
        '**Trial 4.** Same position AND letter as Trial 3.\nTap **both** buttons!',
    highlight: _Region.bothButtons,
    trialIndex: 3,
    expected: _ExpectedMatch.both,
  ),
  // 9 – Run trial 5 + no match – keep buttons visible for context
  _Step(
    narration:
        '**Trial 5.** Neither position nor audio matches Trial 4.\n\nDon\'t tap anything — correct rejections count too! ✅',
    highlight: _Region.bothButtons,
    trialIndex: 4,
  ),
  // 10 – N explanation – highlight N-badge
  _Step(
    narration:
        'N = **1** → compare with **1 trial ago**.\nN = **2** → compare with **2 trials ago**, and so on.',
    highlight: _Region.nBadge,
  ),
  // 11 – Dynamic N – highlight N-badge
  _Step(
    narration:
        'The game **automatically adjusts** N based on your accuracy.\n\nPlay well → N goes up. Make mistakes → N drops. Always at your limit! 🧠',
    highlight: _Region.nBadge,
  ),
  // 12 – Final / About
  _Step(
    narration:
        'You\'re all set! 🎉\n\nFor detailed rules and research behind the game, go to the [**About**] section.',
    highlight: _Region.textBox,
  ),
];

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
  int _stepIndex = 0;

  bool _trialRunning = false;
  int? _activeCell;
  bool _gridActive = false;
  final List<_Trial> _history = [];

  bool? _posFeedback;
  bool? _audFeedback;

  Timer? _trialTimer;
  Timer? _stopTimer;
  final PlatformAudioPlayer _player = PlatformAudioPlayer();
  bool _audioLoaded = false;

  // GlobalKeys for spotlight measurement
  final _keyNBadge = GlobalKey();
  final _keyTrialCounter = GlobalKey();
  final _keyGrid = GlobalKey();
  final _keyScoreSheet = GlobalKey();
  final _keyPosButton = GlobalKey();
  final _keyAudButton = GlobalKey();

  // N-badge pulse
  late AnimationController _badgePulse;

  // Cached spotlight rects (updated post-frame)
  List<Rect> _spotRects = [];
  // Bottom Y of the control pad (buttons), used to anchor bottom-pinned callout
  double? _controlPadBottom;

  @override
  void initState() {
    super.initState();
    _badgePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _player
        .load(_audioAsset)
        .then((_) {
          if (mounted) _audioLoaded = true;
        })
        .catchError((e) {
          debugPrint('[Tutorial] audio preload: $e');
        });

    // Force a rebuild after first frame so GlobalKey rects are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshSpotlight();
    });
  }

  @override
  void dispose() {
    _trialTimer?.cancel();
    _stopTimer?.cancel();
    _badgePulse.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Spotlight helpers ─────────────────────────────────────────────────────

  Rect? _rectFor(GlobalKey key) {
    final rb = key.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || !rb.hasSize) return null;
    final pos = rb.localToGlobal(Offset.zero);
    return pos & rb.size;
  }

  static Rect _pad(Rect r, double p) =>
      Rect.fromLTRB(r.left - p, r.top - p, r.right + p, r.bottom + p);

  void _refreshSpotlight() {
    if (!mounted) return;
    final step = _steps[_stepIndex];
    final rects = <Rect>[];
    switch (step.highlight) {
      case _Region.nBadge:
        final r = _rectFor(_keyNBadge);
        if (r != null) rects.add(_pad(r, 10));
      case _Region.trialCounter:
        final r = _rectFor(_keyTrialCounter);
        if (r != null) rects.add(_pad(r, 10));
      case _Region.grid:
        final g = _rectFor(_keyGrid);
        if (g != null) rects.add(_pad(g, 14));
      case _Region.scoreSheet:
        final s = _rectFor(_keyScoreSheet);
        if (s != null && s.height > 0) rects.add(_pad(s, 8));
      case _Region.gridAndScore:
        final g = _rectFor(_keyGrid);
        if (g != null) rects.add(_pad(g, 14));
        // Only add scoresheet if it has content
        if (_history.isNotEmpty) {
          final s = _rectFor(_keyScoreSheet);
          if (s != null && s.height > 0) rects.add(_pad(s, 8));
        }
      case _Region.posButton:
        final r = _rectFor(_keyPosButton);
        if (r != null) rects.add(_pad(r, 4));
      case _Region.audButton:
        final r = _rectFor(_keyAudButton);
        if (r != null) rects.add(_pad(r, 4));
      case _Region.bothButtons:
        final rp = _rectFor(_keyPosButton);
        final ra = _rectFor(_keyAudButton);
        if (rp != null) rects.add(_pad(rp, 4));
        if (ra != null) rects.add(_pad(ra, 4));
      case _Region.textBox:
        // No rects – the spotlight painter will dim everything;
        // we signal "text box only" by a sentinel rect that will be
        // handled specially in the painter via a flag.
        break;
      case _Region.none:
        break;
    }
    // Always compute the control-pad bottom so the callout can anchor below
    // the buttons regardless of which region is being highlighted.
    final rp = _rectFor(_keyPosButton);
    final ra = _rectFor(_keyAudButton);
    final padBottom = [
      if (rp != null) rp.bottom,
      if (ra != null) ra.bottom,
    ].fold<double>(0, (a, b) => a > b ? a : b);

    setState(() {
      _spotRects = rects;
      if (padBottom > 0) _controlPadBottom = padBottom;
    });
  }

  // Primary spotlight rect used to anchor callout bubble.
  // For gridAndScore the scoresheet (last rect) is the better anchor so the
  // callout positions itself BELOW the scoresheet, not behind it.
  Rect? get _primaryRect {
    if (_spotRects.isEmpty) return null;
    final h = _current.highlight;
    // gridAndScore: rects are [grid, scoreSheet]. Grid is now BELOW the
    // scoresheet, so use the grid rect (first) as the anchor — the callout
    // will sit just below the grid with the arrow pointing up at it.
    if (h == _Region.gridAndScore) return _spotRects.first;
    return _spotRects.first;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  bool get _isLast => _stepIndex == _steps.length - 1;
  _Step get _current => _steps[_stepIndex];

  void _next() {
    if (_trialRunning) return;
    if (_isLast) {
      context.pop();
      return;
    }
    _goTo(_stepIndex + 1);
  }

  void _previous() {
    if (_trialRunning) return;
    if (_stepIndex == 0) return;
    _goTo(_stepIndex - 1);
  }

  void _skip() {
    _trialTimer?.cancel();
    _stopTimer?.cancel();
    context.pop();
  }

  void _goTo(int idx) {
    _trialTimer?.cancel();
    _stopTimer?.cancel();
    final step = _steps[idx];
    setState(() {
      _stepIndex = idx;
      _posFeedback = null;
      _audFeedback = null;
      _gridActive = false;
      _activeCell = null;
      // Keep _spotRects as-is until the new measurement arrives to avoid
      // a flicker frame where the scrim shows with no transparent holes.
    });

    void scheduleMeasure(int ms) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (mounted && _stepIndex == idx) _refreshSpotlight();
      });
    }

    // Measure immediately after the first layout frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stepIndex == idx) _refreshSpotlight();
    });
    // Re-measure shortly after to catch any quick AnimatedSize transitions.
    scheduleMeasure(200);

    if (step.trialIndex != null) {
      // Start the trial after a short pause so the callout renders first.
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && _stepIndex == idx) _runTrial(step.trialIndex!);
      });
      // Re-measure after the trial + scoresheet AnimatedSize have fully
      // settled (trial runs for ~1850 ms; AnimatedSize adds ~250 ms).
      scheduleMeasure(2200);
      scheduleMeasure(2700);
    }
  }

  // ── Trial playback ─────────────────────────────────────────────────────────

  Future<void> _runTrial(int index) async {
    if (index >= _demo.length) return;
    final trial = _demo[index];

    // Ensure history is filled up to this index
    while (_history.length <= index) {
      _history.add(_demo[_history.length]);
    }

    setState(() {
      _trialRunning = true;
      _gridActive = true;
      _activeCell = trial.position;
    });

    await _playLetter(trial.letter);

    _trialTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _gridActive = false;
          _trialRunning = false;
        });
        // Re-measure after the scoresheet AnimatedSize finishes expanding
        // (AnimatedSize duration is 250 ms; add a small buffer).
        Future.delayed(const Duration(milliseconds: 320), () {
          if (mounted) _refreshSpotlight();
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
        await _player.load(_audioAsset);
        _audioLoaded = true;
      }
      await _player.playFromMs(ts.startMs, ts.durationMs, letter, _audioAsset);
      if (!kIsWeb) {
        _stopTimer = Timer(Duration(milliseconds: ts.durationMs), () {
          _player.stopAfterMs(0, letter);
        });
      }
    } catch (e) {
      debugPrint('[Tutorial] audio: $e');
    }
  }

  // ── Button tap ────────────────────────────────────────────────────────────

  void _handleTap(bool isPosition) {
    if (_trialRunning) return;
    final exp = _current.expected;
    bool correct = false;
    if (isPosition &&
        (exp == _ExpectedMatch.position || exp == _ExpectedMatch.both)) {
      correct = true;
    } else if (!isPosition &&
        (exp == _ExpectedMatch.audio || exp == _ExpectedMatch.both)) {
      correct = true;
    }
    setState(() {
      if (isPosition) {
        _posFeedback = correct;
      } else {
        _audFeedback = correct;
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _posFeedback = null;
          _audFeedback = null;
        });
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const totalTrials = 20 + _n; // 21 for N=1
    final trialNum = _history.length.clamp(1, totalTrials);
    final exp = _current.expected;
    final posPulsing =
        exp == _ExpectedMatch.position || exp == _ExpectedMatch.both;
    final audPulsing =
        exp == _ExpectedMatch.audio || exp == _ExpectedMatch.both;

    return Scaffold(
      // No explicit backgroundColor → defaults to cs.surface, same as the
      // real game screen (GameScreen sets no backgroundColor either).
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -300) _next();
          if ((d.primaryVelocity ?? 0) > 300) _previous();
        },
        child: Stack(
          children: [
            // ── [1] Game screen replica ─────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Header — identical to game_screen header
                  _buildHeader(cs, trialNum, totalTrials),
                  const Gap(8),

                  // Score sheet — shown ABOVE the grid so the control-pad
                  // area has more breathing room for the floating callout.
                  // AnimatedSize collapses it to zero height when empty.
                  RepaintBoundary(
                    key: _keyScoreSheet,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child:
                          _history.isNotEmpty
                              ? _buildScoreSheet(cs)
                              : const SizedBox(height: 0),
                    ),
                  ),

                  // Grid — same Expanded(flex:3) + maxWidth:400 as game_screen.
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: RepaintBoundary(
                        key: _keyGrid,
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
                            itemBuilder: (ctx, i) {
                              if (i == 4) return const SizedBox();
                              return GridCell(
                                index: i,
                                isActive: _gridActive && i == _activeCell,
                                activeColor: cs.secondary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Control pad — same as the real game screen
                  _buildControlPad(cs, posPulsing, audPulsing),

                  const Gap(8),
                ],
              ),
            ),

            // ── [2] Spotlight scrim ─────────────────────────────────────────
            if (_spotRects.isNotEmpty || _current.highlight == _Region.textBox)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      rects: _spotRects,
                      dimOnly: _current.highlight == _Region.textBox,
                    ),
                  ),
                ),
              ),

            // ── [3] Floating callout bubble + nav ──────────────────────────
            _FloatingCallout(
              stepIndex: _stepIndex,
              step: _current,
              primaryRect: _primaryRect,
              highlight: _current.highlight,
              controlPadBottom: _controlPadBottom,
              isLast: _isLast,
              trialRunning: _trialRunning,
              onPrev: _stepIndex > 0 ? _previous : null,
              onNext: _next,
              onSkip: _skip,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildHeader(ColorScheme cs, int trialNum, int totalTrials) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Row(
        children: [
          // How to Play label (replaces "Practice")
          Text(
            'How to Play',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          // No step counter text in header – it's shown in the callout nav bar
          const Spacer(),
          // Trial counter
          RepaintBoundary(
            key: _keyTrialCounter,
            child: Column(
              children: [
                Text(
                  '$trialNum / $totalTrials',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '0',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          // N badge
          ScaleTransition(
            scale:
                _current.highlight == _Region.nBadge
                    ? _badgePulse
                    : const AlwaysStoppedAnimation(1.0),
            child: RepaintBoundary(
              child: Container(
                key: _keyNBadge,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$_n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSheet(ColorScheme cs) {
    // No row highlighting in tutorial – all rows show uniformly.
    const matchRows = <int>{};

    return SizedBox(
      height: 160,
      child: Container(
        color: cs.surfaceContainerHighest,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 28,
              dataRowMaxHeight: 28,
              columnSpacing: 12,
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Position')),
                DataColumn(label: Text('Letter')),
                DataColumn(label: Text('Pos Match?')),
                DataColumn(label: Text('Audio Match?')),
              ],
              rows: List.generate(_history.length, (i) {
                final t = _history[i];
                final canCompare = i >= _n;
                String posMatch = '–';
                String audMatch = '–';
                if (canCompare) {
                  final ref = _history[i - _n];
                  posMatch = t.position == ref.position ? '✅ Yes' : '❌ No';
                  audMatch = t.letter == ref.letter ? '✅ Yes' : '❌ No';
                }
                final isHighlighted = matchRows.contains(i);
                Color? rowColor;
                if (isHighlighted) {
                  rowColor = cs.primary.withValues(alpha: 0.18);
                }

                return DataRow(
                  color: WidgetStateProperty.all(rowColor),
                  cells: [
                    DataCell(
                      Text(
                        '${i + 1}',
                        style:
                            isHighlighted
                                ? TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                )
                                : null,
                      ),
                    ),
                    DataCell(
                      Text(
                        t.posLabel,
                        style:
                            isHighlighted
                                ? TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                )
                                : null,
                      ),
                    ),
                    DataCell(
                      Text(
                        t.letter,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isHighlighted ? cs.primary : cs.secondary,
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
        ),
      ),
    );
  }

  Widget _buildControlPad(ColorScheme cs, bool posPulsing, bool audPulsing) {
    final exp = _current.expected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _TutControlButton(
              label: 'POSITION',
              icon: Icons.grid_view_rounded,
              idleColor: cs.secondary,
              isPulsing: posPulsing,
              feedback: _posFeedback,
              layoutKey: _keyPosButton,
              onTap: exp != _ExpectedMatch.none ? () => _handleTap(true) : null,
            ),
          ),
          const Gap(16),
          Expanded(
            child: _TutControlButton(
              label: 'AUDIO',
              icon: Icons.headphones_rounded,
              idleColor: cs.primary,
              isPulsing: audPulsing,
              feedback: _audFeedback,
              layoutKey: _keyAudButton,
              onTap:
                  exp != _ExpectedMatch.none ? () => _handleTap(false) : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Floating callout bubble (positions itself near the spotlight)
// ===========================================================================
class _FloatingCallout extends StatelessWidget {
  final int stepIndex;
  final _Step step;
  final Rect? primaryRect;
  final _Region highlight;
  final double? controlPadBottom; // actual bottom Y of the button row
  final bool isLast;
  final bool trialRunning;
  final VoidCallback? onPrev;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _FloatingCallout({
    required this.stepIndex,
    required this.step,
    required this.primaryRect,
    required this.highlight,
    this.controlPadBottom,
    required this.isLast,
    required this.trialRunning,
    required this.onPrev,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    const cardW = 320.0;
    const cardPad = 16.0;

    // Horizontal center of the callout card
    double cardLeft = ((screenW - cardW) / 2).clamp(
      cardPad,
      screenW - cardW - cardPad,
    );

    const double cardEstH = 200.0;
    const double gap = 12.0;
    double topPos;
    bool pointerAboveCard;

    final Rect? pr = primaryRect;

    if (pr != null &&
        (highlight == _Region.posButton ||
            highlight == _Region.audButton ||
            highlight == _Region.bothButtons)) {
      // Buttons are at the bottom — callout goes ABOVE the spotlight so it
      // stays on screen, with the arrow pointing DOWN toward the buttons.
      topPos = pr.top - cardEstH - gap;
      pointerAboveCard = false; // arrow below card, pointing down toward target
    } else if (pr == null) {
      // No spotlight → float near bottom
      topPos = screenH - cardEstH - 100;
      pointerAboveCard = false;
    } else {
      final bool rectInUpperHalf = pr.center.dy < screenH * 0.5;
      if (rectInUpperHalf) {
        topPos = pr.bottom + gap;
        pointerAboveCard = true;
      } else {
        topPos = pr.top - cardEstH - gap;
        pointerAboveCard = false;
      }
    }

    // Clamp to screen bounds so the card is always fully visible.
    topPos = topPos.clamp(60.0, screenH - cardEstH - 20);

    // Pointer X: point toward highlighted rect center
    final double pointerCenterX =
        pr != null
            ? (pr.center.dx - cardLeft).clamp(20, cardW - 20)
            : cardW / 2;

    final isLastStep = step.narration.contains('About');

    return Positioned(
      top: topPos,
      left: cardLeft,
      width: cardW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pointer triangle (above card → pointing up) ──────────────────
          if (pr != null && pointerAboveCard)
            Padding(
              padding: EdgeInsets.only(left: pointerCenterX - 10),
              child: CustomPaint(
                size: const Size(20, 10),
                painter: _TrianglePainter(color: cs.surface, pointingUp: true),
              ),
            ),

          // ── Callout card ─────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder:
                (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
            child: Container(
              key: ValueKey(stepIndex),
              width: cardW,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLastStep
                      ? _RichNarrationWithAboutLink(
                        text: step.narration,
                        onAboutTap: () => context.push('/about'),
                      )
                      : _RichNarration(text: step.narration),
                  const Gap(14),

                  // Nav row: Prev | Next (X/N) | Skip
                  Row(
                    children: [
                      if (onPrev != null) ...[
                        Expanded(
                          flex: 1,
                          child: FilledButton.icon(
                            onPressed: trialRunning ? null : onPrev,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                            ),
                            label: const Text('Prev'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: cs.surfaceContainerHighest,
                              foregroundColor: cs.onSurface,
                            ),
                          ),
                        ),
                        const Gap(6),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: trialRunning ? null : onNext,
                          icon: Icon(
                            isLast
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: Text(
                            isLast
                                ? "LET'S PLAY!"
                                : 'Next (${stepIndex + 2}/${_steps.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      // SKIP
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          foregroundColor: cs.onSurface.withValues(alpha: 0.55),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Pointer triangle (below card → pointing down) ─────────────────
          if (pr != null && !pointerAboveCard)
            Padding(
              padding: EdgeInsets.only(left: pointerCenterX - 10),
              child: CustomPaint(
                size: const Size(20, 10),
                painter: _TrianglePainter(color: cs.surface, pointingUp: false),
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Spotlight painter
// ===========================================================================
class _SpotlightPainter extends CustomPainter {
  final List<Rect> rects;
  final bool dimOnly; // true = dim everything with no holes (textBox region)
  const _SpotlightPainter({required this.rects, this.dimOnly = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Semi-transparent gray mask over the whole screen.
    final scrimColor = Colors.black.withValues(alpha: 0.45);

    if (dimOnly || rects.isEmpty) {
      canvas.drawRect(Offset.zero & size, Paint()..color = scrimColor);
      return;
    }

    // Use saveLayer + BlendMode.clear to punch transparent holes.
    // This works on ALL Flutter renderers (HTML, CanvasKit, mobile, desktop).
    // Path.combine(PathOperation.difference) is NOT supported on the HTML
    // web renderer, which is why holes were never cut before.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, Paint()..color = scrimColor);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    for (final r in rects) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        clearPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotlightPainter o) =>
      o.rects != rects || o.dimOnly != dimOnly;
}

// ===========================================================================
// Triangle pointer painter
// ===========================================================================
class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointingUp;
  const _TrianglePainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter o) =>
      o.color != color || o.pointingUp != pointingUp;
}

// ===========================================================================
// Pulsing control button
// ===========================================================================
class _TutControlButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color idleColor;
  final bool isPulsing;
  final bool? feedback;
  final VoidCallback? onTap;
  // Key placed on the inner AnimatedContainer so spotlight measurement
  // captures the actual visual button rect, not the Expanded layout rect.
  final GlobalKey? layoutKey;

  const _TutControlButton({
    required this.label,
    required this.icon,
    required this.idleColor,
    required this.isPulsing,
    this.feedback,
    this.onTap,
    this.layoutKey,
  });

  @override
  State<_TutControlButton> createState() => _TutControlButtonState();
}

class _TutControlButtonState extends State<_TutControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.93,
      upperBound: 1.0,
    );
    if (widget.isPulsing) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_TutControlButton old) {
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
    final cs = Theme.of(context).colorScheme;
    final hasFeedback = widget.feedback != null;
    final Color bgColor =
        hasFeedback
            ? (widget.feedback! ? Colors.green : Colors.red)
            : cs.surfaceContainerHighest; // natural button appearance
    final Color fgColor = hasFeedback ? Colors.white : widget.idleColor;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          key: widget.layoutKey, // measures the actual button bounds
          duration: const Duration(milliseconds: 150),
          height: 80,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasFeedback
                      ? Colors.transparent
                      : (widget.isPulsing
                          ? widget.idleColor.withValues(alpha: 0.8)
                          : cs.outlineVariant),
              width: widget.isPulsing && !hasFeedback ? 2 : 1.5,
            ),
            boxShadow:
                widget.isPulsing && !hasFeedback
                    ? [
                      BoxShadow(
                        color: widget.idleColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 28, color: fgColor),
              const Gap(4),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                  fontSize: 13,
                ),
              ),
              if (widget.isPulsing && !hasFeedback) ...[
                const Gap(2),
                Text(
                  'TAP!',
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Rich narration (supports **bold** inline)
// ===========================================================================
class _RichNarration extends StatelessWidget {
  final String text;
  const _RichNarration({required this.text});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.55, fontSize: 14.5);
    return RichText(
      text: TextSpan(style: baseStyle, children: _parseSpans(text)),
    );
  }

  static List<InlineSpan> _parseSpans(String text) {
    final spans = <InlineSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(
        TextSpan(
          text: parts[i],
          style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      );
    }
    return spans;
  }
}

// ===========================================================================
// Rich narration with a tappable [About] link
// ===========================================================================
class _RichNarrationWithAboutLink extends StatelessWidget {
  final String text;
  final VoidCallback onAboutTap;
  const _RichNarrationWithAboutLink({
    required this.text,
    required this.onAboutTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(height: 1.55, fontSize: 14.5);
    final linkStyle = baseStyle?.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: cs.primary,
    );

    // Replace [**About**] with a tappable link span
    final spans = <InlineSpan>[];
    // Split on the placeholder [**About**]
    final parts = text.split('[**About**]');
    for (int i = 0; i < parts.length; i++) {
      if (i > 0) {
        // Insert tappable About link
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onAboutTap,
              child: Text('About', style: linkStyle),
            ),
          ),
        );
      }
      // Parse **bold** in the surrounding text segments
      final subParts = parts[i].split('**');
      for (int j = 0; j < subParts.length; j++) {
        spans.add(
          TextSpan(
            text: subParts[j],
            style:
                j.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        );
      }
    }

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}
