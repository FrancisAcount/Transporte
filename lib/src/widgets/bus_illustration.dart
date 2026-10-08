import 'package:flutter/material.dart';

/// Escenas de flota representadas en la portada pública.
///
/// El proyecto todavía no incluye archivos de imagen, así que cada escena se
/// dibuja con vectores. Al cargar los `assets` reales basta con sustituir
/// [BusIllustration] por un `Image.asset` conservando el mismo `height`.
enum BusScene {
  /// Bus de frente, estacionado frente a un portón escolar.
  frontal,

  /// Bus en perspectiva sobre la carretera (con línea de carril).
  carretera,

  /// Bus acompañado de estudiantes en la puerta.
  estudiantes,

  /// Bus en movimiento con arbolado de fondo (galería de flota).
  galeria,
}

/// Marcador de imagen de la flota: muestra una fotografía real de un bus
/// escolar de 18 asientos (minibús tipo Coaster) tomada de `assets/images/`.
///
/// Si el asset no estuviera disponible (p. ej. en un build sin assets), cae
/// automáticamente a la ilustración vectorial [_BusPainter] para no romper la
/// maquetación.
class BusIllustration extends StatelessWidget {
  const BusIllustration({
    super.key,
    required this.scene,
    this.height = 120,
    this.borderRadius = 14,
  });

  final BusScene scene;

  /// Alto reservado. El ancho siempre se estira al de su contenedor.
  final double height;
  final double borderRadius;

  /// Fotografía real asignada a cada escena (buses de 18 asientos).
  static const Map<BusScene, String> _fotos = {
    BusScene.frontal: 'assets/images/bus-coaster-2016.jpg',
    BusScene.carretera: 'assets/images/bus-coaster-escolar.jpg',
    BusScene.estudiantes: 'assets/images/bus-foton-18.jpg',
    BusScene.galeria: 'assets/images/bus-ankai-minibus.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(
          _fotos[scene]!,
          fit: BoxFit.cover,
          // Si el asset falta, se pinta la escena vectorial original.
          errorBuilder: (_, __, ___) => CustomPaint(painter: _BusPainter(scene)),
        ),
      ),
    );
  }
}

/// Pinta la escena completa: cielo, horizonte, carretera y el autobús.
class _BusPainter extends CustomPainter {
  _BusPainter(this.scene);

