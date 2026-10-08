import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'welcome/welcome_benefits.dart';
import 'welcome/welcome_footer.dart';
import 'welcome/welcome_gallery.dart';
import 'welcome/welcome_header.dart';
import 'welcome/welcome_hero.dart';
import 'welcome/welcome_metrics_routes.dart';
import 'welcome/welcome_services.dart';
import 'welcome/welcome_tables.dart';

/// Bienvenida: portada institucional integrada en el panel lateral.
///
/// Se muestra como módulo 0 del listado de `HomeScreen`, con el sidebar azul
/// visible a la izquierda. Desde aquí, «Iniciar Sesión» devuelve al usuario al
/// Panel de Inicio mediante [onIniciarSesion].
/// Estructura descendente: esta pantalla solo orquesta las secciones en el
/// orden de la referencia y delega la maquetación de cada bloque a un widget
/// independiente dentro de `views/welcome/`.
///
///   1. [WelcomeHeader]              → título, buscador y «Ver rutas».
///   2. [WelcomeHero]                → banner de bienvenida dividido.
///   3. [WelcomeServices]            → tarjeta azul + tarjetas apiladas.
///   4. [WelcomeBenefitsCarousel]    → carrusel de beneficios.
///   5. [WelcomeMetricsRoutes]       → métricas y tarjetas de ruta.
///   6. [WelcomeTablesSection]       → horarios, avisos y estado del servicio.
///   7. [WelcomeGallerySection]      → galería de la flota y objetivos.
///   8. [WelcomeFooter]              → suscripción y pie institucional.
///
/// Todo el contenido vive dentro de un único [SingleChildScrollView] para
/// garantizar un scroll continuo entre bloques.
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key, this.onIniciarSesion});

  /// Callback invocado por «Iniciar Sesión» para volver al Panel de Inicio.
  final VoidCallback? onIniciarSesion;

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  /// Consulta del buscador del header.
  final TextEditingController _buscador = TextEditingController();

  /// Identificador de la sección de rutas, para desplazar el scroll hasta ella.
  final GlobalKey _anclaRutas = GlobalKey();

  /// Texto actual del buscador.
  String _consulta = '';

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  /// Desplaza la página hasta el bloque de rutas (botón «Ver rutas»).
  void _irARutas() {
    final contexto = _anclaRutas.currentContext;
    if (contexto == null) return;
    Scrollable.ensureVisible(
      contexto,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
      // Deja respirar el bloque bajo el header fijo.
      alignment: 0.05,
    );
  }

  /// Aviso uniforme para las acciones simuladas de la portada.
  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      // Un solo scroll vertical para toda la portada.
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header compacto con buscador.
            WelcomeHeader(
              controller: _buscador,
              onQueryChanged: (valor) => setState(() => _consulta = valor),
              onVerRutas: _irARutas,
              onIniciarSesion: () => widget.onIniciarSesion?.call(),
            ),

            // 2. Banner de bienvenida dividido.
            WelcomeHero(
              onVerRutas: _irARutas,
              onSolicitar: () => _aviso('Solicitud de transporte · formulario simulado'),
            ),

            // 3. Servicios: tarjeta azul + dos tarjetas blancas.
            WelcomeServices(
              onVerRutas: _irARutas,
              onSolicitar: () => _aviso('Solicitud de transporte · formulario simulado'),
            ),

            // 4. Carrusel horizontal de beneficios.
            const WelcomeBenefitsCarousel(),

            // 5. Métricas clave + tarjetas de las rutas principales.
            WelcomeMetricsRoutes(
              key: _anclaRutas,
              consulta: _consulta,
              onLimpiarConsulta: () {
                _buscador.clear();
                setState(() => _consulta = '');
              },
              onVerRuta: (ruta) => _aviso('${ruta.name} · detalle de ruta simulado'),
            ),

            // 6. Tablas de horarios, avisos y estado del servicio.
            const WelcomeTablesSection(),

            // 7. Galería de la flota y objetivos del proyecto.
            const WelcomeGallerySection(),

            // 8. Pie institucional con suscripción.
            WelcomeFooter(
              onSuscribirse: (correo) => _aviso('¡Gracias! Enviamos las novedades a $correo'),
            ),

            // Cierre visual de la página.
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}
