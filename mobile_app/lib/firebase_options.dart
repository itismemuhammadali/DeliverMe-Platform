import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALPQUtVzkQNqd8kUqhj3IDcO2y_y9CLtc',
    authDomain: 'delivermee-12c26.firebaseapp.com',
    projectId: 'delivermee-12c26',
    storageBucket: 'delivermee-12c26.firebasestorage.app',
    messagingSenderId: '648361658719',
    appId: '1:648361658719:web:a4abdd4626f9420d088eea',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-aMZUlqHBmmhHBolum72-OHmK1BBiBXk',
    appId: '1:648361658719:android:ff17c3b5fe3254da088eea',
    messagingSenderId: '648361658719',
    projectId: 'delivermee-12c26',
    storageBucket: 'delivermee-12c26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3fedUM_wTX5hL3p31Q89LH2HSB5D8gW8',
    appId: '1:648361658719:ios:dac49540361fd2e5088eea',
    messagingSenderId: '648361658719',
    projectId: 'delivermee-12c26',
    storageBucket: 'delivermee-12c26.firebasestorage.app',
    iosBundleId: 'com.delivermee.app',
  );
}
