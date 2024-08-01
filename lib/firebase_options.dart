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
    apiKey: 'AIzaSyCJSkMAaVQYxRvUDwmmMXnJaiB18yyb_qo',
    appId: '1:252840820791:web:e9ff33cc08aedb6bf37fb2',
    messagingSenderId: '252840820791',
    projectId: 'splitbill-93a0f',
    authDomain: 'splitbill-93a0f.firebaseapp.com',
    storageBucket: 'splitbill-93a0f.appspot.com',
    measurementId: 'G-228QL2B328',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtTpQYcgHCfhdJFB5ntJdCOSYJgLHPleM',
    appId: '1:252840820791:android:47c97169d2c808faf37fb2',
    messagingSenderId: '252840820791',
    projectId: 'splitbill-93a0f',
    storageBucket: 'splitbill-93a0f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgSIqvGyL08QlsZoi9HUwImztdi754jLs',
    appId: '1:252840820791:ios:e2b4cbb81acf82fbf37fb2',
    messagingSenderId: '252840820791',
    projectId: 'splitbill-93a0f',
    storageBucket: 'splitbill-93a0f.appspot.com',
    iosBundleId: 'com.example.splitbill',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgSIqvGyL08QlsZoi9HUwImztdi754jLs',
    appId: '1:252840820791:ios:e2b4cbb81acf82fbf37fb2',
    messagingSenderId: '252840820791',
    projectId: 'splitbill-93a0f',
    storageBucket: 'splitbill-93a0f.appspot.com',
    iosBundleId: 'com.example.splitbill',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJSkMAaVQYxRvUDwmmMXnJaiB18yyb_qo',
    appId: '1:252840820791:web:231abe291f536a16f37fb2',
    messagingSenderId: '252840820791',
    projectId: 'splitbill-93a0f',
    authDomain: 'splitbill-93a0f.firebaseapp.com',
    storageBucket: 'splitbill-93a0f.appspot.com',
    measurementId: 'G-2J9266LSLJ',
  );

}