  final BusScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // Cielo degradado.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFBFDBFE)],
        ).createShader(Offset.zero & size),
    );

    // Nubes.
    _nube(canvas, Offset(w * 0.20, h * 0.24), h * 0.10);
    _nube(canvas, Offset(w * 0.74, h * 0.17), h * 0.075);

    switch (scene) {
      case BusScene.carretera:
        _carretera(canvas, w, h);
        _arbustos(canvas, w, h);
        // Bus en perspectiva, pequeño y al fondo del carril.
        _bus(canvas, Rect.fromLTWH(w * 0.30, h * 0.24, w * 0.40, h * 0.40));
        break;

      case BusScene.estudiantes:
        _suelo(canvas, w, h, 0.72);
        _arbustos(canvas, w, h);
        _bus(canvas, Rect.fromLTWH(w * 0.10, h * 0.14, w * 0.80, h * 0.56));
        _estudiantes(canvas, w, h);
        break;

      case BusScene.galeria:
        _suelo(canvas, w, h, 0.74);
        _arboles(canvas, w, h);
        _bus(canvas, Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.72, h * 0.52), angulo: -0.03);
        break;

      case BusScene.frontal:
        _suelo(canvas, w, h, 0.78);
        _arbol(canvas, Offset(w * 0.86, h * 0.50), h * 0.30);
        _arbol(canvas, Offset(w * 0.12, h * 0.54), h * 0.24);
        _bus(canvas, Rect.fromLTWH(w * 0.08, h * 0.22, w * 0.84, h * 0.56));
        break;
    }
  }
  // ------------------------------------------------------------------
  // Elementos del escenario
  // ------------------------------------------------------------------

  /// Franja de asfalto plana para las escenas de parada.
  void _suelo(Canvas canvas, double w, double h, double inicio) {
    // El shader del asfalto va de gris medio a pizarra.
    const colores = [Color(0xFF94A3B8), Color(0xFF475569)];
    canvas.drawRect(
      Rect.fromLTWH(0, h * inicio, w, h * (1 - inicio)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colores,
        ).createShader(Rect.fromLTWH(0, h * inicio, w, h)),
    );
    // Línea de acera.
    canvas.drawRect(
      Rect.fromLTWH(0, h * inicio, w, h * 0.014),
      Paint()..color = const Color(0xFFE2E8F0),
    );
  }

  /// Carretera en perspectiva con línea de carril punteada.
  void _carretera(Canvas canvas, double w, double h) {
    final horizonte = h * 0.40;
    canvas.drawRect(
      Rect.fromLTWH(0, horizonte, w, h - horizonte),
      Paint()..color = const Color(0xFF64748B),
    );
    final via = Path()
      ..moveTo(w * 0.46, horizonte)
      ..lineTo(w * 0.54, horizonte)
      ..lineTo(w * 0.96, h)
      ..lineTo(w * 0.04, h)
      ..close();
    canvas.drawPath(via, Paint()..color = const Color(0xFF334155));

    final pintura = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (var i = 0; i < 4; i++) {
      final t0 = 0.08 + i * 0.24;
      final t1 = t0 + 0.12;
      final y0 = horizonte + (h - horizonte) * t0;
      final y1 = horizonte + (h - horizonte) * t1;
      final x0 = w * 0.012 + w * 0.026 * t0;
      canvas.drawRect(
        Rect.fromLTRB(w / 2 - x0, y0, w / 2 + x0, y1),
        pintura,
      );
    }
  }

  void _nube(Canvas canvas, Offset centro, double radio) {
    final pintura = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(centro, radio, pintura);
    canvas.drawCircle(centro.translate(radio * 0.85, radio * 0.22), radio * 0.62, pintura);
    canvas.drawCircle(centro.translate(-radio * 0.85, radio * 0.28), radio * 0.52, pintura);
  }

  /// Seto bajo del fondo.
  void _arbustos(Canvas canvas, double w, double h) {
    final pintura = Paint()..color = const Color(0xFF86EFAC);
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(Offset(w * (0.02 + i * 0.16), h * 0.42), h * 0.045, pintura);
    }
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.42, w, h * 0.02),
      Paint()..color = const Color(0xFF4ADE80),
    );
  }

  /// Árbol de copa redonda (fondos de la galería y del bus frontal).
  void _arbol(Canvas canvas, Offset base, double alto) {
    canvas.drawRect(
      Rect.fromLTWH(base.dx - alto * 0.05, base.dy - alto * 0.45, alto * 0.10, alto * 0.45),
      Paint()..color = const Color(0xFF92400E),
    );
    canvas.drawCircle(
      Offset(base.dx, base.dy - alto * 0.52),
      alto * 0.28,
      Paint()..color = const Color(0xFF16A34A),
    );
    canvas.drawCircle(
      Offset(base.dx - alto * 0.20, base.dy - alto * 0.40),
      alto * 0.18,
      Paint()..color = const Color(0xFF22C55E),
    );
  }

  void _arboles(Canvas canvas, double w, double h) {
    _arbol(canvas, Offset(w * 0.08, h * 0.76), h * 0.34);
    _arbol(canvas, Offset(w * 0.90, h * 0.74), h * 0.30);
  }
  /// Autobús escolar blanco con franja institucional guindo.
  void _bus(Canvas canvas, Rect area, {double angulo = 0}) {
    canvas.save();
    canvas.translate(area.center.dx, area.center.dy);
    if (angulo != 0) canvas.rotate(angulo);
    canvas.translate(-area.width / 2, -area.height / 2);
    final w = area.width;
    final h = area.height;

    // Sombra proyectada.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.04, h * 0.80, w * 0.92, h * 0.20),
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.18),
    );

    // Carrocería.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.10, w, h * 0.74),
        Radius.circular(h * 0.16),
      ),
      Paint()..color = Colors.white,
    );

    // Parabrisas y montante central.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.07, h * 0.20, w * 0.86, h * 0.28),
        Radius.circular(h * 0.09),
      ),
      Paint()..color = const Color(0xFF1E3A8A),
    );
    final montante = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (final x in [0.34, 0.62]) {
      canvas.drawRect(Rect.fromLTWH(w * x, h * 0.20, w * 0.025, h * 0.28), montante);
    }

    // Franja institucional y remate inferior.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.56, w, h * 0.07), Paint()..color = const Color(0xFF991B1B));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.66, w, h * 0.035), Paint()..color = const Color(0xFFDB2777));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.72, w * 0.96, h * 0.12),
        Radius.circular(h * 0.05),
      ),
      Paint()..color = const Color(0xFFE2E8F0),
    );

    // Rótulo de la compañía (solo si hay ancho suficiente para leerlo).
    if (w > 90) {
      final texto = TextPainter(
        text: const TextSpan(
          text: 'MARANATA',
          style: TextStyle(
            color: Color(0xFF991B1B),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      texto.paint(canvas, Offset((w - texto.width) / 2, h * 0.645));
    }

    // Faros y ruedas.
    final faro = Paint()..color = const Color(0xFFFDE68A);
    for (final x in [0.09, 0.78]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * x, h * 0.68, w * 0.13, h * 0.08),
          Radius.circular(h * 0.03),
        ),
        faro,
      );
    }
    for (final x in [0.24, 0.76]) {
      canvas.drawCircle(Offset(w * x, h * 0.84), h * 0.14, Paint()..color = const Color(0xFF0F172A));
      canvas.drawCircle(Offset(w * x, h * 0.84), h * 0.06, Paint()..color = const Color(0xFF94A3B8));
    }

    canvas.restore();
  }

  /// Tres estudiantes con chaleco frente a la puerta del bus.
  void _estudiantes(Canvas canvas, double w, double h) {
    const chalecos = [Color(0xFF3B82F6), Color(0xFFFBBF24), Color(0xFF10B981)];
    final escala = h * 0.0016;
    final pierna = Paint()..color = const Color(0xFF1E293B);
    for (var i = 0; i < 3; i++) {
      final x = w * (0.30 + i * 0.20);
      final y = h * 0.76;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5 * escala, y - 14 * escala, 10 * escala, 14 * escala),
          Radius.circular(4 * escala),
        ),
        Paint()..color = chalecos[i],
      );
      canvas.drawCircle(
        Offset(x, y - 19 * escala),
        4.6 * escala,
        Paint()..color = const Color(0xFFFDE0C8),
      );
      canvas.drawRect(Rect.fromLTWH(x - 3.4 * escala, y, 2.4 * escala, 7 * escala), pierna);
      canvas.drawRect(Rect.fromLTWH(x + 1 * escala, y, 2.4 * escala, 7 * escala), pierna);
    }
  }

  @override
  bool shouldRepaint(covariant _BusPainter oldDelegate) => oldDelegate.scene != scene;
}

