// File generated for Firebase Options
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJ89eePx_p-XYsNKmmyVeXL3YdvHOal7A',
    appId: '1:8770051386:web:540da5a46e25c711aa0403',
    messagingSenderId: '8770051386',
    projectId: 'arsitekturcp',
    authDomain: 'arsitekturcp.firebaseapp.com',
    storageBucket: 'arsitekturcp.firebasestorage.app',
    measurementId: 'G-MVQKWJW243',
  );
}
