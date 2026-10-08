// Test de humo: verifica que la app arranca y que la navegación cambia de módulo.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:transporte_maranata/main.dart';
import 'package:transporte_maranata/src/data/admin_store.dart';
import 'package:transporte_maranata/src/views/dashboard_view.dart';
import 'package:transporte_maranata/src/views/intro_view.dart';
import 'package:transporte_maranata/src/views/welcome_view.dart';
import 'package:transporte_maranata/src/widgets/app_sidebar.dart';

/// Entra al panel de gestión desde la portada pública.
///
/// En escritorio se pulsa el botón con etiqueta; en móvil el header oculta el
/// texto y solo muestra el icono, así que se localiza por su tooltip.
Future<void> _entrarAlSistema(WidgetTester tester) async {
  final porTexto = find.text('Iniciar Sesión');
  if (porTexto.evaluate().isNotEmpty) {
    await tester.tap(porTexto);
  } else {
    await tester.tap(find.byTooltip('Iniciar Sesión'));
  }
  await tester.pumpAndSettle();
}

/// Lanza la app, espera la coreografía de la intro (2.8 s) y entra al panel
/// pulsando su botón «Entrar al panel».
///
/// [app] permite inyectar un `MaranataApp` con clave para recrear el árbol.
Future<void> _arrancarApp(WidgetTester tester, {Widget? app}) async {
  await tester.pumpWidget(app ?? const MaranataApp());
  await tester.pumpAndSettle(); // termina la animación y aparece el botón
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar al panel'));
  await tester.pumpAndSettle(); // fundido hacia HomeScreen
}

/// Desplaza la portada hasta dejar visible [finder] en pantalla.
///
/// [scrollable] debe apuntar al `Scrollable` real: `scrollUntilVisible` no
/// acepta el `SingleChildScrollView` que lo envuelve.
Future<void> _llevarA(WidgetTester tester, Finder finder,
    {Finder? scrollable}) async {
  await tester.scrollUntilVisible(finder, 220,
      scrollable: scrollable ?? _scrollVertical);
  await tester.pumpAndSettle();
}

/// El `Scrollable` vertical de la portada.
///
/// Se limita a los descendientes del `WelcomeView`: otras vistas (tablas de
/// estudiantes, etc.) también crean `Scrollable` verticales.
final Finder _scrollVertical = find.descendant(
  of: find.byType(WelcomeView),
  matching: find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down),
);

