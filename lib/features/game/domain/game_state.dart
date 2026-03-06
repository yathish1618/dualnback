import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

/// Represents a single trial's stimulus
@freezed
abstract class GameSignal with _$GameSignal {
  const factory GameSignal({
    required int positionIndex, // 0-8 for 3x3 grid
    required String audioLetter, // e.g., 'A', 'B', 'C'
  }) = _GameSignal;
}

enum GameStatus { initial, countdown, playing, finished }

/// Represents the current state of a game session
@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    @Default(GameStatus.initial) GameStatus status,
    @Default(false) bool isPaused,
    @Default(0) int currentNLevel,
    @Default(0) int currentTrial,
    @Default(0) int totalTrials,
    @Default(0) int score,
    @Default(0) int lives, // Optional, maybe not needed per specs, but useful
    // The history of signals in this session
    @Default([]) List<GameSignal> history,

    // The current signal being presented (null if in between or not started)
    GameSignal? currentSignal,

    // User feedback for the current trial
    bool? visualMatchPressed,
    bool? audioMatchPressed,

    // Result of the current trial
    bool? lastTrialCorrect, // For UI feedback (green/red flash)
    // Detailed stats
    @Default(0) int correctPositionMatches,
    @Default(0) int correctAudioMatches,
    @Default(0) int missedPositionMatches,
    @Default(0) int missedAudioMatches,
    @Default(0) int falsePositionMatches,
    @Default(0) int falseAudioMatches,

    // Countdown
    // Countdown
    @Default(3) int countdownValue,

    // Debug Data
    @Default([]) List<TrialResult> trialResults,

    // Pending row: set when a trial begins (before evaluation)
    int? pendingTrialNumber,
    GameSignal? pendingSignal,
  }) = _GameState;
}

@freezed
abstract class TrialResult with _$TrialResult {
  const factory TrialResult({
    required int trialNumber, // 1-based
    required int positionIndex,
    required String audioLetter,
    required bool isPositionMatch,
    required bool isAudioMatch,
    required bool userPositionPressed,
    required bool userAudioPressed,
    required int positionScore, // 1, 0, -1
    required int audioScore, // 1, 0, -1
    required int totalScore, // Accumulated score at this point
  }) = _TrialResult;
}
