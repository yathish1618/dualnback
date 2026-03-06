import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettingsState>((ref) {
      return GameSettingsNotifier();
    });

class GameSettingsState {
  final bool visualFeedbackEnabled;
  final bool vibrationEnabled;
  final bool debugModeEnabled;

  const GameSettingsState({
    this.visualFeedbackEnabled = true,
    this.vibrationEnabled = true,
    this.debugModeEnabled = false,
  });

  GameSettingsState copyWith({
    bool? visualFeedbackEnabled,
    bool? vibrationEnabled,
    bool? debugModeEnabled,
  }) {
    return GameSettingsState(
      visualFeedbackEnabled:
          visualFeedbackEnabled ?? this.visualFeedbackEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      debugModeEnabled: debugModeEnabled ?? this.debugModeEnabled,
    );
  }
}

class GameSettingsNotifier extends StateNotifier<GameSettingsState> {
  GameSettingsNotifier() : super(const GameSettingsState());

  void setVisualFeedback(bool enabled) {
    state = state.copyWith(visualFeedbackEnabled: enabled);
  }

  void setVibration(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
  }

  void setDebugMode(bool enabled) {
    state = state.copyWith(debugModeEnabled: enabled);
  }
}
