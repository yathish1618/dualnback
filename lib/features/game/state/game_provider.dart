import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../stats/data/stats_repository.dart';
import '../../stats/domain/game_session.dart';
import '../../stats/domain/score_sheet_item.dart';
import '../../training/domain/training_models.dart';
import '../domain/game_state.dart';
import '../domain/signal_generator.dart';

/// Training block result callback — called when a training block ends
typedef BlockCompleteCallback = Future<void> Function(BlockResult result);

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final statsRepo = ref.read(statsRepositoryProvider);
  // Pass the provider Ref so GameNotifier can update feedback providers without
  // storing a stale WidgetRef from a specific screen widget.
  return GameNotifier(SignalGenerator(), statsRepo, ref);
});

// Whether the current stimulus (grid highlight + audio) is actively showing.
// true during 500ms stimulus window, false during 2500ms ISI.
final stimulusActiveProvider = StateProvider<bool>((ref) => false);

// Per-button feedback colours exposed as independent providers.
final positionFeedbackProvider = StateProvider<bool?>((ref) => null);
final audioFeedbackProvider = StateProvider<bool?>((ref) => null);

class GameNotifier extends StateNotifier<GameState> {
  final SignalGenerator _signalGenerator;
  final StatsRepository _statsRepository;
  // Provider Ref — always valid, never stale across navigation/widget rebuilds.
  final Ref _ref;
  Timer? _trialTimer;
  Timer? _feedbackTimer;
  Timer? _countdownTimer;
  Timer? _posFeedbackTimer;
  Timer? _audFeedbackTimer;

  bool _debugMode = false;
  String _currentMode = 'sandbox';
  int _currentBlockNumber = 1;
  BlockCompleteCallback? _onBlockComplete;

  /// The completed GameSession from the most recent finished game.
  /// Set at the end of _finishGame and never cleared by stopGame().
  /// Used by the result screen Score Sheet button.
  GameSession? _lastSession;
  GameSession? get lastSession => _lastSession;

  GameNotifier(this._signalGenerator, this._statsRepository, this._ref)
    : super(const GameState());

