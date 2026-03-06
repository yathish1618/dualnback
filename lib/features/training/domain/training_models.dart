import 'package:flutter/foundation.dart';

/// Game mode — sandbox (free practice) or daily training (structured 20 blocks)
enum GameMode { sandbox, dailyTraining }

/// Result for a single block in a daily training session
class BlockResult {
  final int blockNumber; // 1–20
  final int nLevel;
  final int positionMistakes;
  final int audioMistakes;
  final DateTime completedAt;
  final List<Map<String, dynamic>> trialData; // serialized TrialResult list

  const BlockResult({
    required this.blockNumber,
    required this.nLevel,
    required this.positionMistakes,
    required this.audioMistakes,
    required this.completedAt,
    this.trialData = const [],
  });

  Map<String, dynamic> toMap() => {
    'blockNumber': blockNumber,
    'nLevel': nLevel,
    'positionMistakes': positionMistakes,
    'audioMistakes': audioMistakes,
    'completedAt': completedAt.toIso8601String(),
    'trialData': trialData,
  };

  factory BlockResult.fromMap(Map<String, dynamic> map) => BlockResult(
    blockNumber: map['blockNumber'] as int,
    nLevel: map['nLevel'] as int,
    positionMistakes: map['positionMistakes'] as int,
    audioMistakes: map['audioMistakes'] as int,
    completedAt: DateTime.parse(map['completedAt'] as String),
    trialData: List<Map<String, dynamic>>.from(
      (map['trialData'] as List<dynamic>?)?.map(
            (e) => Map<String, dynamic>.from(e as Map),
          ) ??
          [],
    ),
  );
}

/// A full daily training session (20 blocks)
class TrainingDay {
  final String date; // yyyy-MM-dd
  final List<BlockResult> blocks;
  final int startingNLevel;
  final int endingNLevel;

  const TrainingDay({
    required this.date,
    required this.blocks,
    required this.startingNLevel,
    required this.endingNLevel,
  });

  bool get isComplete => blocks.length >= AppTrainingConstants.blocksPerSession;
  int get completedBlocks => blocks.length;

  Map<String, dynamic> toMap() => {
    'date': date,
    'blocks': blocks.map((b) => b.toMap()).toList(),
    'startingNLevel': startingNLevel,
    'endingNLevel': endingNLevel,
  };

  factory TrainingDay.fromMap(Map<String, dynamic> map) => TrainingDay(
    date: map['date'] as String,
    blocks:
        (map['blocks'] as List<dynamic>? ?? [])
            .map(
              (e) => BlockResult.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList(),
    startingNLevel: map['startingNLevel'] as int? ?? 2,
    endingNLevel: map['endingNLevel'] as int? ?? 2,
  );
}

// Separate constants class to avoid circular imports
class AppTrainingConstants {
  static const int blocksPerSession = 20;
  static const int nLevelUpThreshold = 3; // < 3 mistakes → N+1
  static const int nLevelDownThreshold = 5; // > 5 mistakes → N−1
}

/// User profile — persisted across sessions
class UserProfile {
  final int currentNLevel;
  final int bestNLevel;
  final int currentStreak;
  final int bestStreak;
  final String? lastTrainingDate; // yyyy-MM-dd
  final bool hasSeenTutorial;

  const UserProfile({
    this.currentNLevel = 2,
    this.bestNLevel = 2,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastTrainingDate,
    this.hasSeenTutorial = false,
  });

  UserProfile copyWith({
    int? currentNLevel,
    int? bestNLevel,
    int? currentStreak,
    int? bestStreak,
    String? lastTrainingDate,
    bool? hasSeenTutorial,
  }) => UserProfile(
    currentNLevel: currentNLevel ?? this.currentNLevel,
    bestNLevel: bestNLevel ?? this.bestNLevel,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    lastTrainingDate: lastTrainingDate ?? this.lastTrainingDate,
    hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
  );

  Map<String, dynamic> toMap() => {
    'currentNLevel': currentNLevel,
    'bestNLevel': bestNLevel,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'lastTrainingDate': lastTrainingDate,
    'hasSeenTutorial': hasSeenTutorial,
  };

  factory UserProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserProfile();
    return UserProfile(
      currentNLevel: map['currentNLevel'] as int? ?? 2,
      bestNLevel: map['bestNLevel'] as int? ?? 2,
      currentStreak: map['currentStreak'] as int? ?? 0,
      bestStreak: map['bestStreak'] as int? ?? 0,
      lastTrainingDate: map['lastTrainingDate'] as String?,
      hasSeenTutorial: map['hasSeenTutorial'] as bool? ?? false,
    );
  }
}

/// N-level adaptation logic per research paper
int adaptNLevel({
  required int currentN,
  required int positionMistakes,
  required int audioMistakes,
}) {
  final maxMistakes =
      positionMistakes > audioMistakes ? positionMistakes : audioMistakes;
  debugPrint(
    '[N-Adapt] posErr=$positionMistakes audErr=$audioMistakes max=$maxMistakes',
  );
  if (maxMistakes < AppTrainingConstants.nLevelUpThreshold) {
    return (currentN + 1).clamp(1, 9); // < 3 mistakes → N+1
  } else if (maxMistakes > AppTrainingConstants.nLevelDownThreshold) {
    return (currentN - 1).clamp(1, 9); // > 5 mistakes → N−1
  }
  return currentN; // 3–5 mistakes → unchanged
}
