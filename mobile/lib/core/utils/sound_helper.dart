import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static AudioPlayer? _player;

  /// Play clean, sweet, echoing chime when a habit is marked done
  static Future<void> playPeacefulChime() async {
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.setVolume(0.8);
      await _player!.play(
        AssetSource('sounds/peaceful_bell.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Silently catch in case device audio focus is restricted
    }
  }

  /// Play the signature HabitLeaf notification chime
  static Future<void> playNotificationChime() async {
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.setVolume(0.85);
      await _player!.play(
        AssetSource('sounds/habitleaf_notification.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  static void dispose() {
    _player?.dispose();
    _player = null;
  }
}