  /// [mode]: 'sandbox' or 'training'
  /// [blockNumber]: 1-based block number when in training mode
  /// [onBlockComplete]: called with BlockResult when training block ends
  void startGame(
    int nLevel, {
    bool debugMode = false,
    String mode = 'sandbox',
    int blockNumber = 1,
    BlockCompleteCallback? onBlockComplete,
  }) {
    _debugMode = debugMode;
    _currentMode = mode;
    _currentBlockNumber = blockNumber;
    _onBlockComplete = onBlockComplete;

    // Generate signals using appropriate strategy
    final List<GameSignal> signals;
    if (mode == 'training') {
      final blockSignals = _signalGenerator.generateBlockSignals(n: nLevel);
      signals = blockSignals.signals;
    } else {
      final trialCount =
          AppConstants.defaultTrialCount +
          (nLevel * AppConstants.trialIncrementPerN);
      signals = _signalGenerator.generateSessionSignals(
        n: nLevel,
        length: trialCount,
      );
    }

    final trialCount = signals.length;
    state = GameState(
      status: GameStatus.countdown,
      currentNLevel: nLevel,
      history: signals,
      totalTrials: trialCount,
      currentTrial: 0,
      score: 0,
      countdownValue: 3,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownValue > 1) {
        state = state.copyWith(countdownValue: state.countdownValue - 1);
      } else {
        timer.cancel();
        // Start Game Loop
        state = state.copyWith(status: GameStatus.playing);
        _startTrialCycle();
      }
    });
  }

  void stopGame() {
    _trialTimer?.cancel();
    _feedbackTimer?.cancel();
    _countdownTimer?.cancel();
    state = state.copyWith(
      status: GameStatus.initial,
      currentSignal: null,
      pendingSignal: null,
      pendingTrialNumber: null,
    );
  }

  Future<void> _finishGame() async {
    _trialTimer?.cancel();
    _feedbackTimer?.cancel();

    // Build the session record (always saved for sandbox; saved additionally as
    // BlockResult for training mode via callback)
    final session = GameSession(
      id: const Uuid().v4(),
      date: DateTime.now(),
      nLevel: state.currentNLevel,
      score: state.score,
      totalTrials: state.totalTrials,
      correctPosition: state.correctPositionMatches,
      correctAudio: state.correctAudioMatches,
      mistakes:
          state.falsePositionMatches +
          state.falseAudioMatches +
          state.missedPositionMatches +
          state.missedAudioMatches,
      scoreSheet:
          state.trialResults
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
      debugMode: _debugMode,
      gameMode: _currentMode, // 'training' or 'practice'/'sandbox'
    );

    // For training mode, also build BlockResult and invoke callback
    if (_currentMode == 'training') {
      final blockResult = BlockResult(
        blockNumber: _currentBlockNumber,
        nLevel: state.currentNLevel,
        positionMistakes:
            state.missedPositionMatches + state.falsePositionMatches,
        audioMistakes: state.missedAudioMatches + state.falseAudioMatches,
        completedAt: DateTime.now(),
        // Serialize trial results so score sheets work from block history
        trialData:
            state.trialResults
                .map(
                  (t) => {
                    'trialNumber': t.trialNumber,
                    'positionIndex': t.positionIndex,
                    'audioLetter': t.audioLetter,
                    'isPositionMatch': t.isPositionMatch,
                    'isAudioMatch': t.isAudioMatch,
                    'userPositionPressed': t.userPositionPressed,
                    'userAudioPressed': t.userAudioPressed,
                    'positionScore': t.positionScore,
                    'audioScore': t.audioScore,
                    'totalScore': t.totalScore,
                  },
                )
                .toList(),
      );
      try {
        await _onBlockComplete?.call(blockResult);
      } catch (e) {
        // ignore: avoid_print
        print('[GameNotifier] onBlockComplete failed: $e');
      }
    }

    // Always transition to finished, even if saving fails.
    // We save first, then mark done; if save throws we still finish the game.
    try {
      await _statsRepository.saveSession(session);
    } catch (e) {
      // ignore: avoid_print
      print('[GameNotifier] saveSession failed (game will still end): $e');
    } finally {
      // Cache the completed session so the result screen can always access
      // score sheet data — immune to any subsequent state resets.
      _lastSession = session;
      state = state.copyWith(status: GameStatus.finished, currentSignal: null);
    }
  }

  void _startTrialCycle() {
    if (state.currentTrial >= state.history.length) {
      _finishGame();
      return;
    }

    // Show stimulus — set signal and mark stimulus as active
    state = state.copyWith(
      visualMatchPressed: null,
      audioMatchPressed: null,
      lastTrialCorrect: null,
      currentSignal: state.history[state.currentTrial],
      // Pending debug row: shows immediately when trial begins
      pendingTrialNumber: state.currentTrial + 1,
      pendingSignal: state.history[state.currentTrial],
    );

    // After STIMULUS_DURATION (500ms), dim the grid but keep accepting input
    _trialTimer = Timer(
      const Duration(milliseconds: AppConstants.stimulusDurationMs),
      () {
        // Dim the grid — clear currentSignal so grid goes dark
        state = state.copyWith(currentSignal: null);

        // After ISI (2500ms), evaluate and advance
        _trialTimer = Timer(
          const Duration(milliseconds: AppConstants.stimulusIsiMs),
          () {
            _evaluateTrial();
            state = state.copyWith(currentTrial: state.currentTrial + 1);
            _startTrialCycle();
          },
        );
      },
    );
  }

  void _evaluateTrial() {
    // This runs AT THE END of a stimulus window
    final int n = state.currentNLevel;
    final int currentIndex = state.currentTrial;

    if (currentIndex >= state.history.length) return;

    final currentSig = state.history[currentIndex];
    bool isPosMatch = false;
    bool isAudioMatch = false;

    // Check matches
    if (currentIndex >= n) {
      final originalSig = state.history[currentIndex - n];
      isPosMatch = currentSig.positionIndex == originalSig.positionIndex;
      isAudioMatch = currentSig.audioLetter == originalSig.audioLetter;
    }

    // Determine Trial Specific Scores for Table
    int posScore = 0;
    int audioScore = 0;

    // Position Scoring Logic
    if (isPosMatch) {
      if (state.visualMatchPressed == true) {
        posScore = 1; // Correct Hit
      } else {
        // Missed Match
        // Note: AppConstants might handle score updates differently, but table needs explicit value
        posScore =
            0; // Or -1 if misses are penalized in debug view? Prompt said "0 or 1 or -1"
        _updateScore(AppConstants.scoreMiss);
        state = state.copyWith(
          missedPositionMatches: state.missedPositionMatches + 1,
        );
      }
    } else {
      // No Match
      if (state.visualMatchPressed == true) {
        // False Positive
        posScore = -1;
      } else {
        // Correct Rejection (did nothing correctly)
        posScore = 0;
      }
    }

    // Audio Scoring Logic
    if (isAudioMatch) {
      if (state.audioMatchPressed == true) {
        audioScore = 1; // Correct Hit
      } else {
        // Missed Match
        audioScore = 0;
        _updateScore(AppConstants.scoreMiss);
        state = state.copyWith(
          missedAudioMatches: state.missedAudioMatches + 1,
        );
      }
    } else {
      // No Match
      if (state.audioMatchPressed == true) {
        // False Positive
        audioScore = -1;
      } else {
        // Correct Rejection
        audioScore = 0;
      }
    }

    // Capture Result
    final result = TrialResult(
      trialNumber: currentIndex + 1,
      positionIndex: currentSig.positionIndex,
      audioLetter: currentSig.audioLetter,
      isPositionMatch: isPosMatch,
      isAudioMatch: isAudioMatch,
      userPositionPressed: state.visualMatchPressed == true,
      userAudioPressed: state.audioMatchPressed == true,
      positionScore: posScore,
      audioScore: audioScore,
      totalScore: state.score, // Snapshot current score
    );

    // Update State regarding scores and Misses is done above or in inputs.
    // We append the result here and clear the pending row.
    state = state.copyWith(
      trialResults: [...state.trialResults, result],
      pendingSignal: null,
      pendingTrialNumber: null,
    );
  }

  void togglePause() {
    if (state.isPaused) {
      // Resume
      state = state.copyWith(isPaused: false);
      _startTrialCycle();
    } else {
      // Pause
      _trialTimer?.cancel();
      _feedbackTimer?.cancel();
      state = state.copyWith(isPaused: true);
    }
  }

  void _setButtonFeedback({required bool isPosition, required bool correct}) {
    final provider =
        isPosition ? positionFeedbackProvider : audioFeedbackProvider;
    (isPosition ? _posFeedbackTimer : _audFeedbackTimer)?.cancel();
    // Use the provider Ref — always valid, no stale WidgetRef issue
    _ref.read(provider.notifier).state = correct;
    final timer = Timer(
      const Duration(milliseconds: AppConstants.feedbackDurationMs),
      () {
        if (mounted) _ref.read(provider.notifier).state = null;
      },
    );
    if (isPosition) {
      _posFeedbackTimer = timer;
    } else {
      _audFeedbackTimer = timer;
    }
  }

  void onPositionInput() {
    if (state.status != GameStatus.playing ||
        state.visualMatchPressed != null) {
      return;
    }

    state = state.copyWith(visualMatchPressed: true);

    final int n = state.currentNLevel;
    final int currentIndex = state.currentTrial;

    if (currentIndex < n) {
      _handleFalsePositive(isVisual: true);
      return;
    }

    // SAFETY CHECK: Ensure we don't access out of bounds if game is finishing
    if (currentIndex >= state.history.length) return;

    final currentSig = state.history[currentIndex];
    final originalSig = state.history[currentIndex - n];

    if (currentSig.positionIndex == originalSig.positionIndex) {
      _updateScore(AppConstants.scoreCorrect);
      state = state.copyWith(
        correctPositionMatches: state.correctPositionMatches + 1,
      );
      _setButtonFeedback(isPosition: true, correct: true);
      _triggerFeedback(true);
    } else {
      _handleFalsePositive(isVisual: true);
    }
  }

  void onAudioInput() {
    if (state.status != GameStatus.playing || state.audioMatchPressed != null) {
      return;
    }

    state = state.copyWith(audioMatchPressed: true);

    final int n = state.currentNLevel;
    final int currentIndex = state.currentTrial;

    if (currentIndex < n) {
      _handleFalsePositive(isVisual: false);
      return;
    }

    // SAFETY CHECK: Ensure we don't access out of bounds
    if (currentIndex >= state.history.length) return;

    final currentSig = state.history[currentIndex];
    final originalSig = state.history[currentIndex - n];

    if (currentSig.audioLetter == originalSig.audioLetter) {
      _updateScore(AppConstants.scoreCorrect);
      state = state.copyWith(
        correctAudioMatches: state.correctAudioMatches + 1,
      );
      _setButtonFeedback(isPosition: false, correct: true);
      _triggerFeedback(true);
    } else {
      _handleFalsePositive(isVisual: false);
    }
  }

  void _handleFalsePositive({required bool isVisual}) {
    _updateScore(AppConstants.scoreFalsePositive);
    if (isVisual) {
      state = state.copyWith(
        falsePositionMatches: state.falsePositionMatches + 1,
      );
    } else {
      state = state.copyWith(falseAudioMatches: state.falseAudioMatches + 1);
    }
    _setButtonFeedback(isPosition: isVisual, correct: false);
    _triggerFeedback(false);
  }

  void _updateScore(double delta) {
    int newScore = state.score + delta.toInt();
    state = state.copyWith(score: newScore);
  }

  void _triggerFeedback(bool correctlyCaught) {
    state = state.copyWith(lastTrialCorrect: correctlyCaught);
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(
      const Duration(milliseconds: AppConstants.feedbackDurationMs),
      () {
        if (mounted) state = state.copyWith(lastTrialCorrect: null);
      },
    );
  }

  @override
  void dispose() {
    _trialTimer?.cancel();
    _feedbackTimer?.cancel();
    _countdownTimer?.cancel();
    _posFeedbackTimer?.cancel();
    _audFeedbackTimer?.cancel();
    super.dispose();
  }
}
