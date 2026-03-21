import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/domain/game_settings_provider.dart';

// Conditional import: dart:html AudioElement on web, audioplayers on mobile.
// This is the key fix for Chrome audio — AudioElement doesn't use the
// AudioContext that Chrome suspends between user gestures.
import 'platform_audio/mobile_player.dart'
    if (dart.library.html) 'platform_audio/web_player.dart';

// Singleton — persists for the full app lifetime.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  // Keep the gender in sync with the settings provider.
  ref.listen<AudioGender>(
    gameSettingsProvider.select((s) => s.audioGender),
    (_, gender) => service.setGender(gender),
  );
  ref.onDispose(service.dispose);
  return service;
});

class AudioService {
  final PlatformAudioPlayer _player = PlatformAudioPlayer();
  Timer? _stopTimer;
  AudioGender _gender = AudioGender.female;
  bool _isBackgrounded = false;

  void setBackgrounded(bool bg) {
    _isBackgrounded = bg;
    if (bg) {
      stopAudio();
    }
  }

  void stopAudio() {
    _stopTimer?.cancel();
    _player.stopAfterMs(0, '');
  }

  // ── Asset paths ────────────────────────────────────────────────────────────
  static const String _maleAsset = 'audio/Alphabet.oga';
  static const String _femaleAsset = 'audio/Alphabet_female.oga';

  String get _currentAsset =>
      _gender == AudioGender.female ? _femaleAsset : _maleAsset;

  // ── Male timestamps (Alphabet.oga) ─────────────────────────────────────────
  static const Map<String, ({int startMs, int durationMs})> _maleTimestamps = {
    'A': (startMs: 0, durationMs: 1027),
    'B': (startMs: 1027, durationMs: 1165),
    'C': (startMs: 2192, durationMs: 1164),
    'D': (startMs: 3356, durationMs: 1165),
    'E': (startMs: 4521, durationMs: 1323),
    'F': (startMs: 5844, durationMs: 1111),
    'G': (startMs: 6955, durationMs: 1165),
    'H': (startMs: 8120, durationMs: 1164),
    'I': (startMs: 9284, durationMs: 1112),
    'J': (startMs: 10396, durationMs: 1111),
    'K': (startMs: 11507, durationMs: 1165),
    'L': (startMs: 12671, durationMs: 1165),
    'M': (startMs: 13836, durationMs: 1111),
    'N': (startMs: 14947, durationMs: 1324),
    'O': (startMs: 16270, durationMs: 1218),
    'P': (startMs: 17488, durationMs: 1006),
    'Q': (startMs: 18493, durationMs: 1165),
    'R': (startMs: 19658, durationMs: 1270),
    'S': (startMs: 20928, durationMs: 1112),
    'T': (startMs: 22040, durationMs: 1111),
    'U': (startMs: 23151, durationMs: 1059),
    'V': (startMs: 24210, durationMs: 1111),
    'W': (startMs: 25321, durationMs: 1217),
    'X': (startMs: 26538, durationMs: 1006),
    'Y': (startMs: 27544, durationMs: 1112),
    'Z': (startMs: 28656, durationMs: 688),
  };

  // ── Female timestamps (9abc05fe...wav) ────────────────────────────────────
  // begin × 1000 → startMs (rounded), length × 1000 → durationMs (rounded).
  static const Map<String, ({int startMs, int durationMs})>
  _femaleTimestamps = {
    'A': (startMs: 0, durationMs: 863),
    'B': (startMs: 2054, durationMs: 1116),
    'C': (startMs: 4301, durationMs: 1131),
    'D': (startMs: 6876, durationMs: 893),
    'E': (startMs: 9391, durationMs: 1206),
    'F': (startMs: 11802, durationMs: 1057),
    'G': (startMs: 14303, durationMs: 1042),
    'H': (startMs: 16848, durationMs: 1339),
    'I': (startMs: 19246, durationMs: 1696),
    'J': (startMs: 21814, durationMs: 1673),
    'K': (startMs: 24382, durationMs: 1979),
    'L': (startMs: 27680, durationMs: 1885),
    'M': (startMs: 30295, durationMs: 1861),
    'N': (startMs: 32886, durationMs: 1814),
    'O': (startMs: 35477, durationMs: 1578),
    'P': (startMs: 38163, durationMs: 1673),
    'Q': (startMs: 40707, durationMs: 1578),
    'R': (startMs: 43369, durationMs: 1602),
    'S': (startMs: 45913, durationMs: 1484),
    'T': (startMs: 48481, durationMs: 1484),
    'U': (startMs: 50907, durationMs: 1649),
    'V': (startMs: 53640, durationMs: 1555),
    'W': (startMs: 56420, durationMs: 1673),
    'X': (startMs: 59105, durationMs: 1602),
    'Y': (startMs: 61485, durationMs: 1767),
    'Z': (startMs: 64123, durationMs: 2026),
  };

  Map<String, ({int startMs, int durationMs})> get _timestamps =>
      _gender == AudioGender.female ? _femaleTimestamps : _maleTimestamps;

  void setGender(AudioGender gender) {
    _gender = gender;
  }

  /// Pre-load the audio asset. Call this at game start (post-frame, after first
  /// render, counts as "in user gesture context" on web).
  Future<void> unlockAndPreload() async {
    debugPrint(
      '[AudioService] unlockAndPreload (${_gender.name}) on ${kIsWeb ? "WEB" : "MOBILE"}',
    );
    await _player.load(_currentAsset);
    debugPrint('[AudioService] Ready to play');
  }

  // Alias kept for compatibility
  Future<void> preload() => unlockAndPreload();

  /// Play a single letter from the audio sprite.
  Future<void> playLetter(String letter) async {
    if (_isBackgrounded) return;

    final timing = _timestamps[letter.toUpperCase()];
    if (timing == null) {
      debugPrint('[AudioService] Unknown letter "$letter"');
      return;
    }

    // Cancel any pending stop from the previous letter
    _stopTimer?.cancel();

    await _player.playFromMs(
      timing.startMs,
      timing.durationMs,
      letter,
      _currentAsset,
    );

    // Schedule stop
    _stopTimer = Timer(Duration(milliseconds: timing.durationMs), () {
      _player.stopAfterMs(0, letter);
    });
  }

  void dispose() {
    _stopTimer?.cancel();
    _player.dispose();
  }
}
