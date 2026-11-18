// lib/services/audio_effects_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'audio_effects_stub.dart' if (dart.library.js_interop) 'audio_effects_web.dart';

class AudioEffectsService {
  static bool isMuted = false;

  /// Toggle mute status
  static bool toggleMute() {
    isMuted = !isMuted;
    if (!isMuted) {
      playClick();
    }
    return isMuted;
  }

  /// Trigger JavaScript Web Audio engine directly via JS interop
  static void _callWebSound(String type) {
    if (kIsWeb) {
      try {
        callPlayUiSound(type);
      } catch (e) {
        debugPrint('[AudioEffectsService] $e');
      }
    }
  }

  /// Crisp, modern tactile UI click sound
  static void playClick() {
    if (isMuted) return;

    // Standard system sound on desktop/mobile
    SystemSound.play(SystemSoundType.click);

    // High fidelity Web Audio synthesis on Web
    _callWebSound('click');
  }

  /// Subtle soft blip on button hover
  static void playHover() {
    if (isMuted) return;

    _callWebSound('hover');
  }

  /// Celebratory chime for achievements or correct answers
  static void playSuccess() {
    if (isMuted) return;

    _callWebSound('success');
  }
}
