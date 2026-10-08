import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../screens/home_screen.dart';

/// Pantalla de introducción animada que precede a [HomeScreen].
///
/// Reproduce la identidad institucional (cuadro guindo con el icono del bus y
/// tipografía Inter) en una coreografía escalonada de ~2.8 s:
///
/// 1. El distintivo entra con rebote suave y dos anillos de pulso.
/// 2. «Maranata» y «TRANSPORTE ESCOLAR» aparecen con desplazamiento vertical.
/// 3. Un bus cruza una carretera punteada mientras se llena la barra de progreso.
/// 4. Al terminar aparece el botón «Entrar al panel»; al pulsarlo —o al tocar
///    la pantalla— se navega a [HomeScreen] con fundido.
class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView>
    with SingleTickerProviderStateMixin {
  /// Duración total de la coreografía de entrada.
  static const Duration _duracion = Duration(milliseconds: 2800);

  late final AnimationController _control = AnimationController(
    vsync: this,
    duration: _duracion,
  );

  /// Ventana [inicio, fin] del controlador con su curva.
  Animation<double> _curva(double inicio, double fin,
      [Curve curve = Curves.easeOutCubic]) {
    return CurvedAnimation(
      parent: _control,
      curve: Interval(inicio, fin, curve: curve),
    );
  }

  late final Animation<double> _aAparicion = _curva(0.02, 0.28);
  late final Animation<double> _aAnillo1 = _curva(0.10, 0.55);
  late final Animation<double> _aAnillo2 = _curva(0.22, 0.67);
  late final Animation<double> _aDistintivo =
      _curva(0.05, 0.35, Curves.easeOutBack);
  late final Animation<double> _aTitulo = _curva(0.28, 0.52);
  late final Animation<double> _aSubtitulo = _curva(0.40, 0.62);
  late final Animation<double> _aRegla = _curva(0.45, 0.68);
  late final Animation<double> _aCarretera = _curva(0.50, 0.62);
  late final Animation<double> _aBus = _curva(0.50, 0.88, Curves.easeInOutSine);
  late final Animation<double> _aProgreso = _curva(0.0, 0.95, Curves.linear);
  /// Revelado del botón «Entrar al panel» en el tramo final (86 %–100 %).
  late final Animation<double> _aBoton = _curva(0.86, 1.0);
  /// Pista «o toca en cualquier parte» bajo el botón (92 %–100 %).
  late final Animation<double> _aPista = _curva(0.92, 1.0);

  /// Evita navegar dos veces si se pulsa el botón y la pantalla a la vez.
  bool _navego = false;

  @override
  void initState() {
    super.initState();
    _control.forward();
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  /// Reemplaza la intro por [HomeScreen] con un fundido de salida.
  void _entrar() {
    if (_navego || !mounted) return;
    _navego = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final fundido =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(opacity: fundido, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _entrar,
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: AnimatedBuilder(
          animation: _control,
          builder: (context, _) => Stack(
            children: [
              // Luz radial superior que da profundidad al fondo.
              Positioned(
                top: -120,
                left: -60,
                right: -60,
                child: Container(
                  height: 380,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.28),
                        AppColors.primaryBlue.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(child: _contenido()),
            ],
          ),
        ),
      ),
    );
  }

  /// Columna central: distintivo, marca, carretera animada y progreso.
  Widget _contenido() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _distintivo(),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _aTitulo,
              child: Transform.translate(
                offset: Offset(0, 26 * (1 - _aTitulo.value)),
                child: Text(
                  'Maranata',
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _aSubtitulo,
              child: Text(
                'TRANSPORTE ESCOLAR',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Regla institucional que se dibuja de izquierda a derecha.
            Container(
              width: 130 * _aRegla.value,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.guindo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 30),
            _carretera(),
            const SizedBox(height: 34),
            _progreso(),
          ],
        ),
      ),
    );
  }

  /// Distintivo de marca: cuadro guindo con el bus y dos anillos de pulso.
  Widget _distintivo() {
    const tamano = 92.0;

    Widget anillo(Animation<double> anim) {
      final p = anim.value;
      return Opacity(
        opacity: (1 - p) * 0.30,
        child: Transform.scale(
          scale: 1 + 0.7 * p,
          child: Container(
            width: tamano,
            height: tamano,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.6),
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _aAparicion,
      child: SizedBox(
        width: 200,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            anillo(_aAnillo1),
            anillo(_aAnillo2),
            Transform.scale(
              scale: _aDistintivo.value,
              child: Container(
                width: tamano,
                height: tamano,
                decoration: BoxDecoration(
                  color: AppColors.guindo,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.guindo.withValues(alpha: 0.38),
                      blurRadius: 42,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_filled_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carretera animada: línea de carril y bus que cruza de izquierda a derecha.
  Widget _carretera() {
    return Opacity(
      opacity: _aCarretera.value,
      child: SizedBox(
        width: 260,
        height: 46,
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final ancho = restricciones.maxWidth;
            // Ancho del grupo (líneas de movimiento + bus) para el recorrido.
            const anchoGrupo = 76.0;
            final x = (ancho - anchoGrupo) * _aBus.value;
            // Las líneas de movimiento solo se ven mientras el bus acelera.
            final movimiento =
                (4 * _aBus.value * (1 - _aBus.value)).clamp(0.0, 1.0);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: _lineaCarril(ancho),
                ),
                Positioned(
                  left: x,
                  bottom: 10,
                  child: Transform.translate(
                    offset: Offset(0, -3 * math.sin(_aBus.value * math.pi * 2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: movimiento,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 2,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 9,
                                height: 2,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.directions_bus_filled_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Línea de carril discontinua que une ambos extremos de la carretera.
  Widget _lineaCarril(double ancho) {
    final tramos = (ancho / 18).floor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        tramos,
        (_) => Container(width: 9, height: 2, color: Colors.white24),
      ),
    );
  }

  /// Barra de progreso, estado del viaje y botón de entrada a la app.
  Widget _progreso() {
    // La coreografía ya terminó: entra el botón y cambia el texto de espera.
    final listo =
        _control.status == AnimationStatus.completed || _control.value >= 1.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 3,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _aProgreso.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFF93C5FD)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          listo ? 'Listo para entrar' : 'Preparando tu viaje…',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            letterSpacing: 1.4,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 18),
        // Botón principal: se revela al terminar la coreografía.
        FadeTransition(
          opacity: _aBoton,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - _aBoton.value)),
            child: SizedBox(
              width: 230,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navyDeep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _entrar,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Entrar al panel'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: _aPista.value,
          child: Text(
            'o toca en cualquier parte',
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 0.8,
              color: Colors.white38,
            ),
          ),
        ),
      ],
    );
  }
}
