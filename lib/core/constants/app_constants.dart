class AppConstants {
  // Game Modes
  static const int defaultNLevel = 2; // Start at N=2
  static const int defaultNLabel = 2;
  static const int minNLevel = 1;
  static const int maxNLevel = 9;

  // Grid — 3×3 with center excluded = 8 positions
  static const int defaultGridSize = 3; // 3x3 grid
  // Valid position indices (0–8, index 4 = center is excluded)
  static const List<int> validGridPositions = [0, 1, 2, 3, 5, 6, 7, 8];

  // Consonants only (no vowels — matches research paper)
  static const List<String> consonantPool = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  // Block composition (per research paper)
  static const int trialsPerBlock = 20; // 20 + N trials total
  static const int targetsPerModality = 6; // 6 visual + 6 audio per block
  static const int dualTargets = 2; // 2 dual (both modalities) per block
  static const int singleModalityTargets = 4; // 4 single-modality per block
  static const int lettersPerBlock = 6; // 6 consonants used per block

  // Daily training session
  static const int blocksPerSession = 20; // 20 blocks per day

  // Legacy aliases (used by game_provider for backward compat)
  static const int defaultTrialCount = trialsPerBlock; // = 20
  static const int trialIncrementPerN = 1; // n + 20 trials total

  // Timing (milliseconds) — from research paper
  static const int stimulusDurationMs = 500; // stimulus on for 500ms
  static const int stimulusIsiMs = 2500; // interstimulus interval 2500ms
  static const int defaultIntervalMs = 3000; // total trial = 3000ms

  static const int feedbackDurationMs = 600; // green/red flash duration

  // N-level adaptation (per research paper)
  // Count = missed matches + false presses, per modality
  static const int nLevelUpThreshold = 3; // < 3 mistakes/modality → N+1
  static const int nLevelDownThreshold = 5; // > 5 mistakes/modality → N−1

  // Legacy scoring (kept for sandbox mode)
  static const double scoreCorrect = 1.0;
  static const double scoreMiss = -0.5;
  static const double scoreFalsePositive = -1.0;

  // Assets
  static const String appTitle = 'Dual N-Back';
}
