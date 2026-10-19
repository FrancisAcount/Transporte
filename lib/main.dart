// TODO: elimínalo cuando ejecutes `flutter create .` en esta carpeta.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transporte_maranata/firebase_options.dart';
import 'src/theme/app_settings.dart';
import 'src/theme/app_theme.dart';
import 'src/views/intro_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaranataApp());
}

/// Raíz de la aplicación con tema dinámico (claro/oscuro).
class MaranataApp extends StatelessWidget {
  const MaranataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Transporte Escolar Maranata',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode:
              AppSettings.instance.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
          home: const IntroView(),
        );
      },
    );
  }
}
