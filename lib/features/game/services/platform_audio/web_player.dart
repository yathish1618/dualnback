// Web-specific audio player.
// Calls window._audioSprite (defined in web/audio_sprite.js) via dart:js.
// The JS bridge uses Web Audio API AudioBufferSourceNode.start(offset, duration)
// which is sample-accurate — no OGG seek issues.
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PlatformAudioPlayer {
  static String _buildSrc(String asset) =>
      kReleaseMode ? 'assets/assets/$asset' : 'assets/$asset';

  js.JsObject? get _sprite {
    final s = js.context['_audioSprite'];
    return s is js.JsObject ? s : null;
  }

  Future<void> load(String asset) async {
    final sprite = _sprite;
    if (sprite == null) {
      debugPrint(
        '[WebAudio] ✗ _audioSprite not found — audio_sprite.js missing?',
      );
      return;
    }
    // JS load() is async internally; call and don't wait (it sets buffer when done)
    sprite.callMethod('load', [_buildSrc(asset)]);
    debugPrint('[WebAudio] load() called on JS sprite: $asset');
  }

  Future<void> playFromMs(
    int startMs,
    int durationMs,
    String letter,
    String asset,
  ) async {
    final sprite = _sprite;
    if (sprite == null) {
      debugPrint('[WebAudio] ✗ _audioSprite unavailable for "$letter"');
      return;
    }
    final offsetSec = startMs / 1000.0;
    final durationSec = durationMs / 1000.0;
    sprite.callMethod('play', [offsetSec, durationSec, letter]);
    debugPrint('[WebAudio] ▶ "$letter" @${offsetSec.toStringAsFixed(3)}s');
  }

  // AudioBufferSourceNode auto-stops after duration — no-op
  Future<void> stopAfterMs(int durationMs, String letter) async {}

  void dispose() {}
}
