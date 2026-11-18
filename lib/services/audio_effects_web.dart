// lib/services/audio_effects_web.dart
import 'dart:js_interop';

@JS('playUiSound')
external void playWebUiSound(JSString type);

void callPlayUiSound(String type) => playWebUiSound(type.toJS);
