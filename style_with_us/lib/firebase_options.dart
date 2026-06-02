// GENERATED FILE - DO NOT MODIFY BY HAND
// This is a placeholder `firebase_options.dart` created to avoid runtime
// assertion failures. Replace the placeholder values with your real
// Firebase project configuration or run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCY5pqtJLsZUyTDfWRX3URLcMnghsymXE',
    authDomain: 'style-with-us-4ee75.firebaseapp.com',
    projectId: 'style-with-us-4ee75',
    storageBucket: 'style-with-us-4ee75.firebasestorage.app',
    messagingSenderId: '546023044699',
    appId: '<YOUR_WEB_APP_ID>',
    measurementId: '<YOUR_MEASUREMENT_ID>',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCY5pqtJLsZUyTDfWRX3URLcMnghsymXE',
    appId: '1:546023044699:android:049fa65619a28635cf317e',
    messagingSenderId: '546023044699',
    projectId: 'style-with-us-4ee75',
    storageBucket: 'style-with-us-4ee75.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCY5pqtJLsZUyTDfWRX3URLcMnghsymXE',
    appId: '<YOUR_IOS_APP_ID>',
    messagingSenderId: '546023044699',
    projectId: 'style-with-us-4ee75',
    storageBucket: 'style-with-us-4ee75.firebasestorage.app',
    iosBundleId: '<YOUR_IOS_BUNDLE_ID>',
  );
}
