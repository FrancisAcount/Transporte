// Test de humo: verifica que la app arranca y que la navegación cambia de módulo.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:transporte_maranata/main.dart';

void main() {
  testWidgets('La app inicia en el Panel de Inicio y navega a los 7 módulos', (tester) async {
    // Simula una pantalla de escritorio: por debajo de 900 px el menú pasa a Drawer.
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaranataApp());
    await tester.pumpAndSettle();

    // Módulo inicial
    expect(find.text('Panel de Inicio'), findsWidgets);
    expect(find.text('Resumen operativo de flota y estudiantes'), findsOneWidget);

    // Recorre los 7 apartados del menú lateral
    const modulos = [
      'Rutas y Monitoreo',
      'Gestión de Flota',
      'Conductores y Personal',
      'Registro de Estudiantes',
      'Alertas y Seguridad',
      'Configuración',
    ];

    for (final modulo in modulos) {
      await tester.tap(find.text(modulo).first);
      await tester.pumpAndSettle();
      expect(find.text(modulo), findsWidgets, reason: 'No se renderizó el módulo $modulo');
    }
  });
}