void main() {
  testWidgets('La intro animada muestra la marca y navega al panel',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaranataApp());
    await tester.pump();

    // La intro es la pantalla inicial y presenta la identidad de la marca.
    expect(find.byType(IntroView), findsOneWidget);
    expect(find.text('Maranata'), findsOneWidget);
    expect(find.text('TRANSPORTE ESCOLAR'), findsOneWidget);
    expect(find.text('Preparando tu viaje…'), findsOneWidget);

    // Al terminar la coreografía NO se navega sola: aparece el botón de entrada.
    await tester.pumpAndSettle();
    expect(find.byType(IntroView), findsOneWidget);
    expect(find.text('Listo para entrar'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar al panel'), findsOneWidget);

    // Solo el botón lleva al panel, con fundido.
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar al panel'));
    await tester.pumpAndSettle();
    expect(find.byType(IntroView), findsNothing);
    expect(find.text('Servicio de transporte escolar'), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La intro se salta con un toque en la pantalla', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaranataApp());
    await tester.pump();
    expect(find.byType(IntroView), findsOneWidget);

    await tester.tap(find.byType(IntroView));
    await tester.pumpAndSettle();

    expect(find.byType(IntroView), findsNothing);
    expect(find.text('Servicio de transporte escolar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La app inicia en Bienvenida y navega por los 7 módulos',
      (tester) async {
    // Simula una pantalla de escritorio: por debajo de 900 px el menú pasa a Drawer.
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // Módulo inicial: la portada pública de bienvenida.
    expect(find.text('Servicio de transporte escolar'), findsOneWidget);
    // «Ver rutas» aparece en el header, en el hero y en la tarjeta azul.
    expect(find.text('Ver rutas'), findsWidgets);

    // «Iniciar Sesión» lleva al Panel de Inicio.
    await _entrarAlSistema(tester);
    await tester.pumpAndSettle();
    expect(
        find.text('Resumen operativo de flota y estudiantes'), findsOneWidget);

    // Recorre los 6 módulos restantes del menú lateral.
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
      expect(find.text(modulo), findsWidgets,
          reason: 'No se renderizó el módulo $modulo');
    }
  });

  testWidgets('Bienvenida se integra en el panel con el sidebar visible',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // La portada premium se renderiza dentro del shell del panel, no aislada.
    expect(find.byType(WelcomeView), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);

    // La portada no duplica la cabecera del shell: solo existe su propio header.
    expect(find.text('Servicio de transporte escolar'), findsOneWidget);

    // «Bienvenida» es la primera opción del menú lateral y arranca seleccionada.
    expect(find.text('Bienvenida'), findsOneWidget);

    // Desde el sidebar se llega al resto de módulos sin perder la navegación.
    await tester.tap(find.text('Panel de Inicio').first);
    await tester.pumpAndSettle();
    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.byType(AppSidebar), findsOneWidget);

    // Y se vuelve a la portada desde el propio sidebar.
    await tester.tap(find.text('Bienvenida').first);
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeView), findsOneWidget);
  });

  testWidgets('«Iniciar Sesión» salta del índice 0 al Panel de Inicio',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);
    expect(find.byType(WelcomeView), findsOneWidget);

    await _entrarAlSistema(tester);

    // Índice 1 == «Panel de Inicio»: la cabecera del shell reaparece.
    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.byType(WelcomeView), findsNothing);
    expect(
        find.text('Resumen operativo de flota y estudiantes'), findsOneWidget);
  });
  testWidgets('Conductores: búsqueda, filtros y alta de registro',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // El AdminStore es un singleton compartido: el alta de esta prueba no debe
    // contaminar los recuentos (28 unidades) de los tests siguientes.
    addTearDown(AdminStore.instance.restaurarSemilla);

    await _arrancarApp(tester);
    await _entrarAlSistema(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conductores y Personal').first);
    await tester.pumpAndSettle();

    // La lista semilla arranca con 8 conductores.
    expect(find.text('Carlos Mendoza Ríos'), findsOneWidget);

    // Filtro por estado: solo los conductores «En Ruta».
    await tester.tap(find.textContaining('En Ruta (').first);
    await tester.pumpAndSettle();
    expect(find.text('Carlos Mendoza Ríos'), findsOneWidget);
    expect(find.text('Lucía Fernández Palau'), findsNothing);

    // Búsqueda por nombre.
    await tester.tap(find.textContaining('Todos (').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'carlos');
    await tester.pumpAndSettle();
    expect(find.text('Carlos Mendoza Ríos'), findsOneWidget);
    expect(find.text('Rosa Whitaker Intriago'), findsNothing);

    // Estado vacío cuando no hay coincidencias.
    await tester.enterText(find.byType(TextField).first, 'zzzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin resultados'), findsOneWidget);
    await tester.tap(find.text('Limpiar filtros'));
    await tester.pumpAndSettle();

    // El formulario valida los campos obligatorios.
    await tester.tap(find.text('Nuevo conductor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Este campo es obligatorio'), findsWidgets);

    // Alta válida: el registro aparece de inmediato en la lista.
    final campos = find.descendant(
        of: find.byType(Dialog), matching: find.byType(TextFormField));
    await tester.enterText(campos.at(0), 'Nuevo Conductor Prueba');
    await tester.enterText(campos.at(1), '+593 99 000 0000');
    await tester.enterText(campos.at(2), 'zzz-999');
    await tester.enterText(campos.at(3), 'C1');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Conductor Prueba'), findsOneWidget);
  });

  // Verifica que Conductores no desborda en móvil ni en escritorio.
  // Cada tamaño usa una clave distinta para forzar un árbol de widgets nuevo.
  for (final tamano in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets('Conductores sin desbordamientos en ${tamano.width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _arrancarApp(tester, app: MaranataApp(key: ValueKey(tamano)));
      await _entrarAlSistema(tester);
      await tester.pumpAndSettle();

      // En móvil el menú lateral vive dentro del Drawer.
      if (tamano.width < 900) {
        await tester.tap(find.byTooltip('Abrir menú'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Conductores y Personal').first);
      await tester.pumpAndSettle();

      // El módulo debe existir y no haber lanzado excepciones de layout.
      expect(find.text('Nuevo conductor'), findsOneWidget,
          reason: 'No se renderizó en $tamano');
      expect(tester.takeException(), isNull,
          reason: 'Error de layout en $tamano');
    });
  }

  testWidgets('Estudiantes: tarjetas de 28 buses y detalle tipo Excel',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);
    await _entrarAlSistema(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registro de Estudiantes').first);
    await tester.pumpAndSettle();

    // El módulo muestra 28 tarjetas de bus; ya no existe el filtro por unidad.
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Filtrar por unidad'), findsNothing);
    expect(find.text('Unidades de transporte'), findsOneWidget);
    expect(find.text('Ver estudiantes'), findsNWidgets(28));
    expect(find.text('Carlos Mendoza Ríos'), findsOneWidget);
    expect(find.text('PBA-1042'), findsOneWidget);

    // Buscador por chofer, placa o número de bus.
    await tester.enterText(find.byType(TextField).first, 'BUS-5');
    await tester.pumpAndSettle();
    expect(find.text('Ver estudiantes'), findsOneWidget);

    // Estado vacío y recuperación del buscador.
    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await tester.pumpAndSettle();
    expect(find.text('Sin resultados'), findsOneWidget);
    await tester.tap(find.text('Limpiar filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Ver estudiantes'), findsNWidgets(28));

    // Al entrar al detalle: chofer arriba y lista Excel con 16 alumnos.
    await tester
        .tap(find.widgetWithText(FilledButton, 'Ver estudiantes').first);
    await tester.pumpAndSettle();

    expect(find.text('BUS-1 · Estudiantes'), findsOneWidget);
    expect(find.text('Carlos Mendoza Ríos'), findsOneWidget);
    expect(find.text('16 estudiantes'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Apellido Paterno'), findsOneWidget);
    expect(find.text('Apellido Materno'), findsOneWidget);
    expect(find.text('Curso'), findsOneWidget);
    expect(find.text('Mateo'), findsOneWidget);

    // El detalle vive dentro del módulo: el shell conserva el menú lateral.
    expect(find.byType(AppSidebar), findsOneWidget,
        reason: 'El sidebar debe seguir visible en el detalle');
    expect(
        find.descendant(
          of: find.byType(AppSidebar),
          matching: find.text('Registro de Estudiantes'),
        ),
        findsOneWidget);

    // Se vuelve a la cuadrícula con el botón «Volver» del propio módulo.
    await tester.tap(find.byTooltip('Volver a unidades'));
    await tester.pumpAndSettle();
    expect(find.text('Ver estudiantes'), findsNWidgets(28));
    expect(find.byType(AppSidebar), findsOneWidget);
  });

  // Verifica que Estudiantes no desborda en móvil ni en escritorio.
  for (final tamano in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets('Estudiantes sin desbordamientos en ${tamano.width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _arrancarApp(tester, app: MaranataApp(key: ValueKey(tamano)));
      await _entrarAlSistema(tester);
      await tester.pumpAndSettle();

      if (tamano.width < 900) {
        await tester.tap(find.byTooltip('Abrir menú'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Registro de Estudiantes').first);
      await tester.pumpAndSettle();

      expect(find.text('Unidades de transporte'), findsOneWidget,
          reason: 'No se renderizó en $tamano');
      expect(find.text('Ver estudiantes'), findsWidgets,
          reason: 'No se renderizaron tarjetas en $tamano');
      expect(tester.takeException(), isNull,
          reason: 'Error de layout en $tamano');
    });
  }

  // Verifica que la portada no desborda en móvil ni en escritorio.
  for (final tamano in [const Size(390, 844), const Size(1440, 900)]) {
    testWidgets('Portada sin desbordamientos en ${tamano.width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _arrancarApp(tester, app: MaranataApp(key: ValueKey(tamano)));

      // Bloque 1 (header) y bloque 2 (hero) deben estar visibles sin scroll.
      expect(find.text('Servicio de transporte escolar'), findsOneWidget);
      expect(find.text('¡Bienvenidos al transporte escolar Maranata!'),
          findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: 'Error de layout en $tamano');
    });
  }

  testWidgets('Portada: los 7 bloques se renderizan', (tester) async {
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // Bloque 1: header + buscador compacto.
    expect(find.text('Colegio Maranata'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Buscar ruta, paradero...'),
        findsOneWidget);

    // Bloque 2: hero dividido.
    expect(find.text('Bienvenido'), findsOneWidget);

    // Bloque 3: tarjeta azul + tarjetas apiladas.
    expect(find.text('Tu colegio, a un viaje seguro de distancia'),
        findsOneWidget);
    expect(find.text('Mañana - Tarde'), findsOneWidget);

    // Bloque 4: carrusel de beneficios.
    expect(find.text('Viaja con tranquilidad'), findsOneWidget);

    // Bloque 5: métricas y rutas principales. «Ruta Norte» aparece en
    // la tarjeta de ruta y en la tabla de paraderos.
    expect(find.text('18'), findsWidgets);
    expect(find.text('Ruta Norte'), findsWidgets);
    expect(find.text('Ruta Sur'), findsWidgets);
    expect(find.text('Ruta Centro'), findsWidgets);

    // Bloque 6: tablas, avisos y estado del servicio.
    expect(find.text('Salidas de mañana'), findsOneWidget);
    expect(find.text('Últimos avisos'), findsOneWidget);
    expect(find.text('Estado del servicio'), findsOneWidget);
    expect(find.text('Paraderos principales'), findsOneWidget);
    expect(find.text('Activo'), findsNWidgets(4));

    // Bloque 7: galería y footer institucional.
    expect(find.text('Galería de la flota'), findsOneWidget);
    expect(find.text('Nuestra flota'), findsOneWidget);
    expect(find.text('Síguenos'), findsOneWidget);
    expect(find.text('Navegación'), findsOneWidget);
    // «Contacto» aparece como columna del footer y como enlace de navegación.
    expect(find.text('Contacto'), findsWidgets);
    expect(find.text('Suscribirme'), findsOneWidget);
  });

  testWidgets('Portada: el buscador filtra las rutas', (tester) async {
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // Las tarjetas de ruta están en el bloque 5: hay que llegar hasta ellas.
    // `.first` porque el texto se repite en la tabla de paraderos.
    await _llevarA(tester, find.text('Ruta Norte').first);

    await tester.enterText(
        find.widgetWithText(TextField, 'Buscar ruta, paradero...'), 'norte');
    await tester.pumpAndSettle();

    // «Ver ruta» (singular) solo existe en las tarjetas del bloque 5, así que
    // cuenta cuántas rutas sobreviven al filtro. Los nombres también salen en
    // la tabla de paraderos, que no se filtra.
    expect(find.text('Ver ruta'), findsOneWidget);

    // Estado vacío y recuperación con «Limpiar búsqueda».
    await tester.enterText(
        find.widgetWithText(TextField, 'Buscar ruta, paradero...'), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Limpiar búsqueda'), findsOneWidget);
    await tester.tap(find.text('Limpiar búsqueda'));
    await tester.pumpAndSettle();
    expect(find.text('Ver ruta'), findsNWidgets(3));
  });

  testWidgets('Portada: la suscripción valida el correo', (tester) async {
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // El footer queda al final de la portada: hay que desplazarse hasta él.
    await _llevarA(
        tester, find.widgetWithText(TextField, 'Tu correo electrónico'));

    // Correo inválido → mensaje de error.
    await tester.enterText(
        find.widgetWithText(TextField, 'Tu correo electrónico'), 'correo-malo');
    await tester.tap(find.text('Suscribirme'));
    await tester.pump();
    expect(find.text('Ingresa un correo electrónico válido'), findsOneWidget);

    // Correo válido → confirmación.
    await tester.enterText(
      find.widgetWithText(TextField, 'Tu correo electrónico'),
      'apoderado@colegio.edu.pe',
    );
    await tester.tap(find.text('Suscribirme'));
    await tester.pump();
    expect(find.textContaining('apoderado@colegio.edu.pe'), findsOneWidget);
  });

  testWidgets('Portada: el carrusel avanza con las flechas', (tester) async {
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _arrancarApp(tester);

    // La primera tarjeta es la de «Viaja con tranquilidad».
    expect(find.text('Viaja con tranquilidad'), findsOneWidget);

    await tester.tap(find.byTooltip('Beneficio siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Cerca de tu colegio'), findsOneWidget);

    await tester.tap(find.byTooltip('Beneficio siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Siempre a tiempo'), findsOneWidget);
  });
}
