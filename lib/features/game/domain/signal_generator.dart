import 'dart:math';
import 'game_state.dart';
import '../../../core/constants/app_constants.dart';

/// Result of block signal generation — includes signals + which consonants
/// were chosen for this block (so they can be stored with the block result).
class BlockSignals {
  final List<GameSignal> signals;
  final List<String> consonantsUsed;

  const BlockSignals({required this.signals, required this.consonantsUsed});
}

class SignalGenerator {
  final Random _random = Random();

  /// Generate signals for one research-paper-accurate block.
  ///
  /// - Uses only [AppConstants.lettersPerBlock] random consonants.
  /// - Excludes center grid position (index 4).
  /// - Places exactly 6 position matches + 6 audio matches.
  ///   - 2 dual targets (both modalities match on same trial).
  ///   - 4 single-modality targets (2 audio-only, 2 position-only).
  BlockSignals generateBlockSignals({required int n}) {
    final totalTrials = AppConstants.trialsPerBlock + n; // 20 + N

    // Pick 6 consonants for this block (no vowels, no repetition)
    final consonants = List<String>.from(AppConstants.consonantPool)
      ..shuffle(_random);
    final blockConsonants =
        consonants.take(AppConstants.lettersPerBlock).toList();

    // Valid grid positions (center excluded)
    final positions = List<int>.from(AppConstants.validGridPositions);

    // Phase 1: Fill the first N trials with random signals (no matches possible)
    final List<GameSignal> signals = List.generate(
      n,
      (_) => _randomSignal(positions, blockConsonants),
    );

    // Phase 2: Fill remaining 20 trials.
    // We need to place 6 position + 6 audio matches with specific distribution.
    // Matchable trials: indices n to totalTrials-1 (count = 20).
    // Target layout (relative to matchable trial index 0–19):
    //   2 dual matches, 2 position-only, 2 audio-only = 6 match events with 6+6 total targets.
    // Wait — to place 6 visual + 6 audio in 20 trials with only 2 dual →
    // 4 visual-only + 4 audio-only + 2 dual = 10 target events.
    // That gives 4+2=6 visual and 4+2=6 audio. ✓
    final int matchableCount = totalTrials - n; // = 20
    // Choose distinct indices within matchable trials for each target type
    final List<int> matchableIndices = List.generate(matchableCount, (i) => i)
      ..shuffle(_random);
    // Reserve indices for targets (10 total target events, spread evenly)
    final dualIndices = matchableIndices.sublist(
      0,
      AppConstants.dualTargets,
    ); // 2 dual
    final posOnlyIndices = matchableIndices.sublist(2, 6); // 4 pos-only
    final audOnlyIndices = matchableIndices.sublist(6, 10); // 4 aud-only
    final targetIndices = {
      for (final i in dualIndices) i: 'dual',
      for (final i in posOnlyIndices) i: 'pos',
      for (final i in audOnlyIndices) i: 'aud',
    };

    // Build matchable signals forward (so we can back-reference n-back signals)
    for (int m = 0; m < matchableCount; m++) {
      final absoluteIndex = n + m;
      final nBackSignal = signals[absoluteIndex - n]; // guaranteed to exist
      final targetType = targetIndices[m];

      int position;
      String audio;

      switch (targetType) {
        case 'dual':
          // Both match
          position = nBackSignal.positionIndex;
          audio = nBackSignal.audioLetter;
          break;
        case 'pos':
          // Position matches, audio does NOT match
          position = nBackSignal.positionIndex;
          audio = _nonMatchingLetter(nBackSignal.audioLetter, blockConsonants);
          break;
        case 'aud':
          // Audio matches, position does NOT match
          position = _nonMatchingPosition(nBackSignal.positionIndex, positions);
          audio = nBackSignal.audioLetter;
          break;
        default:
          // No match — ensure neither accidentally matches
          position = _nonMatchingPosition(nBackSignal.positionIndex, positions);
          audio = _nonMatchingLetter(nBackSignal.audioLetter, blockConsonants);
          break;
      }

      signals.add(GameSignal(positionIndex: position, audioLetter: audio));
    }

    return BlockSignals(signals: signals, consonantsUsed: blockConsonants);
  }

  /// Legacy method for sandbox mode (kept for backward compatibility).
  List<GameSignal> generateSessionSignals({
    required int n,
    required int length,
    double matchChance = 0.3,
  }) {
    final positions = List<int>.from(AppConstants.validGridPositions);
    final consonants = AppConstants.consonantPool;

    final List<GameSignal> signals = [];
    for (int i = 0; i < length; i++) {
      if (i < n) {
        signals.add(_randomSignal(positions, consonants));
        continue;
      }
      final nBack = signals[i - n];
      final bool forcePos = _random.nextDouble() < matchChance;
      final bool forceAud = _random.nextDouble() < matchChance;

      signals.add(
        GameSignal(
          positionIndex:
              forcePos
                  ? nBack.positionIndex
                  : _nonMatchingPosition(nBack.positionIndex, positions),
          audioLetter:
              forceAud
                  ? nBack.audioLetter
                  : _nonMatchingLetter(nBack.audioLetter, consonants),
        ),
      );
    }
    return signals;
  }

  GameSignal _randomSignal(List<int> positions, List<String> letters) {
    return GameSignal(
      positionIndex: positions[_random.nextInt(positions.length)],
      audioLetter: letters[_random.nextInt(letters.length)],
    );
  }

  int _nonMatchingPosition(int exclude, List<int> positions) {
    final options = positions.where((p) => p != exclude).toList();
    return options[_random.nextInt(options.length)];
  }

  String _nonMatchingLetter(String exclude, List<String> letters) {
    final options = letters.where((l) => l != exclude).toList();
    if (options.isEmpty) return letters[_random.nextInt(letters.length)];
    return options[_random.nextInt(options.length)];
  }
}
