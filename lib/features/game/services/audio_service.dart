import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Conditional import: dart:html AudioElement on web, audioplayers on mobile.
// This is the key fix for Chrome audio — AudioElement doesn't use the
// AudioContext that Chrome suspends between user gestures.
import 'platform_audio/mobile_player.dart'
    if (dart.library.html) 'platform_audio/web_player.dart';

// Singleton — persists for the full app lifetime.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

class AudioService {
  final PlatformAudioPlayer _player = PlatformAudioPlayer();
  Timer? _stopTimer;

  static const Map<String, ({int startMs, int durationMs})> _timestamps = {
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

  /// Pre-load the audio asset. Call this at game start (post-frame, after first
  /// render, counts as "in user gesture context" on web).
  Future<void> unlockAndPreload() async {
    debugPrint(
      '[AudioService] unlockAndPreload on ${kIsWeb ? "WEB" : "MOBILE"}',
    );
    await _player.load();
    debugPrint('[AudioService] Ready to play');
  }

  // Alias kept for compatibility
  Future<void> preload() => unlockAndPreload();

  /// Play a single letter from the audio sprite.
  Future<void> playLetter(String letter) async {
    final timing = _timestamps[letter.toUpperCase()];
    if (timing == null) {
      debugPrint('[AudioService] Unknown letter "$letter"');
      return;
    }

    // Cancel any pending stop from the previous letter
    _stopTimer?.cancel();

    await _player.playFromMs(timing.startMs, timing.durationMs, letter);

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
