import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de Firebase — proyecto trasporte-maranata.
///
/// Web configurada con credenciales reales. Android/Windows reutilizan el
/// mismo projectId/databaseURL; para APK release ejecuta
/// `flutterfire configure` y pega los apiKey/appId nativos.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no configurado para linux. '
          'Ejecuta `flutterfire configure`.',
        );
      default:
        throw UnsupportedError(
          'Plataforma no soportada. Ejecuta `flutterfire configure`.',
        );
    }
  }

  // Configuracion Web real — proyecto trasporte-maranata.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDXDgSQCHytKNw4qrrqqyPDp9-Dj-jgs54',
    appId: '1:17193962527:web:438203ff0ab55b00ddd92a',
    messagingSenderId: '17193962527',
    projectId: 'trasporte-maranata',
    authDomain: 'trasporte-maranata.firebaseapp.com',
    databaseURL: 'https://trasporte-maranata-default-rtdb.firebaseio.com',
    storageBucket: 'trasporte-maranata.firebasestorage.app',
    measurementId: 'G-19Y1K8GJGV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXDgSQCHytKNw4qrrqqyPDp9-Dj-jgs54',
    appId: '1:17193962527:web:438203ff0ab55b00ddd92a',
    messagingSenderId: '17193962527',
    projectId: 'trasporte-maranata',
    databaseURL: 'https://trasporte-maranata-default-rtdb.firebaseio.com',
    storageBucket: 'trasporte-maranata.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXDgSQCHytKNw4qrrqqyPDp9-Dj-jgs54',
    appId: '1:17193962527:web:438203ff0ab55b00ddd92a',
    messagingSenderId: '17193962527',
    projectId: 'trasporte-maranata',
    databaseURL: 'https://trasporte-maranata-default-rtdb.firebaseio.com',
    storageBucket: 'trasporte-maranata.firebasestorage.app',
    iosBundleId: 'com.example.transporteMaranata',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDXDgSQCHytKNw4qrrqqyPDp9-Dj-jgs54',
    appId: '1:17193962527:web:438203ff0ab55b00ddd92a',
    messagingSenderId: '17193962527',
    projectId: 'trasporte-maranata',
    authDomain: 'trasporte-maranata.firebaseapp.com',
    databaseURL: 'https://trasporte-maranata-default-rtdb.firebaseio.com',
    storageBucket: 'trasporte-maranata.firebasestorage.app',
    measurementId: 'G-19Y1K8GJGV',
  );
}
