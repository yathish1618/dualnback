// Mobile (iOS/Android) audio player using the audioplayers package.
// Uses play() with a position offset — atomically reliable across Android
// player states (paused, completed, etc). No separate seek+resume needed.
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class PlatformAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  Future<void> load(String asset) async {
    // Prime the player so the first letter has no delay on mobile.
    try {
      await _player.setSource(AssetSource(asset));
      debugPrint('[MobileAudio] Source primed: $asset');
    } catch (e) {
      debugPrint('[MobileAudio] load failed: $e');
    }
  }

  Future<void> playFromMs(
    int startMs,
    int durationMs,
    String letter,
    String asset,
  ) async {
    try {
      // play() atomically sets source + seeks + starts — most reliable on Android
      await _player.play(
        AssetSource(asset),
        position: Duration(milliseconds: startMs),
      );
      debugPrint('[MobileAudio] ▶ "$letter" @${startMs}ms');
    } catch (e) {
      debugPrint('[MobileAudio] ✗ play failed for "$letter": $e');
    }
  }

  Future<void> stopAfterMs(int durationMs, String letter) async {
    if (durationMs > 0) {
      await Future.delayed(Duration(milliseconds: durationMs));
    }
    try {
      await _player.pause();
      debugPrint('[MobileAudio] ■ paused "$letter"');
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
