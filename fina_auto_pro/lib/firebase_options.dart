// Gerado por: dart run flutterfire_cli:flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plataforma não suportada.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'fina-auto',
    authDomain: 'fina-auto.firebaseapp.com',
    storageBucket: 'fina-auto.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'fina-auto',
    storageBucket: 'fina-auto.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUBSTITUIR',
    appId: 'SUBSTITUIR',
    messagingSenderId: 'SUBSTITUIR',
    projectId: 'fina-auto',
    storageBucket: 'fina-auto.appspot.com',
    iosBundleId: 'com.finaauto.pro',
  );
}
