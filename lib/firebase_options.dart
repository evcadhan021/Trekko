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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4UL68R-_rrqns1ADUN4fX4Ui_B34mxqI',
    appId: '1:562484766953:web:4a51201a30129601566878',
    messagingSenderId: '562484766953',
    projectId: 'trekko-app-2026',
    authDomain: 'trekko-app-2026.firebaseapp.com',
    storageBucket: 'trekko-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-fCAsIQSzRuRNuV6UML8NMmwImjdwf1k',
    appId: '1:562484766953:android:0d9df7b376324173566878',
    messagingSenderId: '562484766953',
    projectId: 'trekko-app-2026',
    storageBucket: 'trekko-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtuqFOYFgJTfIeMvMtPnTpHlzwrx3_l7o',
    appId: '1:562484766953:ios:e75562f810faa417566878',
    messagingSenderId: '562484766953',
    projectId: 'trekko-app-2026',
    storageBucket: 'trekko-app-2026.firebasestorage.app',
    iosBundleId: 'com.example.trekko',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtuqFOYFgJTfIeMvMtPnTpHlzwrx3_l7o',
    appId: '1:562484766953:ios:e75562f810faa417566878',
    messagingSenderId: '562484766953',
    projectId: 'trekko-app-2026',
    storageBucket: 'trekko-app-2026.firebasestorage.app',
    iosBundleId: 'com.example.trekko',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4UL68R-_rrqns1ADUN4fX4Ui_B34mxqI',
    appId: '1:562484766953:web:3e9740b1dc4018bf566878',
    messagingSenderId: '562484766953',
    projectId: 'trekko-app-2026',
    authDomain: 'trekko-app-2026.firebaseapp.com',
    storageBucket: 'trekko-app-2026.firebasestorage.app',
  );
}
