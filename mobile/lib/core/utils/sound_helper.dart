import 'package:audioplayers/audioplayers.dart';

/// Helper class to manage playback of soothing audio cues for habit completions
class SoundHelper {
  static AudioPlayer? _player;

  /// Play a very small and peaceful sound when a habit is marked done
  static Future<void> playPeacefulChime() async {
    try {
      _player ??= AudioPlayer();
      // Ensure player stops previous chime if tapped rapidly
      await _player!.stop();
      await _player!.play(
        AssetSource('sounds/peaceful_bell.wav'),
        volume: 0.65,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Silently catch in case device audio focus is restricted or audio hardware is busy
    }
  }

  /// Cleanly release audio resources
  static void dispose() {
    _player?.dispose();
    _player = null;
  }
}
