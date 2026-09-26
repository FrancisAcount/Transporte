// TODO: elimínalo cuando ejecutes `flutter create .` en esta carpeta.
library;

import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(const MaranataApp());
}

/// Raíz de la aplicación.
class MaranataApp extends StatelessWidget {
  const MaranataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transporte Escolar Maranata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Sin banners de la app: el sistema adaptativo hace ese trabajo.
      home: const HomeScreen(),
    );
  }
}
