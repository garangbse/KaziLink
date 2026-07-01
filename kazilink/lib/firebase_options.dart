import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
        return linux;
      case TargetPlatform.fuchsia:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlXm1fYYZSliJNE97PsSxr0CpNtBnfOVs',
    appId: '1:851121082741:web:3aad88e9932a022e5b833c',
    messagingSenderId: '851121082741',
    projectId: 'kazilink-4f142',
    authDomain: 'kazilink-4f142.firebaseapp.com',
    storageBucket: 'kazilink-4f142.firebasestorage.app',
    measurementId: 'G-7P6HH1M6W5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrO2sQz_AP9os8xv7-qWFyrTQMzdItmd4',
    appId: '1:851121082741:android:eb70f827ad094a3f5b833c',
    messagingSenderId: '851121082741',
    projectId: 'kazilink-4f142',
    storageBucket: 'kazilink-4f142.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3xWB2AuWUenzFhs5baxedoNCBXA6QoY0',
    appId: '1:851121082741:ios:5b73e623ad7b204b5b833c',
    messagingSenderId: '851121082741',
    projectId: 'kazilink-4f142',
    storageBucket: 'kazilink-4f142.firebasestorage.app',
    iosBundleId: 'com.example.kazilink',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3xWB2AuWUenzFhs5baxedoNCBXA6QoY0',
    appId: '1:851121082741:ios:5b73e623ad7b204b5b833c',
    messagingSenderId: '851121082741',
    projectId: 'kazilink-4f142',
    storageBucket: 'kazilink-4f142.firebasestorage.app',
    iosBundleId: 'com.example.kazilink',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlXm1fYYZSliJNE97PsSxr0CpNtBnfOVs',
    appId: '1:851121082741:web:684de3321c5dd28e5b833c',
    messagingSenderId: '851121082741',
    projectId: 'kazilink-4f142',
    authDomain: 'kazilink-4f142.firebaseapp.com',
    storageBucket: 'kazilink-4f142.firebasestorage.app',
    measurementId: 'G-Y9KFW53V8W',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_LINUX_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET',
  );
}
