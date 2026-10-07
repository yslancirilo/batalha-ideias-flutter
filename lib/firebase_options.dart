import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyACFsGooT9uvKPEUc9CMtL3EfPdhw8EAlk',
    authDomain: 'batalha-ideias.firebaseapp.com',
    projectId: 'batalha-ideias',
    storageBucket: 'batalha-ideias.firebasestorage.app',
    messagingSenderId: '665312241669',
    appId: '1:665312241669:web:73c60c6efe37ae05efd46c',
    measurementId: 'G-XDXEYPBJ7G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACFsGooT9uvKPEUc9CMtL3EfPdhw8EAlk',
    appId: '1:665312241669:web:73c60c6efe37ae05efd46c',
    messagingSenderId: '665312241669',
    projectId: 'batalha-ideias',
    storageBucket: 'batalha-ideias.firebasestorage.app',
  );
}
