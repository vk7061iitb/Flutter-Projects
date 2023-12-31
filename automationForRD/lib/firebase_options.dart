// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCZDhs5TDlSPPtLeD87ZOi24z0meu8fOsE',
    appId: '1:866646434645:web:567fb0e8b38990815c85dc',
    messagingSenderId: '866646434645',
    projectId: 'automation-for-road-dev',
    authDomain: 'automation-for-road-dev.firebaseapp.com',
    storageBucket: 'automation-for-road-dev.appspot.com',
    measurementId: 'G-SH63E5NCZF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEdIsYSd6WTytJDhF5ns2mTdKdmioMXP0',
    appId: '1:866646434645:android:9be7fe34fb8ef8ea5c85dc',
    messagingSenderId: '866646434645',
    projectId: 'automation-for-road-dev',
    storageBucket: 'automation-for-road-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDcpzTtcKff2E-rKMYM2PamMK04yC5gb0',
    appId: '1:866646434645:ios:1df9b3eab304dcd55c85dc',
    messagingSenderId: '866646434645',
    projectId: 'automation-for-road-dev',
    storageBucket: 'automation-for-road-dev.appspot.com',
    iosBundleId: 'com.example.assingment1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBDcpzTtcKff2E-rKMYM2PamMK04yC5gb0',
    appId: '1:866646434645:ios:52cfc33f5d4da9bc5c85dc',
    messagingSenderId: '866646434645',
    projectId: 'automation-for-road-dev',
    storageBucket: 'automation-for-road-dev.appspot.com',
    iosBundleId: 'com.example.assingment1.RunnerTests',
  );
}
