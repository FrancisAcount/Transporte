import 'package:flutter/material.dart';

/// Marcas sociales oficiales de Transporte Escolar Maranata.
///
/// Material Icons no incluye los logotipos de Facebook ni de TikTok, así que
/// ambos se dibujan con trazos vectoriales simples y escalables.
enum SocialBrand {
  facebook(color: Color(0xFF1877F2)),
  tiktok(color: Color(0xFF0F172A));

  const SocialBrand({required this.color});

  /// Color corporativo del recuadro.
  final Color color;
}

/// Botón circular con el icono de una red social.
class SocialIcon extends StatelessWidget {
  const SocialIcon({
    super.key,
    required this.brand,
    this.size = 40,
    this.tooltip,
    this.onTap,
  });

  final SocialBrand brand;
  final double size;
  final String? tooltip;

  /// Callback opcional: convierte el icono en un botón pulsable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget icono = CustomPaint(
      painter: _SocialPainter(brand),
      size: Size.square(size * 0.58),
    );

    if (tooltip != null) {
      icono = Tooltip(message: tooltip!, child: icono);
    }

    return Material(
      color: brand.color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: icono),
        ),
      ),
    );
  }
}

/// Dibuja el glifo blanco de la marca seleccionada.
class _SocialPainter extends CustomPainter {
  const _SocialPainter(this.brand);

  final SocialBrand brand;

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    if (brand == SocialBrand.facebook) {
      // Trazo vertical de la «f».
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(38, 20, 20, 78), const Radius.circular(6)),
        pintura,
      );
      // travesaño horizontal.
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(20, 42, 56, 16), const Radius.circular(6)),
        pintura,
      );
      // Gancho superior.
      canvas.drawPath(
        Path()
          ..moveTo(58, 20)
          ..lineTo(80, 20)
          ..lineTo(80, 30)
          ..lineTo(62, 30)
          ..quadraticBezierTo(60, 30, 60, 36)
          ..lineTo(60, 44)
          ..lineTo(54, 44)
          ..lineTo(54, 36)
          ..quadraticBezierTo(54, 20, 74, 20)
          ..close(),
        pintura,
      );
    } else {
      // Nota musical: cabeza, asta y banderola del logotipo de TikTok.
      canvas.drawOval(const Rect.fromLTWH(14, 58, 42, 34), pintura);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(48, 12, 14, 72), const Radius.circular(7)),
        pintura,
      );
      canvas.drawPath(
        Path()
          ..moveTo(62, 12)
          ..quadraticBezierTo(92, 18, 88, 48)
          ..lineTo(74, 44)
          ..quadraticBezierTo(80, 26, 62, 28)
          ..close(),
        pintura,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SocialPainter oldDelegate) => oldDelegate.brand != brand;
}
