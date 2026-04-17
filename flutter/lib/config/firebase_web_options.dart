import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseWebOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
          'FirebaseWebOptions.currentPlatform solo aplica en web.');
    }

    return const FirebaseOptions(
      apiKey: 'AIzaSyCRQuqtrfPPi5zVA7gRthU_XhXIIwZLcns',
      appId: '1:49512358118:android:9928f773bd15f591c05b27',
      messagingSenderId: '49512358118',
      projectId: 'embajadores-x',
      storageBucket: 'embajadores-x.firebasestorage.app',
      authDomain: 'embajadores-x.firebaseapp.com',
    );
  }
}
