import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AudioGender { female, male }

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettingsState>((ref) {
      return GameSettingsNotifier();
    });

class GameSettingsState {
  final bool visualFeedbackEnabled;
  final bool vibrationEnabled;
  final bool debugModeEnabled;
  final AudioGender audioGender;

  const GameSettingsState({
    this.visualFeedbackEnabled = true,
    this.vibrationEnabled = true,
    this.debugModeEnabled = false,
    this.audioGender = AudioGender.female,
  });

  GameSettingsState copyWith({
    bool? visualFeedbackEnabled,
    bool? vibrationEnabled,
    bool? debugModeEnabled,
    AudioGender? audioGender,
  }) {
    return GameSettingsState(
      visualFeedbackEnabled:
          visualFeedbackEnabled ?? this.visualFeedbackEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      debugModeEnabled: debugModeEnabled ?? this.debugModeEnabled,
      audioGender: audioGender ?? this.audioGender,
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

  void setAudioGender(AudioGender gender) {
    state = state.copyWith(audioGender: gender);
  }
}
