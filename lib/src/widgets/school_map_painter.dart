import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mapa escolar simulado dibujado con Canvas (sin dependencias ni APIs externas).
/// Permite sustituirlo por un mapa real (google_maps_flutter / flutter_map)
/// manteniendo la misma interfaz visual.
class SchoolMapPainter extends CustomPainter {
  const SchoolMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF1F5F9));

    // Bloques de ciudad
    final block = Paint()..color = const Color(0xFFE2E8F0);
    for (int i = 0; i < 14; i++) {
      final w = size.width * (0.05 + (i % 4) * 0.03);
      final h = size.height * (0.10 + (i % 3) * 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((size.width * 0.06 * (i + 1)) % (size.width * 0.9), size.height * (0.12 * (i % 5) + 0.08), w, h),
          const Radius.circular(6),
        ),
        block,
      );
    }

    // VíasHorizontales
    final horizontal = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int r = 1; r <= 3; r++) {
      final y = size.height * r / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + (r.isEven ? 18 : -18)), horizontal);
    }

    // Vías verticales
    final vertical = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    for (int c = 1; c <= 4; c++) {
      final x = size.width * c / 5;
      canvas.drawLine(Offset(x, 0), Offset(x + 12, size.height), vertical);
    }

    // Trazado de la ruta (guindo)
    final route = Paint()
      ..color = AppColors.guindo
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final points = [
      Offset(size.width * 0.08, size.height * 0.80),
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.42, size.height * 0.62),
      Offset(size.width * 0.58, size.height * 0.35),
      Offset(size.width * 0.78, size.height * 0.28),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, route);

    // Paradas de la ruta
    final fill = Paint()..color = Colors.white;
    final border = Paint()
      ..color = AppColors.guindo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final p in points) {
      canvas.drawCircle(p, 6, fill);
      canvas.drawCircle(p, 6, border);
    }

    // Colegio (destino final)
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.22), 12, Paint()..color = AppColors.sidebarBg);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.876, size.height * 0.14, 3, 10), Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
