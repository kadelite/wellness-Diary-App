// File generated manually for Firebase configuration
// This file contains Firebase options for different platforms

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmTReqeMy3fOr028jKMIhk9xV2HGCzWQI',
    appId: '1:509976892372:web:1a44e02849e4814647fc41',
    messagingSenderId: '509976892372',
    projectId: 'wellness-diary-81a92',
    authDomain: 'wellness-diary-81a92.firebaseapp.com',
    storageBucket: 'wellness-diary-81a92.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmTReqeMy3fOr028jKMIhk9xV2HGCzWQI',
    appId: '1:509976892372:android:1a44e02849e4814647fc41',
    messagingSenderId: '509976892372',
    projectId: 'wellness-diary-81a92',
    storageBucket: 'wellness-diary-81a92.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmTReqeMy3fOr028jKMIhk9xV2HGCzWQI',
    appId: '1:509976892372:ios:1a44e02849e4814647fc41',
    messagingSenderId: '509976892372',
    projectId: 'wellness-diary-81a92',
    storageBucket: 'wellness-diary-81a92.firebasestorage.app',
    iosBundleId: 'com.wellnessdiary.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmTReqeMy3fOr028jKMIhk9xV2HGCzWQI',
    appId: '1:509976892372:macos:1a44e02849e4814647fc41',
    messagingSenderId: '509976892372',
    projectId: 'wellness-diary-81a92',
    storageBucket: 'wellness-diary-81a92.firebasestorage.app',
    iosBundleId: 'com.wellnessdiary.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAmTReqeMy3fOr028jKMIhk9xV2HGCzWQI',
    appId: '1:509976892372:windows:1a44e02849e4814647fc41',
    messagingSenderId: '509976892372',
    projectId: 'wellness-diary-81a92',
    storageBucket: 'wellness-diary-81a92.firebasestorage.app',
  );
}
